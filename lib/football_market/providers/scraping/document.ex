defmodule FootballMarket.Providers.Scraping.Document do
  @moduledoc "Assessed portion acquisition, bounded deadline and decoded document validation."
  alias FootballMarket.Providers.Scraping.Assessment

  def portion!(key, request, context, state, revision, row) do
    budget!(context)

    admit!(request, state, revision)

    require!(state[:repeat] != true)
    transport = state.transport

    fetch_state =
      state
      |> Map.put(:request, request)
      |> Map.put(:assessment_revision, revision)

    case fetch(transport, key, context, fetch_state) do
      {:error, failure} ->
        throw({:source_failure, failure})

      {:ok, %{body: body, observation: o}} ->
        budget!(context)

        admit!(request, state, revision)

        a = Assessment.current(state)

        if o[:destination] not in a.destinations,
          do: throw({:source_failure, %{category: :unsupported_capability}})

        require!(o[:terminal] == true and o[:witness] == row.witness)
        decode!(body)

      _ ->
        throw({:invalid, :scope})
    end
  end

  defp fetch(transport, key, context, state) do
    try do
      transport.fetch(key, context, state)
    rescue
      _ -> {:error, %{category: :unavailable}}
    catch
      _, _ -> {:error, %{category: :unavailable}}
    end
  end

  def decode!(body) when is_binary(body) do
    raw =
      if String.starts_with?(String.trim_leading(body), "<") do
        case Regex.scan(~r/<script\b[^>]*\bid=["']__NEXT_DATA__["'][^>]*>(.*?)<\/script>/s, body) do
          [[_, json]] -> json
          _ -> throw({:invalid, :scope})
        end
      else
        body
      end

    {:ok, decoded} = Jason.decode(raw)

    case decoded do
      %{"props" => _props} -> get_in(decoded, ["props", "pageProps"]) |> map!()
      value when is_map(value) or is_list(value) -> value
      _ -> throw({:invalid, :scope})
    end
  end

  def decode!(_), do: throw({:invalid, :scope})

  def budget!(context) do
    {runtime, state} = context.runtime

    if runtime.now_us(state) >= context.deadline_us,
      do: throw({:source_failure, %{category: :timeout}})
  end

  def require!(v), do: if(v != true, do: throw({:invalid, :scope}))

  def map!(v) do
    require!(is_map(v))
    v
  end

  def list!(v) do
    require!(is_list(v))
    v
  end

  def id!(v) do
    require!(FootballMarket.Providers.Provenance.safe_text?(v))
    v
  end

  defp admit!(request, state, revision) do
    case Assessment.admit(request, state, revision) do
      {:ok, _, _} -> :ok
      {:error, failure} -> throw({:source_failure, failure})
    end
  end
end
