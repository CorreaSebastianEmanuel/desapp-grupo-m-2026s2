# Implemented inventory — TASK-027

Retrospective inventory: checked implementation entries are supported by the
existing files and merge ancestry, not by a synthesized development run.

- [X] T001 Provide local quote lookup/history/date selection in `lib/football_market/quotes/reader.ex`.
- [X] T002 Expose authenticated quote routes and stable errors in `lib/football_market_web/controllers/quote_controller.ex`.
- [X] T003 Serialize exact public quote representations in `lib/football_market_web/controllers/quote_json.ex`.
- [X] T004 Maintain API schemas in `priv/static/openapi.json`.
- [X] T005 Maintain reader and HTTP regressions in `test/football_market/quotes/reader_test.exs` and `test/football_market_web/controllers/quote_controller_test.exs`.
- [X] T006 Independently verify the backfilled contract and record actual executed checks in `qa-report.md`.
- [X] T007 Independently review scope, provenance and acceptance in `review-report.md`.
- [X] T008 Reconcile the accepted delivery with the normal completion command after both reports pass.
