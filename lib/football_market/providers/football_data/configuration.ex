defmodule FootballMarket.Providers.FootballData.Configuration do
  @moduledoc "Trusted source settings, validated on use without startup work."
  alias FootballMarket.Providers.FootballData.MintTransport
  @test_capability Mix.env() == :test
  @positions %{
    "GK" => "Goalkeeper",
    "DEF" => "Defender",
    "MID" => "Midfielder",
    "FWD" => "Forward"
  }
  @mapping %{"Goalkeeper" => "GK", "Defence" => "DEF", "Midfield" => "MID", "Offence" => "FWD"}
  defstruct enabled: false,
            token: nil,
            position_mapping: @mapping,
            transport: {MintTransport, :live},
            fixture_id: nil,
            invalid: false

  def positions, do: @positions
  def mapping, do: @mapping

  def new(settings) when is_map(settings) do
    known = Map.keys(__struct__()) -- [:__struct__]

    struct(__MODULE__, Map.take(settings, known))
    |> Map.put(
      :invalid,
      Map.get(settings, :invalid, false) != false or
        Enum.any?(Map.keys(settings), &(&1 not in known))
    )
  end

  def new(_), do: %__MODULE__{invalid: true}

  def validate(%__MODULE__{} = state, context) do
    cond do
      state.enabled not in [true, false] ->
        failure(:invalid_request)

      state.enabled == false ->
        failure(:unsupported_capability)

      not is_binary(state.token) or String.trim(state.token) == "" ->
        failure(:authentication_failed)

      state.invalid or not safe_token?(state.token) ->
        failure(:invalid_request)

      not valid_transport?(state.transport) ->
        failure(:invalid_request)

      not is_nil(state.fixture_id) and not clean?(state.fixture_id, state.token) ->
        failure(:invalid_request)

      true ->
        validate_mapping(state, context.positions)
    end
  end

  def validate(_, _), do: failure(:invalid_request)

  defp validate_mapping(state, positions) do
    try do
      true = is_map(state.position_mapping)

      true =
        Enum.all?(@positions, fn {code, name} ->
          positions[code] == name and clean?(code, state.token) and clean?(name, state.token)
        end)

      pairs =
        Enum.map(state.position_mapping, fn {label, target} ->
          true =
            clean?(label, state.token) and is_binary(target) and Map.has_key?(positions, target) and
              clean?(target, state.token) and clean?(positions[target], state.token)

          {label |> String.trim() |> String.downcase(), target}
        end)

      true = length(pairs) == length(Enum.uniq_by(pairs, &elem(&1, 0)))
      mapping = Map.new(pairs)

      true =
        Enum.all?(@mapping, fn {label, target} -> mapping[String.downcase(label)] == target end)

      {:ok, %{state | position_mapping: mapping}}
    rescue
      _ -> failure(:invalid_request)
    end
  end

  def clean?(value, token),
    do:
      FootballMarket.Providers.Provenance.safe_text?(value) and not String.contains?(value, token)

  defp safe_token?(token),
    do: String.valid?(token) and not Regex.match?(~r/[\p{Cc}\p{Cf}]/u, token)

  def valid_transport?({MintTransport, :live}), do: true

  def valid_transport?(
        {MintTransport,
         %{address: {127, 0, 0, 1}, port: port, hostname: "localhost", cacertfile: ca} = state}
      ) do
    @test_capability and is_integer(port) and port in 1..65535 and is_binary(ca) and
      Enum.sort(Map.keys(state)) == Enum.sort([:address, :port, :hostname, :cacertfile])
  end

  def valid_transport?({module, _state}),
    do: @test_capability and module == FootballMarket.Providers.FootballData.RecordingTransport

  def valid_transport?(_), do: false
  defp failure(category), do: {:error, %{category: category}}
end

defimpl Inspect, for: FootballMarket.Providers.FootballData.Configuration do
  def inspect(_, _), do: "#FootballData.Configuration<redacted>"
end
