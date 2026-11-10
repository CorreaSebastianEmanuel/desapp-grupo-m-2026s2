defmodule FootballMarket.Quotes do
  @moduledoc "Trusted internal quote calculation and local history boundary."
  alias FootballMarket.Quotes.{
    Admission,
    Engine,
    ImportRequests,
    Mappings,
    Reader,
    Recovery,
    Replay
  }

  defdelegate save_mapping(name, version, scale), to: Mappings, as: :save
  defdelegate get_mapping(id), to: Mappings, as: :get
  defdelegate request(subject, selector, mapping, id \\ Ecto.UUID.generate()), to: Admission

  defdelegate request_membership(
                subject,
                selector,
                mapping,
                facts,
                id,
                lease \\ nil,
                identity \\ %{}
              ),
              to: Engine

  defdelegate process_import_request(id), to: ImportRequests
  defdelegate get_calculation(id), to: Reader
  defdelegate get_request(id), to: Reader
  defdelegate list_history(player_id), to: Reader
  defdelegate latest(player_id), to: Reader
  defdelegate at_date(player_id, date), to: Reader
  defdelegate pending_evaluations(), to: Recovery
  defdelegate claim_evaluation(id, lease_seconds \\ 300), to: Recovery
  defdelegate acknowledge_evaluation(id, fence, receipt), to: Recovery
  defdelegate replay(id), to: Replay
end
