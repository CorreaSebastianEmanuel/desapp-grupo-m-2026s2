defmodule FootballMarket.Providers.Scraping do
  @moduledoc "Assessed provider pipeline with recorded-fixture and HTTPS document transports."
  @behaviour FootballMarket.Providers.Adapter
  alias FootballMarket.Providers.Scraping.{
    Assessment,
    Source,
    FixtureTransport,
    HttpTransport,
    DisabledTransport
  }

  def publication_guard(request, _context, state) do
    admission =
      if is_map(state),
        do: Assessment.admit(request, state),
        else: {:error, %{category: :unsupported_capability}}

    fn ->
      with {:ok, revision, _} <- admission,
           {:ok, _, _} <- Assessment.admit(request, state, revision) do
        :ok
      end
    end
  end

  def provider_label, do: "fotmob-shaped-offline"

  def read(request, context, state) when is_map(state) do
    if state[:mode] in [:fixture, :live] do
      transport = if state[:mode] == :fixture, do: FixtureTransport, else: HttpTransport
      state = Map.put(state, :transport, transport)

      with {:ok, revision, _} <- Assessment.admit(request, state),
           {:ok, lease} <- transport.acquire(request, context, state) do
        try do
          Source.read(request, context, state, revision)
        after
          transport.release(lease, state)
        end
      end
    else
      DisabledTransport.fetch("disabled", context, state)
    end
  end

  def read(_, _, _), do: {:error, %{category: :unsupported_capability}}
end
