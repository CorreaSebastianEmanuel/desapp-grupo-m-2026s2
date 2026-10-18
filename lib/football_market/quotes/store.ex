defmodule FootballMarket.Quotes.Store do
  @moduledoc "Transactional persistence primitives for quote confirmation."
  import Ecto.Query
  alias FootballMarket.{Repo, Market.Quote}
  alias FootballMarket.Quotes.{Calculation, Evaluation}

  def lock_player!(player_id) do
    Repo.query!("SELECT id FROM players WHERE id=$1 FOR UPDATE", [Ecto.UUID.dump!(player_id)])
    :ok
  end

  def database_now! do
    Repo.query!("SELECT now()", []) |> then(fn %{rows: [[at]]} -> at end)
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

    Repo.insert!(%Evaluation{
      id: Ecto.UUID.generate(),
      quote_id: quote_id,
      calculation_id: calculation.id,
      player_id: player.id,
      idempotency_key: "quote-evaluation:" <> quote_id,
      state: "pending",
      inserted_at: effective_at
    })
  end
end
