defmodule FootballMarket.Providers.Scraping do
  @moduledoc "Explicit offline translator; actual retrieval is denied irrespective of switches."
  @behaviour FootballMarket.Providers.Adapter
  alias FootballMarket.Providers.Scraping.{
    Assessment,
    Source,
    FixtureTransport,
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
    if state[:mode] != :fixture do
      DisabledTransport.fetch("disabled", context, state)
    else
      with {:ok, revision, _} <- Assessment.admit(request, state),
           {:ok, lease} <- FixtureTransport.acquire(request, context, state) do
        try do
          Source.read(request, context, state, revision)
        after
          FixtureTransport.release(lease, state)
        end
      end
    end
  end

  def read(_, _, _), do: {:error, %{category: :unsupported_capability}}
end
