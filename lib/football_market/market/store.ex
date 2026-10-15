defmodule FootballMarket.Market.Store do
  @moduledoc false
  import Ecto.Query
  alias FootballMarket.Repo
  alias FootballMarket.Catalog.Player
  alias FootballMarket.Accounts.User

  alias FootballMarket.Market.{
    Error,
    Consistency,
    InitializationLock,
    InitialRecipient,
    Holding,
    Quote,
    Issuance
  }

  def initialize(%{player_id: player, recipient_id: recipient}) do
    if Repo.in_transaction?() do
      Error.new(:invalid_input, :transaction_in_progress)
    else
      safely(fn ->
        Repo.transaction(fn ->
          if Repo.query!("SHOW transaction_isolation").rows != [["read committed"]],
            do: rollback(:invalid_input, :unsupported_isolation)

          if is_nil(Repo.one(from l in InitializationLock, where: l.id == 1, lock: "FOR UPDATE")),
            do: rollback(:storage_failure, :missing_initialization_lock)

          if is_nil(Repo.one(from p in Player, where: p.id == ^player, lock: "FOR UPDATE")),
            do: rollback(:player_not_found, :player_not_found)

          if is_nil(Repo.one(from u in User, where: u.id == ^recipient, lock: "FOR KEY SHARE")),
            do: rollback(:invalid_designation, :nonexistent_recipient)

          state = snapshot(player, recipient)

          if (state.fixed_recipient != nil and state.fixed_recipient != recipient) or
               Enum.any?(state.issuance_recipients, &(&1 != recipient)),
             do: rollback(:recipient_conflict, :market_recipient_conflict)

          case Consistency.validate(state) do
            {:ok, :unissued} ->
              issue(player, recipient, state.fixed_recipient)

            {:ok, :issued} ->
              %{
                outcome: :already_completed,
                issuance: evidence(state.issuance, original_quote(state))
              }

            {:error, error} ->
              Repo.rollback(error)
          end
        end)
      end)
    end
  end

  defp issue(player, recipient, fixed) do
    [[instant]] = Repo.query!("SELECT clock_timestamp() AT TIME ZONE 'UTC'").rows
    now = DateTime.from_naive!(instant, "Etc/UTC")
    if fixed == nil, do: Repo.insert!(%InitialRecipient{id: 1, user_id: recipient, fixed_at: now})

    quote =
      Repo.insert!(%Quote{
        player_id: player,
        unit_price: Decimal.new(1),
        effective_at: now,
        inserted_at: now,
        rule_id: "initial_issuance",
        rule_version: "1"
      })

    Repo.insert!(%Holding{player_id: player, user_id: recipient, quantity: 100})

    issuance =
      Repo.insert!(%Issuance{
        player_id: player,
        recipient_id: recipient,
        quantity: 100,
        initial_unit_price: Decimal.new(1),
        initial_quote_id: quote.id,
        completed_at: now
      })

    %{outcome: :issued, issuance: evidence(issuance, quote)}
  end

  defp snapshot(player, recipient) do
    fixed = Repo.get(InitialRecipient, 1)

    %{
      player_id: player,
      recipient_id: recipient,
      fixed_recipient: fixed && fixed.user_id,
      issuance_recipients: Repo.all(from i in Issuance, select: i.recipient_id),
      issuance: Repo.one(from i in Issuance, where: i.player_id == ^player),
      holdings: Repo.all(from h in Holding, where: h.player_id == ^player),
      quotes: Repo.all(from q in Quote, where: q.player_id == ^player),
      user_ids: Repo.all(from u in User, select: u.id)
    }
  end

  defp original_quote(state),
    do: Enum.find(state.quotes, &(&1.id == state.issuance.initial_quote_id))

  def get(player) do
    safely(fn ->
      # One MVCC statement retrieves immutable linked original facts coherently.
      case Repo.one(
             from p in Player,
               left_join: i in Issuance,
               on: i.player_id == p.id,
               left_join: q in Quote,
               on: q.id == i.initial_quote_id,
               where: p.id == ^player,
               select: {i, q}
           ) do
        nil -> Error.new(:player_not_found, :player_not_found)
        {nil, _} -> Error.new(:not_initialized, :not_initialized)
        {i, q} when not is_nil(q) -> {:ok, evidence(i, q)}
        _ -> Error.new(:inconsistent_state, :missing_original_quote)
      end
    end)
  end

  defp evidence(i, q) do
    %{
      id: i.id,
      player_id: i.player_id,
      recipient_id: i.recipient_id,
      quantity: i.quantity,
      initial_unit_price: i.initial_unit_price,
      initial_quote_id: i.initial_quote_id,
      initial_inventory_value: Decimal.mult(i.initial_unit_price, Decimal.new(i.quantity)),
      effective_at: q.effective_at,
      rule_id: q.rule_id,
      rule_version: q.rule_version,
      completed_at: i.completed_at
    }
  end

  defp rollback(kind, reason) do
    {:error, error} = Error.new(kind, reason)
    Repo.rollback(error)
  end

  defp safely(fun) do
    fun.()
  rescue
    _error in [
      Postgrex.Error,
      DBConnection.ConnectionError,
      Ecto.ConstraintError,
      Ecto.InvalidChangesetError
    ] ->
      Error.new(:storage_failure, :storage_rejected)
  end
end
