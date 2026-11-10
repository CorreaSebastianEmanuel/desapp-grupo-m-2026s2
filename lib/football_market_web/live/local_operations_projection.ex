defmodule FootballMarketWeb.LocalOperationsProjection do
  @moduledoc "Web labels for raw local operational snapshots; performs no IO."
  alias FootballMarket.Synchronization.Run

  @table_labels %{
    users: "Usuarios",
    leagues: "Ligas",
    seasons: "Temporadas",
    teams: "Equipos",
    players: "Jugadores",
    matches: "Partidos",
    performances: "Estadísticas por partido",
    runs: "Ejecuciones de sincronización",
    attempts: "Intentos de sincronización",
    jobs: "Jobs Oban"
  }

  def snapshot(data) do
    data
    |> Map.delete(:job_contexts)
    |> Map.put(:jobs, jobs(data.job_contexts))
    |> Map.update!(:table_counts, fn counts ->
      Enum.map(counts, fn {key, count} -> {Map.fetch!(@table_labels, key), count} end)
    end)
  end

  defp jobs(contexts) do
    Enum.map(contexts, fn %{
                            job: job,
                            run: run,
                            players: players,
                            quote_contexts: quotes
                          } ->
      job
      |> Map.put(:context, context_for_job(job, run, players, quotes))
      |> Map.put(:execution_state, run && run.state)
      |> Map.put(:execution_detail, run_execution_detail(run))
    end)
  rescue
    _ -> []
  end

  defp quote_context(contexts, job) do
    case Map.get(contexts, get_in(job.args || %{}, ["request_id"])) do
      nil -> nil
      context -> "Calcular cotización · #{context}"
    end
  end

  defp context_for_job(job, run, players, quote_contexts) do
    quote_context(quote_contexts, job) ||
      manual_quote_close_context(job) || job_context(run, players, job.worker)
  end

  defp manual_quote_close_context(job) do
    if job.worker == "FootballMarket.Workers.QuoteClose" and
         get_in(job.args || %{}, ["mode"]) == "manual",
       do: "Cierre manual de cotizaciones · todas las ligas"
  end

  defp job_context(%Run{} = run, players, worker) do
    input = run.input || %{}
    player_id = input["player_id"]
    target = if player_id, do: Map.get(players, player_id, player_id), else: nil
    scope = league_scope(run)

    case {String.split(worker, ".") |> List.last(), run.operation, target} do
      {"CalculationDispatch", "statistics", name} when is_binary(name) ->
        "Enviar cálculo de estadísticas de #{name} · #{scope}"

      {"CalculationDispatch", "statistics", _} ->
        "Enviar cálculo de estadísticas · #{scope}"

      {_, "statistics", name} when is_binary(name) ->
        "Importar estadísticas de #{name} · #{scope}"

      {_, "statistics", _} ->
        "Importar estadísticas de #{scope}"

      {_, "catalog", _} ->
        "Actualizar equipos y planteles · #{scope}"

      {_, operation, _} ->
        "Ejecutar #{operation} · #{scope}"
    end
  end

  defp job_context(_, _, worker), do: worker_activity(worker)

  defp run_execution_detail(%Run{state: "failed", outcome: outcome} = run) do
    category = outcome && outcome["category"]
    reason = outcome && outcome["reason"]

    details =
      [provider_error_label(category), provider_error_label(reason)]
      |> Enum.reject(&is_nil/1)
      |> Enum.uniq()

    retry = if run.reason == "non_retryable", do: "No reintentable", else: nil

    (details ++ [retry])
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" · ")
    |> case do
      "" -> "La ejecución terminó con error"
      value -> value
    end
  end

  defp run_execution_detail(_), do: nil

  defp provider_error_label("invalid_response"), do: "Respuesta no válida del proveedor"
  defp provider_error_label("provider_failure"), do: "Fallo del proveedor"
  defp provider_error_label("rate_limited"), do: "Proveedor limitó las solicitudes"

  defp provider_error_label("unsupported_capability"),
    do: "FotMob no cubre esta liga/temporada"

  defp provider_error_label("timeout"), do: "Tiempo de espera agotado"
  defp provider_error_label(_), do: nil

  def execution_state_label("queued"), do: "Ejecución en cola"
  def execution_state_label("executing"), do: "Ejecución en curso"
  def execution_state_label("retry_wait"), do: "Reintento programado"
  def execution_state_label("succeeded"), do: "Importación exitosa"
  def execution_state_label("failed"), do: "Importación fallida"
  def execution_state_label(_), do: nil

  defp worker_activity(worker) do
    case String.split(worker, ".") |> List.last() do
      "ConditionalOrderEvaluation" -> "Evaluar si una orden condicional debe ejecutarse"
      "ConditionalOrderRecovery" -> "Revisar órdenes condicionales pendientes"
      "QuoteClose" -> "Cerrar cotizaciones vencidas"
      "QuoteRecovery" -> "Recuperar cálculos de cotización pendientes"
      "QuoteCalculation" -> "Calcular la cotización de un jugador"
      "CalculationDispatch" -> "Enviar un cálculo derivado de estadísticas importadas"
      other -> "Procesar tarea auxiliar · #{other}"
    end
  end

  defp league_scope(run) do
    name = Map.get(FootballMarket.Providers.Request.leagues(), run.league_code, run.league_code)
    "#{name} · #{run.start_year}/#{run.end_year}"
  end
end
