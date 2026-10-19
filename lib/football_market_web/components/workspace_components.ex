defmodule FootballMarketWeb.WorkspaceComponents do
  @moduledoc false
  use FootballMarketWeb, :html
  attr :actor, :map, required: true
  attr :destination, :string, required: true
  slot :inner_block, required: true

  def shell(assigns) do
    ~H"""
    <section id="workspace" phx-hook="WorkspaceSession">
      <div id="connection-notice" role="alert" hidden>Connection lost. Reconnecting safely…</div>
      <div id="private-workspace" data-private-workspace>
        <header>
          <p>{@actor.email}</p>
          <nav aria-label="Workspace">
            <a href="/portfolio" aria-current={@destination == "/portfolio" && "page"}>Portfolio</a>
            <a
              href="/conditional-orders"
              aria-current={@destination == "/conditional-orders" && "page"}
            >Conditional orders</a>
          </nav>
          <form method="post" action="/sign-out">
            <input type="hidden" name="_csrf_token" value={get_csrf_token()} />
            <button>Sign out</button>
          </form>
        </header>
        <main>{render_slot(@inner_block)}</main>
      </div>
    </section>
    """
  end

  attr :heading, :string, required: true

  def unavailable(assigns) do
    ~H"""
    <h1>{@heading}</h1>
    <p>This area is not available yet. More features will be added in a future update.</p>
    """
  end

  attr :kind, :string, required: true

  def recovery(assigns) do
    ~H"""
    <main>
      <h1>{@kind}</h1><p role="alert">This resource is unavailable.</p><a href="/portfolio">Return to workspace</a><a href="/sign-in">Sign in</a>
    </main>
    """
  end
end
