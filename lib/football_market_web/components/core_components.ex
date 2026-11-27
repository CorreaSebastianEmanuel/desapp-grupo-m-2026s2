defmodule FootballMarketWeb.CoreComponents do
  @moduledoc "Minimal core UI components shared across Phoenix templates."
  use Phoenix.Component

  attr :name, :string, required: true
  attr :class, :any, default: "size-4"

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end
end

defmodule FootballMarketWeb.Layouts do
  @moduledoc false
  use FootballMarketWeb, :html

  embed_templates "layouts/*"
end
