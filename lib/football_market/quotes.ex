defmodule FootballMarket.Quotes do
  @moduledoc """
  Public facade for the Quotes domain (player token price calculation & history).

  Sub-modules under `lib/football_market/quotes/` (1 file = 1 module):
    * `Mappings` (`mappings.ex`) — score-to-price conversion mappings & exact cent rounding
    * `Admission` (`admission.ex`) — durable request admission & deduplication
    * `Engine` (`engine.ex`) — valuation execution & atomic quote publication
    * `ImportRequests` (`import_requests.ex`) — statistics-import quote request handling
    * `Membership` (`membership.ex`) — accepted fact snapshot membership tracking
    * `Closing` (`closing.ex`) — nightly league/season close quote admission
    * `Recovery` (`recovery.ex`) — stalled request & evaluation event recovery
    * `Reader` (`reader.ex`) — latest quote, history, as-of date, and replay verification
    * `EvidenceCodec` (`evidence_codec.ex`), `Store` (`store.ex`), `schemas.ex`
  """

  alias FootballMarket.Quotes.{
    Admission,
    Engine,
    ImportRequests,
    Mappings,
    Reader,
    Recovery
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
  defdelegate replay(id), to: Reader
  defdelegate pending_evaluations(), to: Recovery
  defdelegate claim_evaluation(id, lease_seconds \\ 300), to: Recovery
  defdelegate acknowledge_evaluation(id, fence, receipt), to: Recovery
end
