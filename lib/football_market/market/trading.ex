defmodule FootballMarket.Market.Trading do
  @moduledoc """
  Unified atomic, idempotent token purchase and sale execution.

  Both purchases (investor buys tokens from the initial recipient) and sales
  (investor sells tokens back to the initial recipient) share the exact same
  locking order, idempotency guarantees, quote lookup, and double-entry credit
  ledger rules — parameterized by `side` (`:purchase` or `:sale`).
  """

  import Ecto.Query

  alias FootballMarket.Accounts.{AuthenticatedActor, User}
  alias FootballMarket.Catalog.Player

  alias FootballMarket.Market.{
    CreditBalance,
    CreditEntry,
    Error,
    Holding,
    Initialization,
    InitialRecipient,
    Issuance,
    Purchase,
    Quote,
    Sale,
    Settlement,
    TokenTransfer
  }

  alias FootballMarket.{Quotes, Repo}

  # --- Public API ---

  def purchase(actor, input) do
    with {:ok, request} <- validate(:purchase, actor, input),
         do: execute(:purchase, request)
  end

  def sale(actor, input) do
    with {:ok, request} <- validate(:sale, actor, input),
         do: execute(:sale, request)
  end

  def get_purchase(buyer_id, purchase_id), do: get_for_actor(:purchase, buyer_id, purchase_id)
  def get_sale(seller_id, sale_id), do: get_for_actor(:sale, seller_id, sale_id)

  # --- Validation ---

  def validate(side, %AuthenticatedActor{account_id: actor_id}, input) when is_map(input) do
    expected_keys = [:player_id, :quantity, :request_key]

    with {:ok, actor_uuid} <- Settlement.cast_uuid(actor_id),
         true <- input |> Map.keys() |> Enum.sort() == expected_keys,
         {:ok, player_uuid} <- Settlement.cast_uuid(input.player_id),
         true <- valid_quantity?(input.quantity),
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

  def validate(_side, %AuthenticatedActor{}, _), do: Error.new(:invalid_request, :invalid_request)
  def validate(_side, _, _), do: Error.new(:unauthenticated, :unauthenticated)

  def execute(side, request) do
    if Repo.in_transaction?() do
      Error.new(:invalid_request, :transaction_in_progress)
    else
      Settlement.safely(fn -> execute_transaction(side, request) end)
    end
  end

  def get_for_actor(side, actor_id, trade_id) do
    Settlement.safely(fn -> lookup_actor_trade(side, actor_id, trade_id) end)
  end

  # --- Transaction Settlement (also reused by ConditionalOrders) ---

  def complete(side, request) do
    {issuance, balances, holdings} = lock_resources!(side, request)
    quote = current_quote!(side, request.player_id)

    case eligible(side, request, issuance, balances, holdings, quote) do
      {:ok, prepared} ->
        write!(side, request, issuance, holdings, quote, prepared, DateTime.utc_now())

      {:error, kind} ->
        Settlement.reject(kind)
    end
  end

  @doc """
  Acquires database row locks in deterministic order (player -> users sorted by ID
  -> credit balances sorted by user ID) so concurrent trades never deadlock.
  """
  def lock_resources!(side, request) do
    if is_nil(Repo.one(from p in Player, where: p.id == ^request.player_id, lock: "FOR UPDATE")),
      do: Settlement.reject(:player_not_found)

    issuance = Repo.one(from s in Issuance, where: s.player_id == ^request.player_id)
    if is_nil(issuance), do: Settlement.reject(:not_initialized)

    actor_id = Map.fetch!(request, actor_key(side))
    if issuance.recipient_id == actor_id, do: Settlement.reject(self_trade_error(side))

    sorted_user_ids = Enum.sort([actor_id, issuance.recipient_id])

    locked_users =
      Repo.all(
        from u in User, where: u.id in ^sorted_user_ids, order_by: u.id, lock: "FOR UPDATE"
      )

    if length(locked_users) != 2, do: Settlement.reject(:inconsistent_state)

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
      {:error, :temporarily_unavailable} -> Settlement.reject(:temporarily_unavailable)
      _ -> nil
    end
  end

  def eligible(_side, _request, _issuance, _balances, _holdings, nil),
    do: {:error, :quote_unavailable}

  def eligible(side, request, issuance, balances, holdings, quote) do
    verify_player_coherence!(request.player_id, issuance, holdings)
    total = Settlement.exact_total!(quote.unit_price, request.quantity)
    {payer_id, payee_id, token_source_id} = counterparties(side, request, issuance)

    payer_balance = Enum.find(balances, fn balance -> balance.user_id == payer_id end)
    payee_balance = Enum.find(balances, fn balance -> balance.user_id == payee_id end)
    source_holding = Enum.find(holdings, fn holding -> holding.user_id == token_source_id end)

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

    Settlement.debit!(payer, total, now)
    Settlement.credit!(payee, payee_id, total, now)

    Repo.update!(Ecto.Changeset.change(source, quantity: source.quantity - request.quantity))
    credit_tokens!(holdings, request.player_id, token_destination_id, request.quantity)

    trade = insert_trade!(side, request, issuance, quote, total, now)
    trade_foreign_key = if side == :purchase, do: :purchase_id, else: :sale_id

    Repo.insert!(
      struct!(TokenTransfer, %{
        trade_foreign_key => trade.id,
        player_id: request.player_id,
        from_user_id: token_source_id,
        to_user_id: token_destination_id,
        quantity: request.quantity,
        inserted_at: now
      })
    )

    Repo.insert!(
      struct!(CreditEntry, %{
        trade_foreign_key => trade.id,
        user_id: payer_id,
        side: "debit",
        amount: total,
        inserted_at: now
      })
    )

    Repo.insert!(
      struct!(CreditEntry, %{
        trade_foreign_key => trade.id,
        user_id: payee_id,
        side: "credit",
        amount: total,
        inserted_at: now
      })
    )

    trade
  end

  def evidence(side, record) do
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

  # --- Private Helpers ---

  defp execute_transaction(side, request),
    do: Repo.transaction(fn -> transact(side, request) end)

  defp lookup_actor_trade(side, actor_id, trade_id) do
    case fetch_actor_trade(side, actor_id, trade_id) do
      nil -> {:error, :not_found}
      found -> {:ok, evidence(side, found)}
    end
  end

  defp fetch_actor_trade(:purchase, buyer_id, purchase_id),
    do: Repo.one(from p in Purchase, where: p.id == ^purchase_id and p.buyer_id == ^buyer_id)

  defp fetch_actor_trade(:sale, seller_id, sale_id),
    do: Repo.one(from s in Sale, where: s.id == ^sale_id and s.seller_id == ^seller_id)

  defp transact(side, request) do
    Settlement.isolation!()
    actor_id = Map.fetch!(request, actor_key(side))

    # Serialize concurrent retries sharing the same (actor, request_key) pair.
    Repo.query!("SELECT pg_advisory_xact_lock(hashtextextended($1,0))", [
      actor_id <> ":" <> request.request_key
    ])

    previous = find_previous_trade(side, actor_id, request.request_key)

    cond do
      previous == nil ->
        side |> complete(request) |> then(fn trade -> evidence(side, trade) end)

      previous.player_id == request.player_id and previous.quantity == request.quantity ->
        evidence(side, previous)

      true ->
        Repo.rollback(%Error{kind: :key_conflict, reason: :key_conflict})
    end
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

  defp actor_key(:purchase), do: :buyer_id
  defp actor_key(:sale), do: :seller_id

  defp self_trade_error(:purchase), do: :self_purchase
  defp self_trade_error(:sale), do: :self_sale

  defp counterparties(:purchase, request, issuance),
    do: {request.buyer_id, issuance.recipient_id, issuance.recipient_id}

  defp counterparties(:sale, request, issuance),
    do: {issuance.recipient_id, request.seller_id, request.seller_id}

  defp quote_eligible?(:purchase, %{
         calculation_id: calculation_id,
         configuration_version_id: configuration_version_id,
         mapping_id: mapping_id,
         performance_sequence: sequence,
         unit_price: price
       }) do
    not is_nil(calculation_id) and not is_nil(configuration_version_id) and
      not is_nil(mapping_id) and is_integer(sequence) and sequence > 0 and
      Settlement.exact_positive?(price)
  end

  defp quote_eligible?(:purchase, _), do: false

  defp quote_eligible?(:sale, quote),
    do: Settlement.exact_positive?(quote.unit_price)

  defp verify_player_coherence!(player_id, issuance, holdings) do
    fixed = Repo.get(InitialRecipient, 1)

    snapshot = %{
      player_id: player_id,
      recipient_id: issuance.recipient_id,
      fixed_recipient: fixed && fixed.user_id,
      issuance_recipients: Repo.all(from s in Issuance, select: s.recipient_id),
      issuance: issuance,
      holdings: holdings,
      quotes: Repo.all(from q in Quote, where: q.player_id == ^player_id),
      user_ids: Repo.all(from u in User, select: u.id)
    }

    case Initialization.validate_snapshot(snapshot) do
      {:ok, :issued} -> :ok
      _ -> Settlement.reject(:inconsistent_state)
    end
  end

  defp credit_tokens!(holdings, player_id, destination_user_id, quantity) do
    case Enum.find(holdings, fn holding -> holding.user_id == destination_user_id end) do
      nil ->
        Repo.insert!(%Holding{
          player_id: player_id,
          user_id: destination_user_id,
          quantity: quantity
        })

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

  defp valid_quantity?(quantity),
    do: is_integer(quantity) and quantity > 0 and quantity <= 2_147_483_647

  defp valid_request_key?(key) when is_binary(key) do
    String.valid?(key) and
      :binary.match(key, <<0>>) == :nomatch and
      String.trim(key) != "" and
      length(String.codepoints(key)) <= 128
  end

  defp valid_request_key?(_), do: false
end
