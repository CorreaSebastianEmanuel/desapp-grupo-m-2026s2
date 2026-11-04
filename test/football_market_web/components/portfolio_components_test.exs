defmodule FootballMarketWeb.PortfolioComponentsTest do
  use ExUnit.Case, async: true
  @moduletag :unit
  import Phoenix.LiveViewTest

  test "portfolio chart marks missing quote data as a gap, not zero" do
    point = %{
      date: ~D[2026-10-30],
      cutoff_at: ~U[2026-10-30 12:00:00Z],
      market_value: Decimal.new("1"),
      realized_profit_loss: Decimal.new(0),
      unrealized_profit_loss: Decimal.new("0"),
      purchase_expenditure: Decimal.new("1"),
      sale_proceeds: Decimal.new("0")
    }

    points = [
      point,
      %{point | date: ~D[2026-10-31], cutoff_at: ~U[2026-10-31 12:00:00Z], market_value: nil},
      %{
        point
        | date: ~D[2026-11-01],
          cutoff_at: ~U[2026-11-01 12:00:00Z],
          market_value: Decimal.new("2")
      }
    ]

    html =
      render_component(&FootballMarketWeb.PortfolioComponents.history_chart/1, %{
        points: points,
        metric: :market_value,
        label: "Valor de mercado del portafolio"
      })

    assert html =~ "Sin datos"
    assert length(Regex.scan(~r/M[0-9.]+,[0-9.]+/, html)) == 2
    assert html =~ "Escala: 1 a 2 créditos."
    assert html =~ "2026-10-30"
    refute html =~ "2026-10-30T12:00:00Z"

    incomplete_allocation =
      render_component(&FootballMarketWeb.PortfolioComponents.portfolio_charts/1, %{
        allocation: %{
          positions: [%{player_name: "Alex Example", weight: nil}],
          totals: %{valuation_complete: false},
          as_of: ~U[2026-10-30 12:00:00Z]
        },
        allocation_unavailable: false,
        history: %{points: [], from: ~D[2026-10-30], to: ~D[2026-10-30]},
        history_unavailable: false
      })

    assert incomplete_allocation =~ "Sin datos"

    assert incomplete_allocation =~
             "La distribución estará disponible cuando todos tus jugadores tengan una cotización actual."

    realized =
      render_component(&FootballMarketWeb.PortfolioComponents.history_chart/1, %{
        points: points,
        metric: :realized_profit_loss,
        label: "Ganancia/pérdida realizada"
      })

    assert realized =~ "<td>0</td>"
    refute realized =~ "<td>Sin datos</td>"
  end

  test "portfolio charts offer accessible empty allocation and history states" do
    html =
      render_component(&FootballMarketWeb.PortfolioComponents.portfolio_charts/1, %{
        allocation: %{positions: [], totals: %{}, as_of: ~U[2026-10-30 12:00:00Z]},
        allocation_unavailable: false,
        history: %{points: [], from: ~D[2026-10-01], to: ~D[2026-10-30]},
        history_unavailable: false
      })

    assert html =~ "No hay posiciones para mostrar."
    assert html =~ "Todavía no hay movimientos."
    refute html =~ "history-chart-market_value"
  end

  test "portfolio charts render accessible populated values and report unavailable reads" do
    point = %{
      date: ~D[2026-10-30],
      cutoff_at: ~U[2026-10-30 12:00:00Z],
      market_value: Decimal.new("4"),
      realized_profit_loss: Decimal.new("1"),
      unrealized_profit_loss: Decimal.new("2"),
      purchase_expenditure: Decimal.new("3"),
      sale_proceeds: Decimal.new("0")
    }

    html =
      render_component(&FootballMarketWeb.PortfolioComponents.portfolio_charts/1, %{
        allocation: %{
          positions: [%{player_name: "Alex Example", weight: Decimal.new("1")}],
          totals: %{valuation_complete: true},
          as_of: ~U[2026-10-30 12:00:00Z]
        },
        allocation_unavailable: false,
        history: %{points: [point], from: point.date, to: point.date},
        history_unavailable: false
      })

    assert html =~ "Alex Example"
    assert html =~ "100.0%"
    assert html =~ "Valor de mercado del portafolio por día"
    assert html =~ "Ganancia/pérdida realizada por día"
    assert html =~ "Ganancia/pérdida no realizada por día"
    assert html =~ "2026-10-30"
    refute html =~ "2026-10-30T12:00:00Z"

    unavailable =
      render_component(&FootballMarketWeb.PortfolioComponents.portfolio_charts/1, %{
        allocation: nil,
        allocation_unavailable: true,
        history: nil,
        history_unavailable: true
      })

    assert unavailable =~ "La distribución no está disponible temporalmente"
    assert unavailable =~ "El historial del portafolio no está disponible temporalmente"
    refute unavailable =~ "Todavía no hay movimientos"
  end
end
