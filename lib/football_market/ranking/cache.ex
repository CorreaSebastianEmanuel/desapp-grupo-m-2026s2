defmodule FootballMarket.Ranking.Cache do
  @moduledoc false

  alias FootballMarket.Valuation.Configurations.Version

  @ttl_seconds 30

  def get(%Version{} = configuration) do
    key = key(configuration)

    case adapter().get(key) do
      {:ok, nil} ->
        emit(:miss)
        :miss

      {:ok, payload} when is_binary(payload) ->
        case decode(payload) do
          {:ok, entries} ->
            emit(:hit)
            {:ok, entries}

          :error ->
            emit(:miss)
            :miss
        end

      _ ->
        emit(:error)
        :miss
    end
  rescue
    _ ->
      emit(:error)
      :miss
  catch
    _, _ ->
      emit(:error)
      :miss
  end

  def put(%Version{} = configuration, entries) when is_list(entries) do
    payload = Enum.map(entries, &encode_entry/1)

    case Jason.encode(payload) do
      {:ok, encoded} ->
        case adapter().put(key(configuration), encoded, @ttl_seconds) do
          :ok -> :ok
          _ -> emit(:error)
        end

      _ ->
        emit(:error)
    end
  rescue
    _ -> emit(:error)
  catch
    _, _ -> emit(:error)
  end

  def ttl_seconds, do: @ttl_seconds

  defp adapter do
    Application.get_env(:football_market, :ranking_cache_adapter, __MODULE__.Redis)
  end

  defp key(configuration) do
    "football_market:ranking:v1:#{configuration.id}:#{configuration.strategy_id}:#{configuration.formula_version}"
  end

  defp encode_entry(entry) do
    %{
      "player_id" => entry.player_id,
      "quote_id" => entry.quote_id,
      "unit_price" => Decimal.to_string(entry.unit_price),
      "effective_at" => DateTime.to_iso8601(entry.effective_at),
      "position" => entry.position
    }
  end

  defp decode(payload) do
    with {:ok, rows} when is_list(rows) <- Jason.decode(payload),
         {:ok, entries} <- decode_entries(rows) do
      {:ok, entries}
    else
      _ -> :error
    end
  rescue
    _ -> :error
  end

  defp decode_entries(rows) do
    Enum.reduce_while(rows, {:ok, []}, fn row, {:ok, entries} ->
      case decode_entry(row) do
        {:ok, entry} -> {:cont, {:ok, [entry | entries]}}
        :error -> {:halt, :error}
      end
    end)
    |> case do
      {:ok, entries} -> {:ok, Enum.reverse(entries)}
      :error -> :error
    end
  end

  defp decode_entry(row) when is_map(row) do
    with player_id when is_binary(player_id) <- row["player_id"],
         quote_id when is_binary(quote_id) <- row["quote_id"],
         price when is_binary(price) <- row["unit_price"],
         {unit_price, ""} <- Decimal.parse(price),
         true <- finite_positive?(unit_price),
         effective when is_binary(effective) <- row["effective_at"],
         {:ok, effective_at, _offset} <- DateTime.from_iso8601(effective),
         position when is_integer(position) and position > 0 <- row["position"] do
      {:ok,
       %{
         player_id: player_id,
         quote_id: quote_id,
         unit_price: unit_price,
         effective_at: effective_at,
         position: position
       }}
    else
      _ -> :error
    end
  end

  defp decode_entry(_), do: :error

  defp finite_positive?(%Decimal{coef: coefficient} = price) when is_integer(coefficient),
    do: Decimal.positive?(price)

  defp finite_positive?(_), do: false

  defp emit(outcome) do
    :telemetry.execute([:football_market, :ranking, :cache, outcome], %{count: 1}, %{})
  end

  defmodule Redis do
    @moduledoc false

    def get(key) do
      Redix.command(:ranking_cache_redis, ["GET", key])
    end

    def put(key, value, ttl_seconds) do
      case Redix.command(:ranking_cache_redis, ["SET", key, value, "EX", ttl_seconds]) do
        {:ok, "OK"} -> :ok
        error -> error
      end
    end
  end
end
