defmodule FootballMarket.Market do
  @moduledoc """
  Public entry point for the Market domain.

  The Market domain is organized into four files under `lib/football_market/market/`:
    * `schemas.ex` — Ecto schemas and `Market.Error`
    * `trading.ex` — initial 100-token issuance + atomic, idempotent buy/sell
    * `portfolio.ex` — holdings, credit balances, transaction history, allocation & daily chart
    * `orders.ex` — conditional buy orders and background evaluation passes
  """

  alias FootballMarket.Market.{Orders, Portfolio, Trading}

  defdelegate initialize_player(player_id, assertions \\ %{}), to: Trading
  defdelegate get_initial_issuance(player_id), to: Trading
  defdelegate purchase(actor, input), to: Trading
  defdelegate sale(actor, input), to: Trading
  defdelegate get_purchase(buyer_id, purchase_id), to: Trading
  defdelegate get_sale(seller_id, sale_id), to: Trading
  defdelegate credit_account(user_id, amount), to: Trading

  defdelegate portfolio(actor), to: Portfolio, as: :list
  defdelegate credit_balance(actor), to: Portfolio
  defdelegate initial_inventory(actor), to: Portfolio
  defdelegate initial_recipient?(actor), to: Portfolio
  defdelegate transaction_history(actor, options), to: Portfolio
  defdelegate portfolio_allocation(actor), to: Portfolio, as: :allocation
  defdelegate portfolio_history(actor, options), to: Portfolio, as: :history

  defdelegate create_conditional_order(actor, terms), to: Orders, as: :create
  defdelegate list_conditional_orders(actor), to: Orders, as: :list
  defdelegate get_conditional_order(actor, id), to: Orders, as: :get
  defdelegate cancel_conditional_order(actor, id), to: Orders, as: :cancel
  defdelegate evaluate_conditional_order(id), to: Orders, as: :evaluate
end

