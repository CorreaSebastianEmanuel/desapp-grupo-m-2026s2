defmodule FootballMarketWeb.OpenAPIContractTest do
  use FootballMarket.DataCase, async: false

  @moduletag :integration
  import Phoenix.ConnTest
  import Plug.Conn
  import FootballMarket.OpenAPICase

  @endpoint FootballMarketWeb.Endpoint
  @codes ~w(invalid_page_size invalid_league_id invalid_team_id invalid_position_id invalid_cursor)

  setup do
    fixture!()
  end

  test "public publication and complete operation contract", fixture do
    json_conn = build_conn() |> get("/openapi.json")
    assert json_conn.status == 200
    assert [content_type] = get_resp_header(json_conn, "content-type")
    assert String.starts_with?(content_type, "application/json")
    doc = Jason.decode!(json_conn.resp_body)
    assert doc == document!()
    docs_html = build_conn() |> get("/docs") |> html_response(200)
    assert docs_html =~ "/api-docs/docs.js"
    assert docs_html =~ ~r/<main[^>]*class="docs-page"[^>]*data-theme="light"/
    assert docs_html =~ "color-scheme: light"

    assert build_conn() |> get("/api-docs/swagger-ui-bundle.js") |> response(200) =~
             "SwaggerUIBundle"

    assert_contract!(doc)
    list = get_in(doc, ["paths", "/api/players", "get"])

    assert Enum.map(list["parameters"], & &1["name"]) ==
             ~w(page_size cursor league_id team_id position_id)

    assert list["responses"]["200"]["content"]["application/json"]["examples"]["empty"]["value"][
             "data"
           ] == []

    assert list["responses"]["200"]["content"]["application/json"]["examples"]["empty"]["value"][
             "pagination"
           ] == %{
             "page_size" => 25,
             "returned_count" => 0,
             "has_more" => false,
             "next_cursor" => nil
           }

    assert fixture.player.id
  end

  test "contract drift guard rejects disposable route, security, parameter and schema mutations" do
    doc = document!()

    mutations = [
      fn copy ->
        put_in(
          copy,
          ["paths", "/api/players", "post"],
          get_in(copy, ["paths", "/api/players", "get"])
        )
      end,
      fn copy ->
        put_in(copy, ["paths", "/api/players", "get", "security"], [
          %{"BearerAuth" => [], "ApiKeyAuth" => []}
        ])
      end,
      fn copy -> update_in(copy, ["paths", "/api/players", "get", "parameters"], &tl/1) end,
      fn copy ->
        update_in(copy, ["components", "schemas", "Player", "required"], &List.delete(&1, "id"))
      end,
      fn copy ->
        put_in(
          copy,
          ["components", "schemas", "Pagination", "properties", "next_cursor", "nullable"],
          false
        )
      end,
      fn copy ->
        put_in(
          copy,
          [
            "components",
            "schemas",
            "UnauthenticatedError",
            "properties",
            "error",
            "properties",
            "code",
            "enum"
          ],
          ["invalid_cursor"]
        )
      end
    ]

    for mutate <- mutations do
      assert_raise ExUnit.AssertionError, fn -> assert_contract!(mutate.(doc)) end
    end
  end

  test "published success examples use a supported league and fictional catalog data" do
    doc = document!()

    list_player =
      get_in(doc, [
        "paths",
        "/api/players",
        "get",
        "responses",
        "200",
        "content",
        "application/json",
        "examples",
        "populated",
        "value",
        "data",
        Access.at(0)
      ])

    detail_player =
      get_in(doc, [
        "paths",
        "/api/players/{player_id}",
        "get",
        "responses",
        "200",
        "content",
        "application/json",
        "examples",
        "player",
        "value",
        "data"
      ])

    assert detail_player == list_player

    assert {list_player["league"]["code"], list_player["league"]["name"]} in FootballMarket.Catalog.supported_leagues()

    assert list_player["display_name"] == "Mara Calder"
    assert list_player["team"]["name"] == "Northbridge FC"
  end

  test "live success and examples match exact response schemas", %{
    jwt: jwt,
    api_key: key,
    player: player
  } do
    doc = document!()
    list = get_in(doc, ["paths", "/api/players", "get"])
    detail = get_in(doc, ["paths", "/api/players/{player_id}", "get"])
    jwt_conn = build_conn() |> put_req_header("authorization", "Bearer " <> jwt)
    key_conn = build_conn() |> put_req_header("x-api-key", key)
    populated = jwt_conn |> get("/api/players") |> json_response(200)
    empty = key_conn |> get("/api/players?team_id=#{Ecto.UUID.generate()}") |> json_response(200)
    shown = key_conn |> get("/api/players/#{player.id}") |> json_response(200)

    assert_schema!(
      doc,
      list["responses"]["200"]["content"]["application/json"]["schema"],
      populated
    )

    assert_schema!(doc, list["responses"]["200"]["content"]["application/json"]["schema"], empty)

    assert_schema!(
      doc,
      detail["responses"]["200"]["content"]["application/json"]["schema"],
      shown
    )

    assert get_in(populated, ["data", Access.at(0), "id"]) == player.id

    assert empty["pagination"] == %{
             "page_size" => 25,
             "returned_count" => 0,
             "has_more" => false,
             "next_cursor" => nil
           }

    for operation <- [list, detail],
        {_, response} <- operation["responses"],
        {_, example} <- get_in(response, ["content", "application/json", "examples"]) do
      assert_schema!(doc, response["content"]["application/json"]["schema"], example["value"])
    end
  end

  test "failure statuses, precedence, challenge and zero rejected catalog reads", %{
    jwt: jwt,
    api_key: key
  } do
    FootballMarket.PlayerCatalogProbe.attach_query_probe(self())
    unauthenticated = build_conn() |> get("/api/players?page_size=bad")
    assert json_response(unauthenticated, 401) == %{"error" => %{"code" => "unauthenticated"}}
    assert get_resp_header(unauthenticated, "www-authenticate") == ["Bearer realm=\"api\""]
    refute_receive {:catalog_query, _}
    auth = build_conn() |> put_req_header("authorization", "Bearer " <> jwt)

    for {query, code} <- [
          {"page_size=bad", "invalid_page_size"},
          {"league_id=bad", "invalid_league_id"},
          {"team_id=bad", "invalid_team_id"},
          {"position_id=bad", "invalid_position_id"},
          {"cursor=bad", "invalid_cursor"},
          {"page_size=bad&league_id=bad", "invalid_page_size"},
          {"league_id=bad&team_id=bad", "invalid_league_id"},
          {"team_id=bad&position_id=bad", "invalid_team_id"},
          {"position_id=bad&cursor=bad", "invalid_position_id"}
        ] do
      assert auth |> get("/api/players?" <> query) |> json_response(400) == %{
               "error" => %{"code" => code}
             }
    end

    refute_receive {:catalog_query, _}

    assert auth |> get("/api/players/malformed") |> json_response(404) == %{
             "error" => %{"code" => "player_not_found"}
           }

    assert auth |> get("/api/players/#{Ecto.UUID.generate()}") |> json_response(404) == %{
             "error" => %{"code" => "player_not_found"}
           }

    assert build_conn()
           |> put_req_header("authorization", "Bearer " <> jwt)
           |> put_req_header("x-api-key", key)
           |> get("/api/players")
           |> json_response(401) == %{"error" => %{"code" => "unauthenticated"}}

    assert build_conn()
           |> put_req_header("authorization", "Bearer bad")
           |> get("/api/players")
           |> json_response(401) == %{"error" => %{"code" => "unauthenticated"}}
  end

  test "repeated credentials and filter-bound cursor reject before catalog queries", %{
    jwt: jwt,
    api_key: key
  } do
    doc = document!()
    list = get_in(doc, ["paths", "/api/players", "get"])
    assert list["description"] =~ "effective filter set"
    assert list["description"] =~ "page_size, league_id, team_id, position_id, cursor"

    assert get_in(doc, ["paths", "/api/players/{player_id}", "get", "description"]) =~
             "Authentication runs before"

    FootballMarket.PlayerCatalogProbe.attach_query_probe(self())

    repeated =
      build_conn()
      |> put_req_header("authorization", "Bearer " <> jwt)
      |> Map.update!(:req_headers, &[{"authorization", "Bearer " <> jwt} | &1])
      |> get("/api/players")

    assert json_response(repeated, 401) == %{"error" => %{"code" => "unauthenticated"}}
    assert get_resp_header(repeated, "www-authenticate") == ["Bearer realm=\"api\""]
    refute_receive {:catalog_query, _}

    mixed =
      build_conn()
      |> put_req_header("authorization", "Bearer " <> jwt)
      |> put_req_header("x-api-key", key)
      |> get("/api/players?page_size=bad")

    assert json_response(mixed, 401) == %{"error" => %{"code" => "unauthenticated"}}
    refute_receive {:catalog_query, _}

    cursor =
      FootballMarket.Catalog.PlayerCursor.encode(
        %{name: "example", id: Ecto.UUID.generate()},
        %{team_id: Ecto.UUID.generate()}
      )

    auth = build_conn() |> put_req_header("authorization", "Bearer " <> jwt)

    assert auth |> get("/api/players?cursor=#{cursor}") |> json_response(400) == %{
             "error" => %{"code" => "invalid_cursor"}
           }

    refute_receive {:catalog_query, _}
  end

  defp assert_contract!(doc) do
    routes =
      FootballMarketWeb.Router
      |> Phoenix.Router.routes()
      |> Enum.filter(
        &(&1.path == "/api/players" or String.starts_with?(&1.path, "/api/players/"))
      )

    assert Enum.all?(routes, &(&1.metadata[:authentication_policy] == :api_protected))

    route_set =
      MapSet.new(routes, fn route ->
        {route.verb |> to_string() |> String.downcase(),
         String.replace(route.path, ":player_id", "{player_id}")}
      end)

    documented =
      MapSet.new(for {path, item} <- doc["paths"], {method, _} <- item, do: {method, path})

    assert documented == route_set
    assert doc["servers"] == [%{"url" => "/"}]
    schemes = doc["components"]["securitySchemes"]
    assert schemes["BearerAuth"]["type"] == "http"
    assert schemes["BearerAuth"]["scheme"] == "bearer"

    assert schemes["ApiKeyAuth"] == %{
             "type" => "apiKey",
             "in" => "header",
             "name" => "X-API-Key",
             "description" => schemes["ApiKeyAuth"]["description"]
           }

    for {_path, item} <- doc["paths"], {_method, op} <- item do
      assert op["security"] == [%{"BearerAuth" => []}, %{"ApiKeyAuth" => []}]

      assert Map.keys(op["responses"]) |> Enum.sort() ==
               if(op["operationId"] == "listPlayers", do: ~w(200 400 401), else: ~w(200 401 404))

      for {_status, response} <- op["responses"] do
        assert Map.keys(response["content"]) == ["application/json"]
      end

      assert get_in(op, ["responses", "401", "headers", "WWW-Authenticate", "example"]) ==
               "Bearer realm=\"api\""

      assert get_in(op, ["responses", "401", "content", "application/json", "schema", "$ref"]) ==
               "#/components/schemas/UnauthenticatedError"

      assert get_in(op, [
               "responses",
               "401",
               "content",
               "application/json",
               "examples",
               "unauthenticated",
               "value"
             ]) == %{"error" => %{"code" => "unauthenticated"}}
    end

    list = get_in(doc, ["paths", "/api/players", "get"])

    assert Enum.map(list["parameters"], & &1["name"]) ==
             ~w(page_size cursor league_id team_id position_id)

    assert Enum.all?(list["parameters"], &(&1["in"] == "query" and &1["required"] == false))

    assert hd(list["parameters"])["schema"] == %{
             "type" => "integer",
             "minimum" => 1,
             "maximum" => 100,
             "default" => 25
           }

    assert Enum.all?(Enum.drop(list["parameters"], 2), &(&1["schema"]["format"] == "uuid"))
    detail = get_in(doc, ["paths", "/api/players/{player_id}", "get"])

    assert [
             %{
               "name" => "player_id",
               "in" => "path",
               "required" => true,
               "schema" => %{"format" => "uuid"}
             }
           ] =
             detail["parameters"]
             |> Enum.map(&Map.update!(&1, "schema", fn s -> Map.take(s, ["format"]) end))
             |> Enum.map(&Map.take(&1, ["name", "in", "required", "schema"]))

    assert Map.keys(get_in(list, ["responses", "400", "content", "application/json", "examples"]))
           |> Enum.sort() == Enum.sort(@codes)

    assert get_in(list, ["responses", "400", "content", "application/json", "schema", "$ref"]) ==
             "#/components/schemas/ListInputError"

    assert get_in(detail, ["responses", "404", "content", "application/json", "schema", "$ref"]) ==
             "#/components/schemas/PlayerNotFoundError"

    schemas = doc["components"]["schemas"]

    for {name, fields} <- [
          {"Player", ~w(id display_name catalog_identity position team season league)},
          {"Position", ~w(id code name)},
          {"Team", ~w(id short_code name)},
          {"Season", ~w(id start_year end_year)},
          {"League", ~w(id code name)},
          {"Pagination", ~w(page_size returned_count has_more next_cursor)},
          {"PlayerPage", ~w(data pagination)},
          {"PlayerDetail", ~w(data)}
        ] do
      schema = schemas[name]
      assert Enum.sort(schema["required"]) == Enum.sort(fields)
      assert Enum.sort(Map.keys(schema["properties"])) == Enum.sort(fields)
      assert schema["additionalProperties"] == false
    end

    assert get_in(schemas, ["Pagination", "properties", "next_cursor", "nullable"]) == true

    for {schema, codes} <- [
          {"UnauthenticatedError", ["unauthenticated"]},
          {"ListInputError", @codes},
          {"PlayerNotFoundError", ["player_not_found"]}
        ] do
      assert get_in(schemas, [schema, "properties", "error", "properties", "code", "enum"]) ==
               codes
    end
  end

  defp assert_schema!(doc, %{"$ref" => ref}, value) do
    assert_schema!(
      doc,
      get_in(doc, [
        "components",
        "schemas",
        String.replace_prefix(ref, "#/components/schemas/", "")
      ]),
      value
    )
  end

  defp assert_schema!(doc, %{"type" => "object"} = schema, value) do
    assert is_map(value)
    assert Enum.sort(Map.keys(value)) == Enum.sort(schema["required"])
    for {key, child} <- schema["properties"], do: assert_schema!(doc, child, value[key])
  end

  defp assert_schema!(doc, %{"type" => "array", "items" => item}, value) do
    assert is_list(value)
    for child <- value, do: assert_schema!(doc, item, child)
  end

  defp assert_schema!(_doc, %{"nullable" => true}, nil), do: :ok

  defp assert_schema!(_doc, %{"type" => "string"} = schema, value) do
    assert is_binary(value) and byte_size(value) >= Map.get(schema, "minLength", 0)
    if schema["format"] == "uuid", do: assert(match?({:ok, _}, Ecto.UUID.cast(value)))
    if schema["enum"], do: assert(value in schema["enum"])
  end

  defp assert_schema!(_doc, %{"type" => "integer"} = schema, value) do
    assert is_integer(value)
    if schema["minimum"], do: assert(value >= schema["minimum"])
    if schema["maximum"], do: assert(value <= schema["maximum"])
  end

  defp assert_schema!(_doc, %{"type" => "boolean"}, value), do: assert(is_boolean(value))
end
