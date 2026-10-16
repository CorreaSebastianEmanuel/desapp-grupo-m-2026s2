defmodule FootballMarketWeb.WorkspaceLive do
  use FootballMarketWeb, :live_view
  import FootballMarketWeb.WorkspaceComponents
  def mount(_, _, socket), do: {:ok, socket}

  def handle_params(_, uri, socket) do
    destination = URI.parse(uri).path

    {:noreply,
     assign(socket,
       destination: destination,
       heading:
         if(destination == "/conditional-orders", do: "Conditional orders", else: "Portfolio")
     )}
  end

  def render(assigns) do
    ~H"""
    <.shell actor={@actor} destination={@destination}><.unavailable heading={@heading} /></.shell>
    """
  end
end
