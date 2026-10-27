defmodule FootballMarketWeb.ErrorJSON do
  @moduledoc """
  This module is invoked by your endpoint in case of errors on JSON requests.

  See config/config.exs.
  """

  # If you want to customize a particular status code,
  # you may add your own clauses, such as:
  #
  # def render("500.json", _assigns) do
  #   %{errors: %{detail: "Internal Server Error"}}
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".
  def render("400.json", %{conn: %{request_path: "/api/purchases"}}),
    do: %{error: %{code: "invalid_request"}}

  def render("400.json", %{conn: %{request_path: "/api/conditional-orders"}}),
    do: %{error: %{code: "invalid_request"}}

  def render("400.json", %{conn: %{request_path: "/api/conditional-orders/" <> _}}),
    do: %{error: %{code: "invalid_request"}}

  def render(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end
end
