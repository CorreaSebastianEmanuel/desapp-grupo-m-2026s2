defmodule FootballMarketWeb.Workspace.Presentation do
  @moduledoc false

  def money(value), do: value |> Decimal.round(2) |> Decimal.to_string(:normal)
  def exact_money(nil), do: "Sin datos"
  def exact_money(value), do: value |> Decimal.normalize() |> Decimal.to_string(:normal)
  def timestamp(value), do: Calendar.strftime(value, "%Y-%m-%d %H:%M:%S UTC")
  def readable_reason(nil), do: "no disponible"
  def readable_reason("insufficient_funds"), do: "saldo insuficiente"
  def readable_reason("insufficient_inventory"), do: "inventario insuficiente"
  def readable_reason(reason), do: reason |> String.replace("_", " ")

  def order_status("pending"), do: "Pendiente"
  def order_status("executed"), do: "Ejecutada"
  def order_status("rejected"), do: "Rechazada"
  def order_status("cancelled"), do: "Cancelada"
  def order_status("expired"), do: "Vencida"
  def order_status(status), do: status
end
