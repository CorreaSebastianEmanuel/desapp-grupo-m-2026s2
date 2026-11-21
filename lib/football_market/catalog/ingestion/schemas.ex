defmodule FootballMarket.Catalog.Ingestion.Outcome do
  @moduledoc "Safe internal reconciliation result; counts always refer to incoming entities."
  defstruct [
    :status,
    :scope,
    :provider,
    :fixture_id,
    :acceptance_reference,
    :revision,
    :retrieved_at,
    :accepted_at,
    :counts,
    :applied_counts,
    :reason,
    :recovery,
    :provider_error,
    :new_bindings_count,
    :applied_new_bindings_count,
    counts_historical: false
  ]

  def failure(status, scope, reason) do
    recovery =
      case status do
        :stale_observation -> :new_retrieval
        :reconciliation_conflict -> :correct_facts_or_instructions
        :concurrent_change -> :retry_new_attempt
        :persistence_failure -> :caller_may_retry
      end

    {:error, %__MODULE__{status: status, scope: scope, reason: reason, recovery: recovery}}
  end
end

defmodule FootballMarket.Catalog.Ingestion.DeliveryReceipt do
  @moduledoc "Neutral fenced publication receipt, confirmed inside the domain transaction."
  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "catalog_delivery_receipts" do
    field :operation, :string, default: "catalog"
    field :fence, :binary_id
    field :run_id, :binary_id
    field :league_code, :string
    field :start_year, :integer
    field :end_year, :integer
    field :state, :string
    field :outcome, :map
    field :confirmed_at, :utc_datetime_usec
  end

  defdelegate lock!(context, scope), to: FootballMarket.Synchronization.DeliveryReceipt
  defdelegate lock!(context, scope, operation), to: FootballMarket.Synchronization.DeliveryReceipt
  defdelegate confirm!(receipt, outcome), to: FootballMarket.Synchronization.DeliveryReceipt
end

defmodule FootballMarket.Catalog.Ingestion.Scope do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "catalog_ingestion_scopes" do
    field :league_code, :string
    field :start_year, :integer
    field :end_year, :integer
    field :league_id, :binary_id
    field :season_id, :binary_id
    field :revision, :integer
    field :latest_observation_id, :binary_id
  end

  def changeset(row, attrs) do
    row
    |> cast(attrs, [
      :league_code,
      :start_year,
      :end_year,
      :league_id,
      :season_id,
      :revision,
      :latest_observation_id
    ])
    |> validate_required([
      :league_code,
      :start_year,
      :end_year,
      :league_id,
      :season_id,
      :revision,
      :latest_observation_id
    ])
    |> validate_number(:revision, greater_than: 0)
    |> validate_inclusion(:league_code, Map.keys(FootballMarket.Providers.Request.leagues()))
  end
end

defmodule FootballMarket.Catalog.Ingestion.SourceBinding do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "catalog_source_bindings" do
    field :scope_id, :binary_id
    field :season_scope_id, :binary_id
    field :league_scope_id, :binary_id
    field :provider, :string
    field :kind, :string
    field :source_id, :string
    field :league_id, :binary_id
    field :season_id, :binary_id
    field :team_id, :binary_id
    field :player_id, :binary_id
  end

  def changeset(row, attrs) do
    row
    |> cast(attrs, [
      :scope_id,
      :season_scope_id,
      :league_scope_id,
      :provider,
      :kind,
      :source_id,
      :league_id,
      :season_id,
      :team_id,
      :player_id
    ])
    |> validate_required([
      :scope_id,
      :season_scope_id,
      :league_scope_id,
      :provider,
      :kind,
      :source_id
    ])
    |> validate_inclusion(:kind, ~w(league season team player))
    |> validate_target()
    |> immutable(row)
  end

  defp validate_target(cs) do
    fields = [:league_id, :season_id, :team_id, :player_id]
    active = Enum.filter(fields, &(not is_nil(get_field(cs, &1))))
    kind = get_field(cs, :kind)

    if kind in ~w(league season team player) and
         active == [String.to_existing_atom(kind <> "_id")],
       do: cs,
       else: add_error(cs, :kind, "requires exactly its typed target")
  end

  defp immutable(cs, %{__meta__: %{state: :built}}), do: cs
  defp immutable(cs, _), do: add_error(cs, :id, "source correspondences are immutable")
end

defmodule FootballMarket.Catalog.Ingestion.Observation do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "catalog_ingestion_observations" do
    field :scope_id, :binary_id
    field :revision, :integer
    field :operation, :string
    field :provider, :string
    field :retrieved_at, :utc_datetime_usec
    field :accepted_at, :utc_datetime_usec
    field :fixture_id, :string
    field :canonical_version, :integer
    field :delivery_digest, :binary
    field :canonical_delivery, :map
    field :counts, :map
  end

  def changeset(row, attrs) do
    row
    |> cast(attrs, [
      :scope_id,
      :revision,
      :operation,
      :provider,
      :retrieved_at,
      :accepted_at,
      :fixture_id,
      :canonical_version,
      :delivery_digest,
      :canonical_delivery,
      :counts
    ])
    |> validate_required([
      :scope_id,
      :revision,
      :operation,
      :provider,
      :retrieved_at,
      :accepted_at,
      :canonical_version,
      :delivery_digest,
      :canonical_delivery,
      :counts
    ])
    |> validate_number(:revision, greater_than: 0)
    |> validate_inclusion(:operation, ["catalog"])
    |> validate_inclusion(:canonical_version, [1])
    |> validate_change(:delivery_digest, fn :delivery_digest, value ->
      if byte_size(value) == 32, do: [], else: [delivery_digest: "must be SHA-256"]
    end)
    |> validate_change(:canonical_delivery, fn :canonical_delivery, value ->
      if match?(%{"v1" => [_ | _]}, value) and map_size(value) == 1 and length(value["v1"]) == 11,
        do: [],
        else: [canonical_delivery: "must be versioned resolved facts"]
    end)
    |> validate_change(:counts, fn :counts, value ->
      validate_counts(value)
    end)
    |> immutable(row)
  end

  defp immutable(cs, %{__meta__: %{state: :built}}), do: cs
  defp immutable(cs, _), do: add_error(cs, :id, "accepted observations are immutable")

  defp validate_counts(value) do
    valid =
      Enum.sort(Map.keys(value)) == ~w(league player season team) and
        Enum.all?(value, fn {_, counts} ->
          is_map(counts) and Enum.sort(Map.keys(counts)) == ~w(created unchanged updated) and
            Enum.all?(Map.values(counts), &(is_integer(&1) and &1 >= 0))
        end)

    if valid, do: [], else: [counts: "must have nonnegative per-kind counts"]
  end
end

defmodule FootballMarket.Catalog.Ingestion.ObservationBinding do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key false
  schema "catalog_ingestion_observation_bindings" do
    field :observation_id, :binary_id, primary_key: true
    field :binding_id, :binary_id, primary_key: true
    field :scope_id, :binary_id
  end

  def changeset(row, attrs) do
    row
    |> cast(attrs, [:observation_id, :binding_id, :scope_id])
    |> validate_required([:observation_id, :binding_id, :scope_id])
    |> immutable(row)
  end

  defp immutable(cs, %{__meta__: %{state: :built}}), do: cs
  defp immutable(cs, _), do: add_error(cs, :observation_id, "observation membership is immutable")
end
