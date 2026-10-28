defmodule FootballMarket.Market.OrderEvaluationStore do
  @moduledoc false
  import Ecto.Query
  alias FootballMarket.Repo
  alias FootballMarket.Market.{ConditionalOrderStore, OrderEvaluationMember, OrderEvaluationPass}

  def request_pass do
    ConditionalOrderStore.command(fn ->
      pass = lock!()
      if pass.state == "idle", do: capture!(pass), else: update!(pass, rescan_requested: true)
      :ok
    end)
  end

  def step do
    ConditionalOrderStore.command(fn ->
      pass = lock!()
      if pass.state == "idle", do: :idle, else: advance!(pass)
    end)
  end

  defp lock!, do: Repo.one!(from p in OrderEvaluationPass, where: p.id == 1, lock: "FOR UPDATE")

  defp capture!(pass) do
    generation = pass.generation + 1
    # The INSERT SELECT has one statement snapshot. Membership, not a moving
    # created_at boundary, is the durable ordering authority for the whole pass.
    Repo.query!(
      """
      INSERT INTO market_order_evaluation_members(pass_generation,ordinal,order_id,captured_created_at)
      SELECT $1, row_number() OVER (ORDER BY created_at,id), id, created_at
      FROM market_conditional_buy_orders WHERE status='pending'
      """,
      [generation]
    )

    high =
      Repo.one(
        from m in OrderEvaluationMember,
          join: o in FootballMarket.Market.ConditionalOrder,
          on: o.id == m.order_id,
          where: m.pass_generation == ^generation,
          order_by: [desc: m.ordinal],
          limit: 1,
          select: {o.created_at, o.id}
      )

    {at, id} = high || {nil, nil}

    update!(pass,
      state: if(high, do: "running", else: "idle"),
      generation: generation,
      started_at: ConditionalOrderStore.clock(),
      cursor_ordinal: 0,
      upper_created_at: at,
      upper_order_id: id,
      rescan_requested: false
    )
  end

  defp advance!(pass) do
    member =
      Repo.one(
        from m in OrderEvaluationMember,
          where: m.pass_generation == ^pass.generation and m.ordinal > ^pass.cursor_ordinal,
          order_by: m.ordinal,
          limit: 1
      )

    case member do
      nil ->
        complete!(pass)

      member ->
        result = ConditionalOrderStore.evaluate_in_transaction!(member.order_id)
        update!(pass, cursor_ordinal: member.ordinal)
        {:decided, result}
    end
  end

  defp complete!(pass) do
    Repo.delete_all(from m in OrderEvaluationMember, where: m.pass_generation == ^pass.generation)

    idle =
      update!(pass, state: "idle", cursor_ordinal: 0, upper_created_at: nil, upper_order_id: nil)

    if pass.rescan_requested do
      capture!(idle)
      :rescan
    else
      :idle
    end
  end

  # The continuation is committed under the same singleton lock as the state
  # inspection. A crash before it is repaired by the periodic/startup sweep.
  def continue do
    ConditionalOrderStore.command(fn ->
      pass = lock!()

      if pass.state == "running",
        do: FootballMarket.Market.OrderEvaluation.enqueue!(%{"source" => "continuation"})

      :ok
    end)
  end

  defp update!(pass, attrs),
    do:
      pass
      |> Ecto.Changeset.change(Keyword.put(attrs, :updated_at, ConditionalOrderStore.clock()))
      |> Repo.update!()
end
