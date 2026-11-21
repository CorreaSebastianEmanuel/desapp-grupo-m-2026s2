defmodule FootballMarket.Market.Initialization do
  @moduledoc """
  One-time initial token issuance for a local player.

  Every player starts with 100 tokens allocated at a unit price of 1.00 to the
  single configured initial recipient account, alongside an opening quote and
  holding record. This module owns:

    * Input validation (`validate_input/3`, `validate_player_id/1`)
    * Pure snapshot consistency verification (`validate_snapshot/1`)
    * Locked transactional persistence (`initialize/1`, `initialize_in_transaction/1`, `get/1`)
  """

  import Ecto.Query

  alias FootballMarket.Accounts.User
  alias FootballMarket.Catalog.Player

  alias FootballMarket.Market.{
    Error,
    Holding,
    InitializationLock,
    InitialRecipient,
    Issuance,
    Quote,
    Settlement
  }

  alias FootballMarket.Repo

  # --- Input Validation ---

  def validate_input(player_id, designation, assertions) do
    with {:ok, validated_player_id} <- validate_player_id(player_id),
         {:ok, recipient_id} <- validate_designation(designation),
         :ok <- validate_assertions(assertions, recipient_id) do
      {:ok, %{player_id: validated_player_id, recipient_id: recipient_id}}
    end
  end

  def validate_player_id(id) do
    case Ecto.UUID.cast(id) do
      {:ok, uuid} -> {:ok, uuid}
      _ -> Error.new(:invalid_input, :invalid_player)
    end
  end

  def exact_one?(1), do: true

  def exact_one?(%Decimal{coef: coefficient} = decimal) when is_integer(coefficient),
    do: Decimal.equal?(decimal, Decimal.new(1))

  def exact_one?(_), do: false

  defp validate_designation([id]) do
    case Ecto.UUID.cast(id) do
      {:ok, uuid} -> {:ok, uuid}
      _ -> Error.new(:invalid_designation, :invalid_recipient)
    end
  end

  defp validate_designation(value) when value in [nil, []],
    do: Error.new(:invalid_designation, :missing_designation)

  defp validate_designation(value) when is_list(value),
    do: Error.new(:invalid_designation, :ambiguous_designation)

  defp validate_designation(_), do: Error.new(:invalid_designation, :invalid_recipient)

  defp validate_assertions(attrs, recipient_id) when is_map(attrs) do
    allowed_keys = [:recipient_id, :quantity, :unit_price]

    cond do
      Enum.any?(Map.keys(attrs), fn key -> key not in allowed_keys end) ->
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

  # --- Snapshot Consistency Rules (Pure) ---

  @doc "Verifies that persisted issuance, holdings, and quotes form a coherent financial snapshot."
  def validate_snapshot(snapshot) do
    case validate_recipient_state(snapshot) do
      :ok -> validate_history(snapshot)
      error -> error
    end
  end

  defp validate_recipient_state(snapshot) do
    cond do
      snapshot.fixed_recipient != nil and snapshot.fixed_recipient != snapshot.recipient_id ->
        Error.new(:recipient_conflict, :market_recipient_conflict)

      Enum.any?(snapshot.issuance_recipients, fn recipient ->
        recipient != snapshot.recipient_id
      end) ->
        Error.new(:recipient_conflict, :market_recipient_conflict)

      partial_recipient_fixation?(snapshot) ->
        Error.new(:inconsistent_state, :partial_recipient_fixation)

      true ->
        :ok
    end
  end

  defp partial_recipient_fixation?(snapshot) do
    has_fixed_recipient = not is_nil(snapshot.fixed_recipient)
    has_issuance_recipients = snapshot.issuance_recipients != []
    has_fixed_recipient != has_issuance_recipients
  end

  defp validate_history(snapshot) do
    cond do
      snapshot.issuance == nil and snapshot.holdings == [] and snapshot.quotes == [] ->
        {:ok, :unissued}

      snapshot.issuance == nil ->
        Error.new(:inconsistent_state, :orphan_history)

      not coherent_snapshot?(snapshot) ->
        Error.new(:inconsistent_state, :invalid_retained_evidence)

      true ->
        {:ok, :issued}
    end
  end

  defp coherent_snapshot?(snapshot) do
    issuance = snapshot.issuance

    initial_quote =
      Enum.find(snapshot.quotes, fn quote ->
        Map.get(quote, :id) == Map.get(issuance, :initial_quote_id)
      end)

    valid_issuance?(snapshot, issuance) and
      valid_holdings?(snapshot) and
      valid_quotes?(snapshot) and
      valid_initial_quote?(initial_quote, snapshot, issuance)
  end

  defp valid_issuance?(snapshot, issuance) do
    valid_issuance_identity?(snapshot, issuance) and
      Map.get(issuance, :player_id) == snapshot.player_id and
      Map.get(issuance, :recipient_id) == snapshot.recipient_id and
      Map.get(issuance, :quantity) === 100 and
      exact_one?(Map.get(issuance, :initial_unit_price)) and
      uuid?(Map.get(issuance, :initial_quote_id)) and
      utc_instant?(Map.get(issuance, :completed_at))
  end

  defp valid_issuance_identity?(snapshot, issuance) do
    uuid?(snapshot.player_id) and
      uuid?(snapshot.recipient_id) and
      snapshot.fixed_recipient == snapshot.recipient_id and
      snapshot.recipient_id in snapshot.user_ids and
      uuid?(Map.get(issuance, :id))
  end

  defp valid_initial_quote?(quote, snapshot, issuance) do
    is_map(quote) and
      Map.get(quote, :player_id) == snapshot.player_id and
      exact_one?(Map.get(quote, :unit_price)) and
      Map.get(quote, :rule_id) == "initial_issuance" and
      Map.get(quote, :rule_version) == "1" and
      Map.get(quote, :effective_at) == Map.get(issuance, :completed_at)
  end

  defp valid_holdings?(snapshot) do
    Enum.all?(snapshot.holdings, fn holding -> valid_holding?(holding, snapshot) end) and
      unique_by_field?(snapshot.holdings, :id) and
      unique_by_field?(snapshot.holdings, :user_id) and
      Enum.sum(Enum.map(snapshot.holdings, fn holding -> holding.quantity end)) == 100
  end

  defp valid_holding?(holding, snapshot) do
    is_map(holding) and
      uuid?(Map.get(holding, :id)) and
      Map.get(holding, :player_id) == snapshot.player_id and
      uuid?(Map.get(holding, :user_id)) and
      Map.get(holding, :user_id) in snapshot.user_ids and
      is_integer(Map.get(holding, :quantity)) and
      Map.get(holding, :quantity) >= 0
  end

  defp valid_quotes?(snapshot) do
    initial_quote_count =
      Enum.count(snapshot.quotes, fn quote -> Map.get(quote, :rule_id) == "initial_issuance" end)

    Enum.all?(snapshot.quotes, fn quote -> valid_quote?(quote, snapshot) end) and
      unique_by_field?(snapshot.quotes, :id) and
      initial_quote_count == 1
  end

  defp valid_quote?(quote, snapshot) do
    is_map(quote) and
      uuid?(Map.get(quote, :id)) and
      Map.get(quote, :player_id) == snapshot.player_id and
      positive_exact_decimal?(Map.get(quote, :unit_price)) and
      utc_instant?(Map.get(quote, :effective_at)) and
      utc_instant?(Map.get(quote, :inserted_at)) and
      non_empty_text?(Map.get(quote, :rule_id)) and
      non_empty_text?(Map.get(quote, :rule_version))
  end

  defp unique_by_field?(rows, key),
    do: length(rows) == length(Enum.uniq_by(rows, fn row -> Map.get(row, key) end))

  defp uuid?(id) when is_binary(id), do: match?({:ok, _}, Ecto.UUID.cast(id))
  defp uuid?(_), do: false

  defp utc_instant?(%DateTime{utc_offset: 0, std_offset: 0}), do: true
  defp utc_instant?(_), do: false

  defp non_empty_text?(text) when is_binary(text), do: String.trim(text) != ""
  defp non_empty_text?(_), do: false

  defp positive_exact_decimal?(%Decimal{coef: coefficient, sign: 1}) when is_integer(coefficient),
    do: coefficient > 0

  defp positive_exact_decimal?(_), do: false

  # --- Database Initialization & Queries ---

  def initialize(%{player_id: player_id, recipient_id: recipient_id}) do
    if Repo.in_transaction?() do
      Error.new(:invalid_input, :transaction_in_progress)
    else
      Settlement.safely(
        fn -> initialize_transaction(player_id, recipient_id) end,
        :storage_failure
      )
    end
  end

  def initialize_in_transaction(%{player_id: player_id, recipient_id: recipient_id}) do
    if Repo.in_transaction?(),
      do: initialize_locked(player_id, recipient_id),
      else: Error.new(:invalid_input, :transaction_required)
  end

  def get(player_id) do
    Settlement.safely(
      fn ->
        # One MVCC statement retrieves immutable linked original facts coherently.
        query =
          from player in Player,
            left_join: issuance in Issuance,
            on: issuance.player_id == player.id,
            left_join: quote in Quote,
            on: quote.id == issuance.initial_quote_id,
            where: player.id == ^player_id,
            select: {issuance, quote}

        case Repo.one(query) do
          nil -> Error.new(:player_not_found, :player_not_found)
          {nil, _} -> Error.new(:not_initialized, :not_initialized)
          {issuance, quote} when not is_nil(quote) -> {:ok, build_evidence(issuance, quote)}
          _ -> Error.new(:inconsistent_state, :missing_original_quote)
        end
      end,
      :storage_failure
    )
  end

  defp initialize_transaction(player_id, recipient_id),
    do: Repo.transaction(fn -> initialize_locked(player_id, recipient_id) end)

  defp initialize_locked(player_id, recipient_id) do
    lock_and_verify_preconditions!(player_id, recipient_id)
    snapshot = load_snapshot(player_id, recipient_id)

    has_conflicting_recipient =
      (snapshot.fixed_recipient != nil and snapshot.fixed_recipient != recipient_id) or
        Enum.any?(snapshot.issuance_recipients, fn existing -> existing != recipient_id end)

    if has_conflicting_recipient do
      rollback(:recipient_conflict, :market_recipient_conflict)
    end

    case validate_snapshot(snapshot) do
      {:ok, :unissued} ->
        persist_initial_issuance!(player_id, recipient_id, snapshot.fixed_recipient)

      {:ok, :issued} ->
        %{
          outcome: :already_completed,
          issuance: build_evidence(snapshot.issuance, find_original_quote(snapshot))
        }

      {:error, error} ->
        Repo.rollback(error)
    end
  end

  defp lock_and_verify_preconditions!(player_id, recipient_id) do
    if Repo.query!("SHOW transaction_isolation").rows != [["read committed"]],
      do: rollback(:invalid_input, :unsupported_isolation)

    # Lock order: singleton initialization lock -> player row -> recipient user row.
    if is_nil(Repo.one(from lock in InitializationLock, where: lock.id == 1, lock: "FOR UPDATE")),
      do: rollback(:storage_failure, :missing_initialization_lock)

    if is_nil(
         Repo.one(from player in Player, where: player.id == ^player_id, lock: "FOR UPDATE")
       ),
       do: rollback(:player_not_found, :player_not_found)

    if is_nil(
         Repo.one(from user in User, where: user.id == ^recipient_id, lock: "FOR KEY SHARE")
       ),
       do: rollback(:invalid_designation, :nonexistent_recipient)
  end

  defp persist_initial_issuance!(player_id, recipient_id, fixed_recipient) do
    now = Settlement.clock()

    if fixed_recipient == nil do
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

    %{outcome: :issued, issuance: build_evidence(issuance, opening_quote)}
  end

  defp load_snapshot(player_id, recipient_id) do
    fixed = Repo.get(InitialRecipient, 1)

    %{
      player_id: player_id,
      recipient_id: recipient_id,
      fixed_recipient: fixed && fixed.user_id,
      issuance_recipients: Repo.all(from issuance in Issuance, select: issuance.recipient_id),
      issuance: Repo.one(from issuance in Issuance, where: issuance.player_id == ^player_id),
      holdings: Repo.all(from holding in Holding, where: holding.player_id == ^player_id),
      quotes: Repo.all(from quote in Quote, where: quote.player_id == ^player_id),
      user_ids: Repo.all(from user in User, select: user.id)
    }
  end

  defp find_original_quote(snapshot) do
    Enum.find(snapshot.quotes, fn quote -> quote.id == snapshot.issuance.initial_quote_id end)
  end

  defp build_evidence(issuance, quote) do
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

  defp rollback(kind, reason) do
    {:error, error} = Error.new(kind, reason)
    Repo.rollback(error)
  end
end
