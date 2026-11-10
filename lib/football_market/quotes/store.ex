defmodule FootballMarket.Quotes.Store do
  @moduledoc "Transactional persistence primitives for quote confirmation."
  import Ecto.Query
  alias FootballMarket.{Repo, Market.Quote}
  alias FootballMarket.Catalog.Player
  alias FootballMarket.Quotes.{Calculation, Evaluation}

  def lock_player!(player_id) do
    Repo.query!("SELECT id FROM players WHERE id=$1 FOR UPDATE", [Ecto.UUID.dump!(player_id)])
    :ok
  end

  def database_now! do
    Repo.query!("SELECT now()", []) |> then(fn %{rows: [[at]]} -> at end)
  end

  def database_clock_now! do
    Repo.query!("SELECT clock_timestamp()", []) |> then(fn %{rows: [[at]]} -> at end)
  end

  def confirm!(%Calculation{} = calculation, player, managed, mapping, price, effective_at) do
    sequence =
      Repo.one(
        from q in Quote, where: q.player_id == ^player.id, select: max(q.performance_sequence)
      ) || 0

    quote_id = Ecto.UUID.generate()

    quote = %Quote{
      id: quote_id,
      player_id: player.id,
      unit_price: price,
      effective_at: effective_at,
      inserted_at: effective_at,
      rule_id: managed.strategy_id,
      rule_version: managed.formula_version,
      calculation_id: calculation.id,
      configuration_version_id: managed.configuration_version_id,
      mapping_id: mapping.id,
      performance_sequence: sequence + 1
    }

    Repo.insert!(Quote.changeset(quote, Map.from_struct(quote)))

    event =
      Repo.insert!(%Evaluation{
        id: Ecto.UUID.generate(),
        quote_id: quote_id,
        calculation_id: calculation.id,
        player_id: player.id,
        idempotency_key: "quote-evaluation:" <> quote_id,
        state: "pending",
        inserted_at: effective_at
      })

    FootballMarket.Market.OrderEvaluation.enqueue!(%{"source" => "quote", "event_id" => event.id})
    event
  end

  def initialized_player(player_id, season_id) do
    case Repo.get(Player, player_id) do
      %Player{season_id: ^season_id} = player ->
        if Repo.exists?(
             from q in Quote, where: q.player_id == ^player.id and q.rule_id == "initial_issuance"
           ), do: {:ok, player}, else: {:error, :player_not_initialized}

      _ ->
        {:error, :player_not_found}
    end
  end

  def ensure_confirmation_lease!(nil), do: :ok

  def ensure_confirmation_lease!({request_id, fence}) do
    request =
      Repo.one(
        from r in FootballMarket.Quotes.CalculationRequest,
          where: r.id == ^request_id,
          lock: "FOR UPDATE"
      )

    # `now()` is fixed at transaction start. This confirmation may have waited
    # for the player lock, so check lease expiry against the current DB clock.
    now = database_clock_now!()

    if request && request.state == "running" && request.lease_fence == fence &&
         request.lease_until && DateTime.compare(request.lease_until, now) == :gt do
      request
    else
      Repo.rollback(:stale_fence)
    end
  end
end
