defmodule FootballMarket.ArchitectureBoundariesTest do
  use ExUnit.Case, async: true

  @moduletag :unit

  @forbidden %{
    web: [
      ["FootballMarket", "Repo"],
      ["FootballMarket", "Providers"],
      ["FootballMarket", "Workers"],
      ["FootballMarket", "Ranking", "Cache"],
      ["Ecto", "Query"],
      ["Ecto", "Schema"],
      ["Ecto", "Changeset"],
      ["Ecto", "Repo"],
      ["Ecto", "Multi"],
      ["Ecto", "Adapters"],
      ["Redix"],
      ["Oban"]
    ],
    domain: [["FootballMarketWeb"]],
    workers: [
      ["FootballMarket", "Repo"],
      ["FootballMarket", "Providers"],
      ["FootballMarket", "Ranking", "Cache"],
      ["FootballMarketWeb"],
      ["Ecto", "Query"],
      ["Ecto", "Schema"],
      ["Ecto", "Changeset"],
      ["Ecto", "Repo"],
      ["Ecto", "Multi"],
      ["Ecto", "Adapters"],
      ["Redix"]
    ],
    providers: [
      ["FootballMarket", "Accounts"],
      ["FootballMarket", "Catalog"],
      ["FootballMarket", "Market"],
      ["FootballMarket", "Quotes"],
      ["FootballMarket", "Ranking"],
      ["FootballMarket", "Repo"],
      ["FootballMarket", "Statistics"],
      ["FootballMarket", "Sync"],
      ["FootballMarket", "Valuation"],
      ["FootballMarket", "Workers"],
      ["FootballMarketWeb"],
      ["Ecto", "Query"],
      ["Ecto", "Schema"],
      ["Ecto", "Changeset"],
      ["Ecto", "Repo"],
      ["Ecto", "Multi"],
      ["Ecto", "Adapters"]
    ],
    cache: [
      ["FootballMarket", "Repo"],
      ["FootballMarket", "Providers"],
      ["FootballMarket", "Workers"],
      ["FootballMarketWeb"],
      ["Ecto", "Query"],
      ["Ecto", "Schema"],
      ["Ecto", "Changeset"],
      ["Ecto", "Repo"],
      ["Ecto", "Multi"],
      ["Ecto", "Adapters"]
    ]
  }

  test "application source keeps the established layer dependencies" do
    violations =
      [
        {:web, ["lib/football_market_web.ex" | Path.wildcard("lib/football_market_web/**/*.ex")]},
        {:domain,
         Path.wildcard("lib/football_market/**/*.ex") --
           [
             "lib/football_market/application.ex",
             "lib/football_market/observability.ex",
             "lib/football_market/workers.ex",
             "lib/football_market/providers.ex",
             "lib/football_market/ranking/cache.ex",
             "lib/football_market/repo.ex"
           ]},
        {:workers, ["lib/football_market/workers.ex"]},
        {:providers, ["lib/football_market/providers.ex"]},
        {:cache, ["lib/football_market/ranking/cache.ex"]}
      ]
      |> Enum.flat_map(fn {layer, paths} ->
        Enum.flat_map(paths, fn path ->
          path
          |> File.read!()
          |> violations(layer, path)
        end)
      end)

    assert violations == []
  end

  test "each layer rule rejects imports, aliases, grouped aliases, and direct references" do
    samples = %{
      web: [
        "import Ecto.Query",
        "alias Ecto, as: Persistence\nimport Persistence.Query",
        "alias FootballMarket.{Ranking}\nRanking.Cache.get(configuration)",
        "import Ecto.{Query, Changeset}",
        "alias FootballMarket.Repo, as: Persistence\nPersistence.all(query)",
        "alias FootballMarket.{Repo, Providers}\nProviders.fetch()",
        "FootballMarket.Repo.all(query)"
      ],
      domain: [
        "import FootballMarketWeb.Router",
        "import FootballMarketWeb.{Router, Endpoint}",
        "alias FootballMarketWeb.{Router, Endpoint}\nRouter.__routes__()",
        "FootballMarketWeb.Router.__routes__()"
      ],
      workers: [
        "import Ecto.Query",
        "alias Ecto, as: Persistence\nimport Persistence.Query",
        "import Ecto.{Query, Changeset}",
        "alias FootballMarket.Repo, as: Persistence\nPersistence.all(query)",
        "alias FootballMarket.{Repo, Providers}\nProviders.fetch()",
        "FootballMarketWeb.Router.__routes__()"
      ],
      providers: [
        "import Ecto.Query",
        "alias FootballMarket, as: App\nApp.Catalog.list()",
        "import FootballMarket.{Catalog, Workers}",
        "alias FootballMarket.Catalog, as: CatalogContext\nCatalogContext.list()",
        "alias FootballMarket.{Catalog, Workers}\nCatalog.list()",
        "FootballMarket.Catalog.list()"
      ],
      cache: [
        "import Ecto.Query",
        "alias Ecto, as: Persistence\nPersistence.Repo.all(query)",
        "import Ecto.{Query, Changeset}",
        "alias FootballMarket.Repo, as: Persistence\nPersistence.all(query)",
        "alias FootballMarket.{Repo, Providers}\nProviders.fetch()",
        "FootballMarket.Repo.all(query)"
      ]
    }

    for {layer, sources} <- samples, source <- sources do
      assert violations(source, layer, "fixture.ex") == ["#{layer}:fixture.ex"]
    end
  end

  test "allowed provider, cache, worker, and endpoint configuration dependencies stay accepted" do
    positives = [
      {:web, "alias FootballMarket.Catalog\nCatalog.list()"},
      {:web, "alias FootballMarket, as: App\nApp.Catalog.list()"},
      {:workers, "alias FootballMarket.Sync\nSync.sync()\nuse Oban.Worker"},
      {:providers, "alias Req\nReq.get(\"https://example.test\")"},
      {:cache, "alias Redix\nRedix.command(:redis, [\"PING\"])"},
      {:domain,
       "Application.fetch_env!(:football_market, FootballMarketWeb.Endpoint)[:secret_key_base]"}
    ]

    for {layer, source} <- positives do
      assert violations(source, layer, "fixture.ex") == []
    end
  end

  test "endpoint is forbidden outside the authorized secret configuration read" do
    sources = [
      "alias FootballMarketWeb.Endpoint",
      "Application.fetch_env!(:football_market, FootballMarketWeb.Endpoint)[:url]",
      "Application.fetch_env!(:other_app, FootballMarketWeb.Endpoint)[:secret_key_base]",
      "FootballMarketWeb.Endpoint.config_change([], [])"
    ]

    for source <- sources do
      assert violations(source, :domain, "fixture.ex") == ["domain:fixture.ex"]
    end
  end

  test "domain contexts retain the documented Ecto persistence adapter" do
    repo = File.read!("lib/football_market/repo.ex")

    assert repo =~ ~r/use\s+Ecto\.Repo/
    refute repo =~ ~r/FootballMarketWeb\.|FootballMarket\.Providers\.|FootballMarket\.Workers\./
  end

  defp violations(source, layer, path) do
    ast = Code.string_to_quoted!(source)
    ast = strip_authorized_endpoint_config(ast)
    aliases = aliases(ast)

    ast
    |> module_references()
    |> Enum.any?(fn reference -> forbidden?(reference, aliases, @forbidden[layer]) end)
    |> case do
      true -> ["#{layer}:#{path}"]
      false -> []
    end
  end

  defp strip_authorized_endpoint_config(ast) do
    Macro.prewalk(ast, fn
      {{:., _, [Access, :get]}, _,
       [
         {{:., _, [{:__aliases__, _, [:Application]}, :fetch_env!]}, _,
          [
            :football_market,
            {:__aliases__, _, [:FootballMarketWeb, :Endpoint]}
          ]},
         :secret_key_base
       ]} ->
        :authorized_endpoint_secret_config

      node ->
        node
    end)
  end

  defp aliases(ast) do
    {_ast, found} =
      Macro.prewalk(ast, %{}, fn
        {:alias, _, [target]} = node, acc ->
          {node, add_aliases(acc, target, nil)}

        {:alias, _, [target, options]} = node, acc ->
          as = Keyword.get(options, :as)
          {node, add_aliases(acc, target, as)}

        node, acc ->
          {node, acc}
      end)

    found
  end

  defp add_aliases(acc, {{:., _, [{:__aliases__, _, prefix}, :{}]}, _, parts}, nil) do
    Enum.reduce(parts, acc, fn {:__aliases__, _, part}, aliases ->
      case {normalize_alias(prefix), normalize_alias(part)} do
        {prefix, part} when is_list(prefix) and is_list(part) ->
          Map.put(aliases, List.last(part), prefix ++ part)

        _ ->
          aliases
      end
    end)
  end

  defp add_aliases(acc, {:__aliases__, _, target}, as) do
    target = normalize_alias(target)

    case target do
      target when is_list(target) ->
        short =
          case as do
            {:__aliases__, _, as_parts} -> as_parts |> List.last() |> to_string()
            nil -> List.last(target)
          end

        Map.put(acc, short, target)

      _ ->
        acc
    end
  end

  defp add_aliases(acc, _target, _as), do: acc

  defp module_references(ast) do
    {_ast, references} =
      Macro.prewalk(ast, [], fn
        {{:., _, [{:__aliases__, _, prefix}, :{}]}, _, parts} = node, refs ->
          grouped =
            Enum.flat_map(parts, fn {:__aliases__, _, part} ->
              case {normalize_alias(prefix), normalize_alias(part)} do
                {prefix, part} when is_list(prefix) and is_list(part) -> [prefix ++ part]
                _ -> []
              end
            end)

          {node, grouped ++ refs}

        {:__aliases__, _, parts} = node, refs when is_list(parts) ->
          case normalize_alias(parts) do
            parts when is_list(parts) -> {node, [parts | refs]}
            _ -> {node, refs}
          end

        node, refs ->
          {node, refs}
      end)

    references
  end

  defp normalize_alias(parts) do
    if Enum.all?(parts, &is_atom/1), do: Enum.map(parts, &to_string/1), else: nil
  end

  defp forbidden?([namespace | suffix], aliases, forbidden_paths) do
    resolved = Map.get(aliases, namespace, [namespace]) ++ suffix

    Enum.any?(forbidden_paths, fn forbidden ->
      Enum.take(resolved, length(forbidden)) == forbidden
    end)
  end
end
