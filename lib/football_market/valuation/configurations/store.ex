defmodule FootballMarket.Valuation.Configurations.Store do
  @moduledoc false
  import Ecto.Query
  alias FootballMarket.Repo
  alias FootballMarket.Catalog.Position
  alias FootballMarket.Valuation.Error
  alias FootballMarket.Valuation.Configurations.Presets

  alias FootballMarket.Valuation.Configurations.{
    Rules,
    Codec,
    Version,
    SelectionLock,
    SelectionChange,
    Registry
  }

  def create(input) do
    with {:ok, r} <- Rules.validate(input) do
      Repo.transaction(fn ->
        create_locked(r)
      end)
    end
  end

  def ensure_presets do
    Repo.transaction(fn ->
      Repo.one!(from l in SelectionLock, where: l.id == 1, lock: "FOR UPDATE")

      Enum.each(
        [{"GK", "Goalkeeper"}, {"DEF", "Defender"}, {"MID", "Midfielder"}, {"FWD", "Forward"}],
        &ensure_position/1
      )

      preset_versions_locked()
    end)
  end

  defp ensure_position({code, name}) do
    case FootballMarket.Catalog.get_position_by_code(code) do
      {:ok, _} -> :ok
      {:error, :not_found} -> create_position(code, name)
    end
  end

  defp create_position(code, name) do
    case FootballMarket.Catalog.create_position(%{code: code, name: name}) do
      {:ok, _} -> :ok
      {:error, _} -> Repo.rollback(:missing_standard_positions)
    end
  end

  def provision_presets do
    Repo.transaction(fn ->
      Repo.one!(from l in SelectionLock, where: l.id == 1, lock: "FOR UPDATE")
      preset_versions_locked()
    end)
  end

  defp preset_versions_locked do
    positions =
      Repo.all(
        from p in Position,
          where: fragment("upper(btrim(?))", p.code) in ^Map.keys(Presets.roles()),
          lock: "FOR KEY SHARE"
      )

    if length(positions) != 4, do: Repo.rollback(:missing_standard_positions)
    mapping = Enum.map(positions, &{&1.id, Presets.roles()[String.upcase(String.trim(&1.code))]})
    Enum.map(Presets.families(), &provision_preset!(&1, mapping))
  end

  defp provision_preset!(family, mapping) do
    key = Presets.key(family, mapping)
    existing = Repo.one(from p in "valuation_presets", where: p.key == ^key, select: p.version_id)

    if existing do
      {:ok, %{version: version}} = get(uuid(existing))
      version
    else
      {:ok, rules} = Rules.validate(Presets.rules(family, mapping))
      version = create_locked(rules)
      Repo.insert_all("valuation_presets", [%{key: key, version_id: Ecto.UUID.dump!(version.id)}])
      %{version | preset_key: key}
    end
  end

  # One statement includes the anchor even for an empty version set. MVCC fixes
  # the versions and latest committed selection to the same snapshot.
  defp snapshot(filter) do
    rows =
      Repo.all(
        from l in SelectionLock,
          left_join: v in Version,
          on: ^filter,
          where: l.id == 1,
          order_by: [asc: v.created_at, asc: v.id],
          select:
            {v,
             fragment("(SELECT key FROM valuation_presets WHERE version_id = ? LIMIT 1)", v.id),
             fragment(
               "(SELECT new_version_id FROM valuation_selection_changes ORDER BY change_order DESC LIMIT 1)"
             )}
      )

    case rows do
      [] ->
        raise "valuation serialization anchor missing"

      [{_, _, active} | _] ->
        {for({v, preset, _} <- rows, v != nil, do: %{decode(v) | preset_key: preset}),
         uuid(active)}
    end
  end

  def list do
    {versions, active} = snapshot(dynamic([_l, _v], true))
    {:ok, %{versions: versions, active_version_id: active}}
  end

  def get(id) do
    with {:ok, id} <- identifier(id) do
      case snapshot(dynamic([_l, v], v.id == ^id)) do
        {[], _} -> Error.new(:not_found, :configuration_not_found)
        {[version], active} -> {:ok, %{version: version, active_version_id: active}}
      end
    end
  end

  def active do
    case snapshot(
           dynamic(
             [_l, v],
             v.id ==
               fragment(
                 "(SELECT new_version_id FROM valuation_selection_changes ORDER BY change_order DESC LIMIT 1)"
               )
           )
         ) do
      {[], nil} -> Error.new(:no_active_configuration, :no_active_configuration)
      {[version], _} -> {:ok, version}
      _ -> raise "valuation selection integrity failure"
    end
  end

  def history, do: {:ok, Repo.all(from c in SelectionChange, order_by: c.change_order)}

  def activate(target, expected) do
    with {:ok, target} <- identifier(target), {:ok, expected} <- expectation(expected) do
      Repo.transaction(fn ->
        activate_locked(target, expected)
      end)
    end
  end

  defp expectation(nil), do: {:ok, nil}
  defp expectation(id), do: identifier(id)

  def identifier(id) when is_binary(id) do
    case Ecto.UUID.cast(id) do
      {:ok, id} -> {:ok, id}
      _ -> Error.new(:validation, :invalid_configuration_identity)
    end
  end

  def identifier(_), do: Error.new(:validation, :invalid_configuration_identity)

  defp uuid(nil), do: nil
  defp uuid(raw) when byte_size(raw) == 16, do: Ecto.UUID.load!(raw)
  defp uuid(raw), do: raw

  defp decode(v) do
    case Codec.decode(v.rules) do
      {:ok, r} -> struct!(v, r)
      {:error, :invalid_stored_rules} -> raise "valuation rule storage integrity failure"
    end
  end

  defp rollback(kind, reason) do
    {:error, error} = Error.new(kind, reason)
    Repo.rollback(error)
  end

  defp create_locked(r) do
    ids = Enum.map(r.position_mapping, &elem(&1, 0))

    found =
      Repo.all(from p in Position, where: p.id in ^ids, select: p.id, lock: "FOR KEY SHARE")

    if Enum.sort(found) != Enum.sort(ids), do: rollback(:validation, :unknown_position)

    %Version{
      strategy_id: r.strategy_id,
      formula_version: r.formula_version,
      rules: Codec.encode(r)
    }
    |> Repo.insert!()
    |> decode()
  end

  defp activate_locked(target, expected) do
    Repo.one!(from l in SelectionLock, where: l.id == 1, lock: "FOR UPDATE")
    current = Repo.one(from c in SelectionChange, order_by: [desc: c.change_order], limit: 1)
    current_id = current && current.new_version_id
    if expected != current_id, do: rollback(:conflict, :stale_selection)

    version =
      case get(target) do
        {:ok, %{version: v}} -> v
        {:error, error} -> Repo.rollback(error)
      end

    case Registry.resolve(version.strategy_id, version.formula_version) do
      {:ok, _} -> :ok
      {:error, error} -> Repo.rollback(error)
    end

    change =
      if target != current_id do
        Repo.insert!(%SelectionChange{
          previous_version_id: current_id,
          new_version_id: target
        })
      end

    %{active_version_id: target, change: change}
  end
end
