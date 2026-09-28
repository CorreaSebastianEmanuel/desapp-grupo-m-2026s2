defmodule FootballMarket.Catalog.PlayerCatalogIndexTest do
  use FootballMarket.DataCase, async: false

  test "catalog ordering index exists with the normalized expression" do
    %{rows: [[definition]]} =
      Ecto.Adapters.SQL.query!(
        FootballMarket.Repo,
        "SELECT indexdef FROM pg_indexes WHERE indexname = 'players_catalog_order_index'"
      )

    assert definition =~ "lower(btrim(display_name))"
    assert definition =~ "id"
  end

  test "PostgreSQL can use the catalog ordering index for a bounded seek" do
    Ecto.Adapters.SQL.query!(FootballMarket.Repo, "SET LOCAL enable_seqscan = off")

    %{rows: rows} =
      Ecto.Adapters.SQL.query!(
        FootballMarket.Repo,
        "EXPLAIN SELECT id FROM players ORDER BY lower(btrim(display_name)), id LIMIT 26"
      )

    assert rows |> List.flatten() |> Enum.join("\n") =~ "players_catalog_order_index"
  end
end
