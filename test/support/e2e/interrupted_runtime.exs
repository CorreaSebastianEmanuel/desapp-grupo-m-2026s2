FootballMarket.E2E.Runtime.with_runtime!(fn _base ->
  schema = FootballMarket.Repo.config()[:parameters][:search_path]
  File.write!(System.fetch_env!("E2E_INTERRUPT_MARKER"), schema)
  Process.sleep(:infinity)
end)
