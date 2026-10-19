defmodule FootballMarketWeb.Live.BrowserAuth do
  @moduledoc false
  import Phoenix.LiveView
  import Phoenix.Component
  alias FootballMarket.Accounts.BrowserSessions

  def on_mount(:workspace, _params, session, socket) do
    case initial_result(socket, session) do
      {:ok, actor} -> mount_actor(actor, socket)
      _ -> {:halt, ended(socket)}
    end
  end

  defp initial_result(socket, session) do
    if connected?(socket) do
      cookie = get_connect_info(socket, :session) || %{}
      BrowserSessions.validate(cookie["browser_handle"])
    else
      case session["actor"] do
        %{session_id: id} -> BrowserSessions.revalidate(id)
        _ -> {:error, :invalid}
      end
    end
  end

  defp mount_actor(actor, socket) do
    if connected?(socket),
      do: Phoenix.PubSub.subscribe(FootballMarket.PubSub, BrowserSessions.topic(actor.session_id))

    case BrowserSessions.revalidate(actor.session_id) do
      {:ok, fresh} -> mount_fresh(fresh, socket)
      _ -> {:halt, ended(socket)}
    end
  end

  defp mount_fresh(fresh, socket) do
    if connected?(socket) do
      Process.send_after(self(), :browser_validate, 250)
      schedule_deadline(fresh)
    end

    socket =
      socket
      |> assign(:actor, fresh)
      |> attach_hook(:browser_params, :handle_params, fn _, _, s -> guard(s) end)
      |> attach_hook(:browser_events, :handle_event, fn _, _, s -> guard(s) end)
      |> attach_hook(:browser_info, :handle_info, &info/2)
      |> attach_hook(:browser_async, :handle_async, fn _, _, s -> guard(s) end)

    {:cont, socket}
  end

  def guard(socket) do
    case BrowserSessions.revalidate(socket.assigns.actor.session_id) do
      {:ok, actor} -> {:cont, assign(socket, :actor, actor)}
      _ -> {:halt, ended(socket)}
    end
  end

  defp schedule_deadline(actor) do
    remaining =
      max(
        div(DateTime.diff(actor.expires_at, BrowserSessions.now(), :microsecond) + 999, 1000),
        1
      )

    Process.send_after(self(), :browser_deadline, remaining)
  end

  defp info(:browser_deadline, socket) do
    case guard(socket) do
      {:cont, socket} ->
        schedule_deadline(socket.assigns.actor)
        {:halt, socket}

      other ->
        other
    end
  end

  defp info(:browser_session_ended, socket), do: {:halt, ended(socket)}

  defp info(:browser_validate, socket) do
    case guard(socket) do
      {:cont, socket} ->
        Process.send_after(self(), :browser_validate, 250)
        {:halt, socket}

      other ->
        other
    end
  end

  defp info(_, socket), do: guard(socket)
  defp ended(socket), do: socket |> assign(:actor, nil) |> redirect(to: "/sign-in?notice=ended")
end
