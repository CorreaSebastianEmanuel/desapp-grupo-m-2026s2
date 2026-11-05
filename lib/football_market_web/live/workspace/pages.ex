defmodule FootballMarketWeb.Workspace.Pages do
  @moduledoc false
  use FootballMarketWeb, :html
  import FootballMarketWeb.WorkspaceComponents
  import FootballMarketWeb.Workspace.Presentation
  import FootballMarketWeb.Workspace.Session, only: [domain_actor: 1]
  alias FootballMarketWeb.PortfolioComponents

  embed_templates "pages/*"

  def render(assigns) do
    ~H"""
    <.shell
      actor={@actor}
      destination={@destination}
      administrator={FootballMarket.Accounts.administrator?(domain_actor(@actor))}
      credit_balance={@credit_balance}
      credit_balance_unavailable={@credit_balance_unavailable}
    >
      <.orders :if={@destination == "/conditional-orders"} {assigns} />
      <.transactions :if={@destination == "/transactions"} {assigns} />
      <.players :if={@destination == "/players"} {assigns} />
      <.ranking :if={@destination == "/ranking"} {assigns} />
      <.portfolio :if={@destination == "/portfolio"} {assigns} />
    </.shell>
    """
  end
end