defmodule FootballMarket.Market.Trading do
  @moduledoc """
  Initial player token issuance and atomic, idempotent buy/sell execution.

  Core financial invariants:
    * Every player is issued exactly 100 tokens at unit price 1.00 to the single
      configured initial recipient account.
    * Purchases (investor buys from initial recipient) and sales (investor sells
      back to initial recipient) lock resources in a deterministic order
      (`player -> users sorted by ID -> credit balances sorted by ID`) so
      concurrent trades never deadlock.
    * Every trade writes a trade row, a `TokenTransfer`, and two balanced
      `CreditEntry` rows (debit + credit) atomically in one transaction.
    * Retrying the same `(actor_id, request_key)` with the same payload returns
      the original trade; reusing it with a different payload returns `:key_conflict`.
  """

  import Ecto.Query

  alias FootballMarket.Accounts.{AuthenticatedActor, User}
  alias FootballMarket.Catalog.Player

  alias FootballMarket.Market.{
    CreditBalance,
    CreditEntry,
    Error,
    Holding,
    InitializationLock,
    InitialRecipient,
    Issuance,
    Purchase,
    Quote,
    Sale,
    TokenTransfer
  }

  alias FootballMarket.{Quotes, Repo}

  # --- Initial 100-Token Issuance ---

  @doc "Issues 100 initial tokens at 1.00 for a player to the configured primary recipient."
  def initialize_player(player_id, assertions \\ %{}) do
    designation = Application.get_env(:football_market, :initial_issuance_recipients, [])

    with {:ok, validated_player_id} <- cast_uuid_or(player_id, :invalid_input, :invalid_player),
         {:ok, recipient_id} <- validate_designation(designation),
         :ok <- validate_assertions(assertions, recipient_id) do
      if Repo.in_transaction?(),
        do: Error.new(:invalid_input, :transaction_in_progress),
        else: run_initialize_tx(validated_player_id, recipient_id)
    end
  end

  defp run_initialize_tx(player_id, recipient_id) do
    safely(
      fn -> Repo.transaction(fn -> initialize_locked!(player_id, recipient_id) end) end,
      :storage_failure
    )
  end

  def get_initial_issuance(player_id) do
    with {:ok, uuid} <- cast_uuid_or(player_id, :invalid_input, :invalid_player) do
      safely(fn -> fetch_initial_issuance(uuid) end, :storage_failure)
    end
  end

  defp fetch_initial_issuance(uuid) do
    query =
      from p in Player,
        left_join: i in Issuance,
        on: i.player_id == p.id,
        left_join: q in Quote,
        on: q.id == i.initial_quote_id,
        where: p.id == ^uuid,
        select: {i, q}

    case Repo.one(query) do
      nil -> Error.new(:player_not_found, :player_not_found)
      {nil, _} -> Error.new(:not_initialized, :not_initialized)
      {issuance, quote} when not is_nil(quote) -> {:ok, issuance_evidence(issuance, quote)}
      _ -> Error.new(:inconsistent_state, :missing_original_quote)
    end
  end

  @doc "Credits an account's spendable balance (e.g. funding a test or demo investor)."
  def credit_account(user_id, %Decimal{} = amount) do
    if exact_positive?(amount) do
      now = db_clock()

      Repo.transaction(fn ->
        existing =
          Repo.one(from b in CreditBalance, where: b.user_id == ^user_id, lock: "FOR UPDATE")

        credit!(existing, user_id, amount, now)
        Repo.get!(CreditBalance, user_id)
      end)
    else
      Error.new(:invalid_request, :invalid_amount)
    end
  end

  # --- Buy & Sell ---

  def purchase(actor, input) do
    with {:ok, request} <- validate_trade(:purchase, actor, input) do
      execute_trade(:purchase, request)
    end
  end

  def sale(actor, input) do
    with {:ok, request} <- validate_trade(:sale, actor, input) do
      execute_trade(:sale, request)
    end
  end

  def get_purchase(buyer_id, purchase_id), do: fetch_trade(:purchase, buyer_id, purchase_id)
  def get_sale(seller_id, sale_id), do: fetch_trade(:sale, seller_id, sale_id)

  # --- Shared Settlement Primitives (Also Used by Conditional Orders) ---

  def lock_resources!(side, request) do
    if is_nil(Repo.one(from p in Player, where: p.id == ^request.player_id, lock: "FOR UPDATE")),
      do: reject(:player_not_found)

    issuance = Repo.one(from s in Issuance, where: s.player_id == ^request.player_id)
    if is_nil(issuance), do: reject(:not_initialized)

    actor_id = Map.fetch!(request, actor_key(side))
    if issuance.recipient_id == actor_id, do: reject(self_trade_error(side))

    sorted_user_ids = Enum.sort([actor_id, issuance.recipient_id])

    locked_users =
      Repo.all(
        from u in User, where: u.id in ^sorted_user_ids, order_by: u.id, lock: "FOR UPDATE"
      )

    if length(locked_users) != 2, do: reject(:inconsistent_state)

    locked_balances =
      Repo.all(
        from b in CreditBalance,
          where: b.user_id in ^sorted_user_ids,
          order_by: b.user_id,
          lock: "FOR UPDATE"
      )

    holdings = Repo.all(from h in Holding, where: h.player_id == ^request.player_id)
    {issuance, locked_balances, holdings}
  end

  def current_quote!(side, player_id) do
    case Quotes.latest(player_id) do
      {:ok, quote} -> if quote_eligible?(side, quote), do: quote, else: nil
      {:error, :temporarily_unavailable} -> reject(:temporarily_unavailable)
      _ -> nil
    end
  end

  def eligible(_side, _request, _issuance, _balances, _holdings, nil),
    do: {:error, :quote_unavailable}

  def eligible(side, request, issuance, balances, holdings, quote) do
    total = exact_total!(quote.unit_price, request.quantity)
    {payer_id, payee_id, token_source_id} = counterparties(side, request, issuance)

    payer_balance = Enum.find(balances, &(&1.user_id == payer_id))
    payee_balance = Enum.find(balances, &(&1.user_id == payee_id))
    source_holding = Enum.find(holdings, &(&1.user_id == token_source_id))

    cond do
      is_nil(payer_balance) or Decimal.compare(payer_balance.amount, total) == :lt ->
        {:error, :insufficient_funds}

      is_nil(source_holding) or source_holding.quantity < request.quantity ->
        {:error, :insufficient_inventory}

      true ->
        {:ok, {payer_balance, payee_balance, source_holding, total}}
    end
  end

  def write!(side, request, issuance, holdings, quote, {payer, payee, source, total}, now) do
    {payer_id, payee_id, token_source_id} = counterparties(side, request, issuance)
    token_destination_id = if token_source_id == payer_id, do: payee_id, else: payer_id

    debit!(payer, total, now)
    credit!(payee, payee_id, total, now)

    Repo.update!(Ecto.Changeset.change(source, quantity: source.quantity - request.quantity))
    credit_tokens!(holdings, request.player_id, token_destination_id, request.quantity)

    trade = insert_trade!(side, request, issuance, quote, total, now)
    trade_fk = if side == :purchase, do: :purchase_id, else: :sale_id

    Repo.insert!(
      struct!(TokenTransfer, %{
        trade_fk => trade.id,
        player_id: request.player_id,
        from_user_id: token_source_id,
        to_user_id: token_destination_id,
        quantity: request.quantity,
        inserted_at: now
      })
    )

    Repo.insert!(
      struct!(CreditEntry, %{
        trade_fk => trade.id,
        user_id: payer_id,
        side: "debit",
        amount: total,
        inserted_at: now
      })
    )

    Repo.insert!(
      struct!(CreditEntry, %{
        trade_fk => trade.id,
        user_id: payee_id,
        side: "credit",
        amount: total,
        inserted_at: now
      })
    )

    trade
  end

  def exact_positive?(%Decimal{coef: coef, sign: 1} = value) when is_integer(coef) and coef > 0,
    do: Decimal.equal?(value, Decimal.round(value, 2))

  def exact_positive?(_), do: false

  def db_clock do
    [[now]] = Repo.query!("SELECT clock_timestamp() AT TIME ZONE 'UTC'").rows
    DateTime.from_naive!(now, "Etc/UTC")
  end

  def require_read_committed! do
    if Repo.query!("SHOW transaction_isolation").rows != [["read committed"]],
      do: reject(:invalid_request)
  end

  def reject(kind), do: Repo.rollback(%Error{kind: kind, reason: kind})

  def safely(fun, failure_kind \\ :temporarily_unavailable) do
    fun.()
  rescue
    _ in [
      Postgrex.Error,
      DBConnection.ConnectionError,
      Ecto.ConstraintError,
      Ecto.InvalidChangesetError
    ] ->
      Error.new(failure_kind, :storage_rejected)
  end

  # --- Private Issuance Helpers ---

  defp initialize_locked!(player_id, recipient_id) do
    if Repo.query!("SHOW transaction_isolation").rows != [["read committed"]],
      do: rollback(:invalid_input, :unsupported_isolation)

    if is_nil(Repo.one(from l in InitializationLock, where: l.id == 1, lock: "FOR UPDATE")),
      do: rollback(:storage_failure, :missing_initialization_lock)

    if is_nil(Repo.one(from p in Player, where: p.id == ^player_id, lock: "FOR UPDATE")),
      do: rollback(:player_not_found, :player_not_found)

    if is_nil(Repo.one(from u in User, where: u.id == ^recipient_id, lock: "FOR KEY SHARE")),
      do: rollback(:invalid_designation, :nonexistent_recipient)

    fixed = Repo.get(InitialRecipient, 1)

    if fixed != nil and fixed.user_id != recipient_id,
      do: rollback(:recipient_conflict, :market_recipient_conflict)

    case Repo.one(from i in Issuance, where: i.player_id == ^player_id) do
      %Issuance{} = existing ->
        quote = Repo.get!(Quote, existing.initial_quote_id)
        %{outcome: :already_completed, issuance: issuance_evidence(existing, quote)}

      nil ->
        persist_initial_issuance!(player_id, recipient_id, fixed)
    end
  end

  defp persist_initial_issuance!(player_id, recipient_id, fixed) do
    now = db_clock()

    if is_nil(fixed) do
      Repo.insert!(%InitialRecipient{id: 1, user_id: recipient_id, fixed_at: now})
    end

    opening_quote =
      Repo.insert!(%Quote{
        player_id: player_id,
        unit_price: Decimal.new(1),
        effective_at: now,
        inserted_at: now,
        rule_id: "initial_issuance",
        rule_version: "1"
      })

    Repo.insert!(%Holding{player_id: player_id, user_id: recipient_id, quantity: 100})

    issuance =
      Repo.insert!(%Issuance{
        player_id: player_id,
        recipient_id: recipient_id,
        quantity: 100,
        initial_unit_price: Decimal.new(1),
        initial_quote_id: opening_quote.id,
        completed_at: now
      })

    %{outcome: :issued, issuance: issuance_evidence(issuance, opening_quote)}
  end

  defp issuance_evidence(issuance, quote) do
    %{
      id: issuance.id,
      player_id: issuance.player_id,
      recipient_id: issuance.recipient_id,
      quantity: issuance.quantity,
      initial_unit_price: issuance.initial_unit_price,
      initial_quote_id: issuance.initial_quote_id,
      initial_inventory_value:
        Decimal.mult(issuance.initial_unit_price, Decimal.new(issuance.quantity)),
      effective_at: quote.effective_at,
      rule_id: quote.rule_id,
      rule_version: quote.rule_version,
      completed_at: issuance.completed_at
    }
  end

  defp validate_designation([id]),
    do: cast_uuid_or(id, :invalid_designation, :invalid_recipient)

  defp validate_designation(value) when value in [nil, []],
    do: Error.new(:invalid_designation, :missing_designation)

  defp validate_designation(value) when is_list(value),
    do: Error.new(:invalid_designation, :ambiguous_designation)

  defp validate_designation(_), do: Error.new(:invalid_designation, :invalid_recipient)

  defp validate_assertions(attrs, recipient_id) when is_map(attrs) do
    allowed = [:recipient_id, :quantity, :unit_price]

    cond do
      Enum.any?(Map.keys(attrs), &(&1 not in allowed)) ->
        Error.new(:invalid_input, :unknown_assertion)

      Map.get(attrs, :recipient_id, recipient_id) != recipient_id ->
        Error.new(:invalid_input, :wrong_recipient)

      Map.get(attrs, :quantity, 100) !== 100 ->
        Error.new(:invalid_input, :wrong_quantity)

      not exact_one?(Map.get(attrs, :unit_price, 1)) ->
        Error.new(:invalid_input, :wrong_price)

      true ->
        :ok
    end
  end

  defp validate_assertions(_, _), do: Error.new(:invalid_input, :invalid_assertions)

  defp exact_one?(1), do: true
  defp exact_one?(%Decimal{coef: c} = d) when is_integer(c), do: Decimal.equal?(d, Decimal.new(1))
  defp exact_one?(_), do: false

  # --- Private Trade Helpers ---

  defp validate_trade(side, %AuthenticatedActor{account_id: actor_id}, input)
       when is_map(input) do
    with {:ok, actor_uuid} <- strict_uuid(actor_id),
         true <- input |> Map.keys() |> Enum.sort() == [:player_id, :quantity, :request_key],
         {:ok, player_uuid} <- strict_uuid(input.player_id),
         true <- is_integer(input.quantity) and input.quantity in 1..2_147_483_647,
         true <- valid_request_key?(input.request_key) do
      {:ok,
       %{
         actor_key(side) => actor_uuid,
         player_id: player_uuid,
         quantity: input.quantity,
         request_key: input.request_key
       }}
    else
      _ -> Error.new(:invalid_request, :invalid_request)
    end
  end

  defp validate_trade(_side, %AuthenticatedActor{}, _),
    do: Error.new(:invalid_request, :invalid_request)

  defp validate_trade(_side, _, _), do: Error.new(:unauthenticated, :unauthenticated)

  defp execute_trade(side, request) do
    if Repo.in_transaction?(),
      do: Error.new(:invalid_request, :transaction_in_progress),
      else: safely(fn -> run_trade_tx(side, request) end)
  end

  defp run_trade_tx(side, request),
    do: Repo.transaction(fn -> transact_trade!(side, request) end)

  defp transact_trade!(side, request) do
    require_read_committed!()
    actor_id = Map.fetch!(request, actor_key(side))

    Repo.query!("SELECT pg_advisory_xact_lock(hashtextextended($1,0))", [
      actor_id <> ":" <> request.request_key
    ])

    previous = find_previous_trade(side, actor_id, request.request_key)

    cond do
      previous == nil ->
        {issuance, balances, holdings} = lock_resources!(side, request)
        quote = current_quote!(side, request.player_id)

        case eligible(side, request, issuance, balances, holdings, quote) do
          {:ok, prepared} ->
            trade = write!(side, request, issuance, holdings, quote, prepared, DateTime.utc_now())
            trade_evidence(side, trade)

          {:error, kind} ->
            reject(kind)
        end

      previous.player_id == request.player_id and previous.quantity == request.quantity ->
        trade_evidence(side, previous)

      true ->
        reject(:key_conflict)
    end
  end

  defp fetch_trade(side, actor_id, trade_id) do
    safely(fn ->
      found =
        case side do
          :purchase ->
            Repo.one(from p in Purchase, where: p.id == ^trade_id and p.buyer_id == ^actor_id)

          :sale ->
            Repo.one(from s in Sale, where: s.id == ^trade_id and s.seller_id == ^actor_id)
        end

      if found, do: {:ok, trade_evidence(side, found)}, else: {:error, :not_found}
    end)
  end

  defp find_previous_trade(:purchase, buyer_id, request_key) do
    Repo.one(
      from p in Purchase,
        where:
          p.buyer_id == ^buyer_id and p.request_key == ^request_key and
            is_nil(p.conditional_order_id)
    )
  end

  defp find_previous_trade(:sale, seller_id, request_key) do
    Repo.one(from s in Sale, where: s.seller_id == ^seller_id and s.request_key == ^request_key)
  end

  defp trade_evidence(side, record) do
    drop_fields = if side == :purchase, do: [:__meta__, :conditional_order_id], else: [:__meta__]

    {transfer, ledger} =
      case side do
        :purchase ->
          {Repo.one(from t in TokenTransfer, where: t.purchase_id == ^record.id),
           Repo.all(from e in CreditEntry, where: e.purchase_id == ^record.id, order_by: e.side)}

        :sale ->
          {Repo.one(from t in TokenTransfer, where: t.sale_id == ^record.id),
           Repo.all(from e in CreditEntry, where: e.sale_id == ^record.id, order_by: e.side)}
      end

    record
    |> Map.from_struct()
    |> Map.drop(drop_fields)
    |> Map.put(:transfer, transfer)
    |> Map.put(:ledger, ledger)
  end

  defp debit!(balance, total, now), do: adjust_balance!(balance, Decimal.negate(total), now)

  defp credit!(nil, id, total, now),
    do: Repo.insert!(%CreditBalance{user_id: id, amount: total, updated_at: now})

  defp credit!(balance, _, total, now), do: adjust_balance!(balance, total, now)

  defp adjust_balance!(balance, delta, now) do
    case Repo.query!(
           "UPDATE market_credit_balances SET amount = amount + $1::numeric, updated_at = $2 WHERE user_id = $3",
           [delta, now, Ecto.UUID.dump!(balance.user_id)]
         ).num_rows do
      1 -> :ok
      0 -> reject(:inconsistent_state)
    end
  end

  defp exact_total!(unit_price, quantity) do
    case Repo.query!("SELECT $1::numeric * $2::numeric", [unit_price, quantity]).rows do
      [[%Decimal{} = total]] -> total
      _ -> reject(:inconsistent_state)
    end
  end

  defp credit_tokens!(holdings, player_id, dest_id, quantity) do
    case Enum.find(holdings, &(&1.user_id == dest_id)) do
      nil ->
        Repo.insert!(%Holding{player_id: player_id, user_id: dest_id, quantity: quantity})

      existing ->
        Repo.update!(Ecto.Changeset.change(existing, quantity: existing.quantity + quantity))
    end
  end

  defp insert_trade!(:purchase, request, issuance, quote, total, now) do
    Repo.insert!(%Purchase{
      buyer_id: request.buyer_id,
      recipient_id: issuance.recipient_id,
      player_id: request.player_id,
      request_key: request.request_key,
      conditional_order_id: Map.get(request, :conditional_order_id),
      quantity: request.quantity,
      quote_id: quote.id,
      unit_price: quote.unit_price,
      total: total,
      quote_effective_at: quote.effective_at,
      rule_id: quote.rule_id,
      rule_version: quote.rule_version,
      configuration_version_id: quote.configuration_version_id,
      mapping_id: quote.mapping_id,
      performance_sequence: quote.performance_sequence,
      completed_at: now
    })
  end

  defp insert_trade!(:sale, request, issuance, quote, total, now) do
    Repo.insert!(%Sale{
      seller_id: request.seller_id,
      buyer_id: issuance.recipient_id,
      player_id: request.player_id,
      request_key: request.request_key,
      quantity: request.quantity,
      quote_id: quote.id,
      unit_price: quote.unit_price,
      total: total,
      quote_effective_at: quote.effective_at,
      rule_id: quote.rule_id,
      rule_version: quote.rule_version,
      configuration_version_id: quote.configuration_version_id,
      mapping_id: quote.mapping_id,
      performance_sequence: quote.performance_sequence,
      completed_at: now
    })
  end

  defp quote_eligible?(:purchase, %{
         calculation_id: calc_id,
         configuration_version_id: cfg_id,
         mapping_id: map_id,
         performance_sequence: seq,
         unit_price: price
       }) do
    not is_nil(calc_id) and not is_nil(cfg_id) and not is_nil(map_id) and is_integer(seq) and
      seq > 0 and exact_positive?(price)
  end

  defp quote_eligible?(:purchase, _), do: false
  defp quote_eligible?(:sale, quote), do: exact_positive?(quote.unit_price)

  defp actor_key(:purchase), do: :buyer_id
  defp actor_key(:sale), do: :seller_id
  defp self_trade_error(:purchase), do: :self_purchase
  defp self_trade_error(:sale), do: :self_sale

  defp counterparties(:purchase, req, issuance),
    do: {req.buyer_id, issuance.recipient_id, issuance.recipient_id}

  defp counterparties(:sale, req, issuance),
    do: {issuance.recipient_id, req.seller_id, req.seller_id}

  defp strict_uuid(value) when is_binary(value) and byte_size(value) == 36,
    do: Ecto.UUID.cast(value)

  defp strict_uuid(_), do: :error

  defp cast_uuid_or(id, kind, reason) do
    case Ecto.UUID.cast(id) do
      {:ok, uuid} -> {:ok, uuid}
      _ -> Error.new(kind, reason)
    end
  end

  defp valid_request_key?(key) when is_binary(key) do
    String.valid?(key) and :binary.match(key, <<0>>) == :nomatch and
      String.trim(key) != "" and String.length(key) <= 128
  end

  defp valid_request_key?(_), do: false

  defp rollback(kind, reason) do
    {:error, err} = Error.new(kind, reason)
    Repo.rollback(err)
  end
end
