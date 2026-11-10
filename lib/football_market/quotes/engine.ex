defmodule FootballMarket.Quotes.Engine do
  @moduledoc "Valuation and atomic quote confirmation; owns the player-before-request lock order."
  import Ecto.Query
  alias FootballMarket.{Repo, Valuation}
  alias FootballMarket.Quotes.{Mappings, Store}

  alias FootballMarket.Quotes.{Calculation, Result}

  def request_membership(
        subject_week,
        selector,
        mapping_id,
        facts,
        request_id,
        lease \\ nil,
        identity_context \\ %{}
      ) do
    with {:ok, subject} <- Valuation.Request.subject_week(subject_week),
         {:ok, request_id} <- Ecto.UUID.cast(request_id),
         {:ok, mapping} <- Mappings.get(mapping_id),
         {:ok, player} <- Store.initialized_player(subject.player_id, subject.season_id) do
      evaluate_and_persist(
        subject,
        player,
        selector,
        mapping,
        request_id,
        facts,
        lease,
        identity_context
      )
    end
  rescue
    _ -> {:error, :temporarily_unavailable}
  end

  def evaluate_and_persist(
        subject,
        player,
        selector,
        mapping,
        request_id,
        facts,
        lease \\ nil,
        identity_context \\ %{}
      ) do
    case Valuation.evaluate_managed_membership(subject, selector, facts) do
      {:ok, managed} ->
        with {:ok, result} <- Result.outcome(managed.score, mapping.scale),
             do:
               persist(
                 subject,
                 player,
                 managed,
                 mapping,
                 request_id,
                 result,
                 lease,
                 identity_context
               )

      {:error, %Valuation.Error{} = error} ->
        with {:ok, configuration_id} <- configuration_id(selector),
             {:ok, status, reason} <- Result.safe_failure(error) do
          persist_no_score(subject, player, %{
            configuration_id: configuration_id,
            mapping: mapping,
            request_id: request_id,
            facts: facts,
            status: status,
            reason: reason,
            lease: lease,
            identity_context: identity_context
          })
        end

      _ ->
        {:error, :calculation_unavailable}
    end
  end

  defp configuration_id({:version, id}) do
    case Ecto.UUID.cast(id) do
      {:ok, normalized} -> {:ok, normalized}
      _ -> {:error, :configuration_unavailable}
    end
  end

  defp configuration_id(_), do: {:error, :configuration_unavailable}

  defp persist(
         subject,
         player,
         managed,
         mapping,
         request_id,
         outcome,
         lease,
         identity_context
       ) do
    version_id = managed.configuration_version_id
    facts = managed.prepared.facts
    ids = Enum.map(facts, & &1.performance_id)

    identity =
      %{
        "player_id" => player.id,
        "season_id" => subject.season_id,
        "week_start" => DateTime.to_iso8601(subject.week_start),
        "week_end" => DateTime.to_iso8601(subject.week_end),
        "membership" => ids,
        "configuration_version_id" => version_id,
        "mapping_id" => mapping.id
      }
      |> Map.merge(identity_context)

    reject_nested_confirmation!()

    context = %{
      identity: identity,
      subject: subject,
      player: player,
      managed: managed,
      mapping: mapping,
      request_id: request_id,
      outcome: outcome,
      lease: lease,
      version_id: version_id,
      ids: ids
    }

    Repo.transaction(fn -> persist_calculation(context) end)
    |> persist_result(request_id)
  end

  defp persist_calculation(context) do
    Store.lock_player!(context.player.id)
    Store.ensure_confirmation_lease!(context.lease)

    case Repo.one(from c in Calculation, where: c.canonical_identity == ^context.identity) do
      %Calculation{} = existing -> existing
      nil -> insert_calculation(context)
    end
  end

  defp insert_calculation(context) do
    now = Store.database_clock_now!()
    outcome = context.outcome

    calculation = %Calculation{
      id: Ecto.UUID.generate(),
      player_id: context.player.id,
      season_id: context.subject.season_id,
      week_start: context.subject.week_start,
      week_end: context.subject.week_end,
      configuration_version_id: context.version_id,
      mapping_id: context.mapping.id,
      membership: context.ids,
      status: outcome.status,
      reason: outcome.reason,
      score: outcome.score,
      unit_price: outcome.price,
      effective_at: if(outcome.status == "successful", do: now),
      canonical_identity: context.identity,
      evidence: evidence(context.managed, context.mapping, outcome.score),
      inserted_at: now
    }

    Repo.insert!(calculation)
    confirm_successful_calculation(calculation, context, now)
    calculation
  end

  defp confirm_successful_calculation(%{status: "successful"} = calculation, context, now) do
    Store.confirm!(
      calculation,
      context.player,
      context.managed,
      context.mapping,
      context.outcome.price,
      now
    )
  end

  defp confirm_successful_calculation(_calculation, _context, _now), do: :ok

  defp persist_result({:ok, calculation}, request_id),
    do: {:ok, %{request_id: request_id, calculation: calculation}}

  defp persist_result({:error, error}, _request_id), do: {:error, error}

  defp reject_nested_confirmation! do
    if Repo.in_transaction?(), do: raise(ArgumentError, "caller transaction not allowed")
  end

  defp persist_no_score(subject, player, attributes) do
    reject_nested_confirmation!()

    case Valuation.Configurations.get(attributes.configuration_id) do
      {:ok, %{version: version}} ->
        persist_no_score_version(subject, player, attributes, version)

      _ ->
        {:error, :configuration_unavailable}
    end
  rescue
    _ -> {:error, :temporarily_unavailable}
  end

  defp persist_no_score_version(subject, player, attributes, version) do
    attributes = Map.update!(attributes, :facts, &Valuation.Preparation.canonical_order/1)
    membership = Enum.map(attributes.facts, & &1.performance_id)

    identity =
      %{
        "player_id" => player.id,
        "season_id" => subject.season_id,
        "week_start" => DateTime.to_iso8601(subject.week_start),
        "week_end" => DateTime.to_iso8601(subject.week_end),
        "membership" => membership,
        "configuration_version_id" => version.id,
        "mapping_id" => attributes.mapping.id
      }
      |> Map.merge(Map.get(attributes, :identity_context, %{}))

    context = %{
      identity: identity,
      subject: subject,
      player: player,
      attributes: attributes,
      version: version,
      membership: membership
    }

    Repo.transaction(fn -> persist_no_score_calculation(context) end)
    |> persist_result(attributes.request_id)
  end

  defp persist_no_score_calculation(context) do
    Store.lock_player!(context.player.id)
    Store.ensure_confirmation_lease!(context.attributes.lease)

    case Repo.one(from c in Calculation, where: c.canonical_identity == ^context.identity) do
      %Calculation{} = existing -> existing
      nil -> insert_no_score_calculation(context)
    end
  end

  defp insert_no_score_calculation(context) do
    now = Store.database_clock_now!()
    attributes = context.attributes
    mapping = attributes.mapping
    version = context.version

    calculation = %Calculation{
      id: Ecto.UUID.generate(),
      player_id: context.player.id,
      season_id: context.subject.season_id,
      week_start: context.subject.week_start,
      week_end: context.subject.week_end,
      configuration_version_id: version.id,
      mapping_id: mapping.id,
      membership: context.membership,
      canonical_identity: context.identity,
      status: attributes.status,
      reason: attributes.reason,
      score: nil,
      unit_price: nil,
      effective_at: now,
      evidence: no_score_evidence(attributes.facts, version, mapping),
      inserted_at: now
    }

    Repo.insert!(calculation)
  end

  defp no_score_evidence(facts, version, mapping) do
    %{
      "schema_version" => 1,
      "configuration_version_id" => version.id,
      "strategy_id" => version.strategy_id,
      "formula_version" => version.formula_version,
      "mapping_id" => mapping.id,
      "mapping_name" => mapping.name,
      "mapping_version" => mapping.version,
      "scale" => Decimal.to_string(mapping.scale),
      "rounding_rule" => mapping.rounding_rule,
      "facts" => FootballMarket.Quotes.EvidenceCodec.encode_facts(facts)
    }
  end

  defp evidence(managed, mapping, score) do
    %{
      "schema_version" => 1,
      "configuration_version_id" => managed.configuration_version_id,
      "strategy_id" => managed.strategy_id,
      "formula_version" => managed.formula_version,
      "mapping_id" => mapping.id,
      "mapping_name" => mapping.name,
      "mapping_version" => mapping.version,
      "scale" => Decimal.to_string(mapping.scale),
      "rounding_rule" => mapping.rounding_rule,
      "score" => if(is_nil(score), do: nil, else: Decimal.to_string(score)),
      "facts" => FootballMarket.Quotes.EvidenceCodec.encode_facts(managed.prepared.facts)
    }
  end
end
