# Feedback — TASK-026

## Feedback 1

- Time: 2026-10-18T00:08:29+00:00
- Author: ezequielgonzalez
- Restart from: product
- Impact: product
- Required regressions: cited discrepancy plus required manifest checks

FR-006 resuelto: convertir el puntaje de estrategia en precio unitario mediante un mapeo monotónico determinista, versionado, con calibración (escala) y redondeo decimal documentados; su identidad/regla forma parte de la evidencia reproducible (FR-004). Si el puntaje o el resultado convertido es cero o negativo, la entrega no es cotizable: registrar un resultado no-quote explícito, sin inventar precio ni aplicar floor.
## Feedback 2

- Time: 2026-10-18T00:29:49+00:00
- Author: ezequielgonzalez
- Restart from: develop
- Impact: implementation
- Required regressions: cited discrepancy plus required manifest checks

La implementación quedó desalineada con tasks.md: el trabajo de código existe (migraciones, lib/football_market/quotes, workers, tests) pero T001–T029 permanecen sin marcar y no hay receipts de manifest checks. Completa la reconciliación según T026/T029: verifica qué tareas están realmente terminadas (ejecutando los checks en falta vía scripts/agentflow_check.py para producir receipts frescos y sincronizados con la fuente), marca en tasks.md solo lo efectivamente completado dejando pendientes únicamente [gate:qa] T030 y [gate:review] T031, y pasa scripts/workflow_artifact_probe.py develop --readiness. Diagnóstica antes cualquier test que falle: no manufactures receipts ni marques sin evidencia.

## Feedback 3

- Time: 2026-10-18T01:21:11+00:00
- Author: ezequielgonzalez
- Restart from: develop
- Impact: implementation
- Required regressions: cited discrepancy plus required manifest checks

Corrida completa MIX_ENV=test mix test: 577/627, 50 fallos con causa dominante de reconciliacon, no logica de negocio. (1) Fallas de scope por rutas nuevas sin registrar: Statistics/Providers/Market/Valuation/Synchronization ScopeTest reportan outside plan para lib/football_market/quotes/*.ex, lib/football_market/workers/quote_calculation.ex, las tres migraciones 20261018*, config/runtime.exs y config/synchronization.exs; extiende allowance exactos en test/support/workflow_scope.ex y los scope_test correspondientes (T002) y ajusta el plan boundary de Statistics al snapshot/migracion de publisher si quickstart lo prevé. (2) Fallas de sandbox en QuotesCase (calculation/outcomes/storage/history/replay/concurrency/followup/recovery/import): error SQL ownership caller debe estar permitido; reconciliar QuotesCase/valuation fixtures con el patrón de sandbox del proyecto (DataCase setup_sandbox o shared/prod-like partitions según quickstart T001/T003). (3) Preflight previo fallo por Mix filesystem lock :eperm transitorio (locks concurrentes); la condición de bloqueo ya cambió: reejecuta todos los checks via scripts/agentflow_check.py (runtime sin --reuse) y produce receipts frescos. Luego marca en tasks.md solo con evidencia, deja sin marcar solo T030/T031, corre workflow_artifact_probe.py develop --readiness y actualiza handoffs/develop.md. No manufactures receipts ni marques sin check aprobado.

## Feedback 4

- Time: 2026-10-18T02:02:42+00:00
- Author: ezequielgonzalez
- Restart from: develop
- Impact: implementation
- Required regressions: cited discrepancy plus required manifest checks

Quedan 10 fallos transaccionales con causa raiz identificada, evidencia en /tmp no referenciable: usa los receipts de integration a56c827a y reejecuta los 4 archivos truncados. Bucket A - market tests (retry/concurrency/rejection/storage, lineas del receipt): el helper test/support/market_case.ex later_quote/2 inserta rule_id 'fixture' sin calculation/configuration/mapping/performance_sequence, que ahora viola el check market_quote_performance_shape de la migracion 20261018000000; reconciliar el helper y los direct-writes de esos tests con la forma inicial_issuance o un quote enlazado completo segun plan T005/T017 (preservar test de integrity guards). Bucket B - statistics/ingestion/calculation_test.exs: CalculationRequests.accept devuelve {:error, :temporarily_unavailable} tras excepcion dentro de Repo.transaction / rescue amplio de do_accept (ver liberacion defence en lib/.../calculation_requests.ex:73-81); depurar la excepcion real (probable enqueue_import! via Quotes.Membership) mismo fallo hace Oban.drain_queue discar el job (failure 4). Bucket C - replay/drain: drain_until_acceptance! sumariza 0 (test line 305). Tras corregir: rerun format/compile/unit/integration + runtime sin reuse via agentflow_check.py hasta receipts PASS, marcar T025 y T026/T027/T029 con evidencia, y dejar solo T030/T031 sin marcar. No manufactures receipts.

## Feedback 5

- Time: 2026-10-18T16:51:01+00:00
- Author: ezequielgonzalez
- Restart from: qa
- Impact: qa
- Required regressions: cited discrepancy plus required manifest checks

El bloqueo Mix TCP filesystem lock :eperm es esporadico del sandbox del agente (evidencia z .agentflow/runs/checks/.../qa/preflight/4aed8c8e7eb24e3980087b2e38c96fda.log y exito en otras corridas previas, incluida la corrida manual full-suite 627/627 exit 0). La condicion de bloqueo ya cambio/esta restablecida: reejecuta la QA independiente completa (todos los manifest checks sin --reuse y revisa diff/coverage) sin suponer que preflight sigue fallando; si reintenta y ve el mismo lock dos veces con inputs intactos, haz el reporte honesto.

## Feedback 6

- Time: 2026-10-18T17:04:27+00:00
- Author: ezequielgonzalez
- Restart from: qa
- Impact: qa
- Required regressions: cited discrepancy plus required manifest checks

El lock Mix TCP :eperm es esporadico y transitorio del sandbox del agente: en la MISMA corrida QA anterior hubo 1 fallo (4aed8c8e...) y el reintento inmediato paso (c8bcb9e71, receipt state=passed). La retry siempre converge. Instrucciones: ante ese error en un check, reintenta el mismo check sin detener la corrida (matcher no cuenta como fallo de inputs); ademas tienes evidencia developer-fresh de toda la suite verde (preflight/format/compile/unit/integration/runtime receipts en .agentflow/runs/checks/.../develop/*), y la QA igual debe correrlos INDEPENDIENTEMENTE (sin --reuse) hasta receipts PASS en qa/*, revisar el diff completo (incluido untracked: quotes/, migraciones 600/700, scripts/verify_quote_runtime.exs, workflow.yml ci_baseline fix) y el coverage de verification.json antes del veredicto. Publicar FAIL solo si un check real falla tras diagnosticos.

## Feedback 7

- Time: 2026-10-18T17:23:57+00:00
- Author: ezequielgonzalez
- Restart from: qa
- Impact: qa
- Required regressions: cited discrepancy plus required manifest checks

Causa raiz del bloqueo reproducido y corregida: Mix adquiere un lock de concurrencia OS con fallback TCP que el sandbox de los agentes deniega intermitentemente (:eperm). Ya esta deshabilitado por defecto (MIX_OS_CONCURRENCY_LOCK=0 inyectado en scripts/agentflow_check.py y en el probe fresh-BEAM). Rerun completo: corre TODOS los manifest checks independentemente (agentflow_check.py CHECK_ID --stage qa, sin --reuse, reintenta ante ese lock), revisa el diff completo incluido untracked, verifica el coverage de verification.json y publica el veredicto final honesto. Resto de instrucciones del feedback anterior siguen vigentes.

## Feedback 8

- Time: 2026-10-18T17:37:19+00:00
- Author: ezequielgonzalez
- Restart from: develop
- Impact: implementation
- Required regressions: cited discrepancy plus required manifest checks

Hallazgos QA desde qa-report.md Verdict FAIL (fuente: specs/026-quote-recalculation-and-immutable-history/qa-report.md). Rectifica en develop: (1) BUG recovery.ex:12 solo selecciona pending/running; incluye retrying con next_attempt_at <= now para honrar los backoffs 60/300s y exhaustion al tercer intento (plan: Outcomes/recovery); agrega tests en recovery_test.exs de la agenda 60/300/exhausted. (2) BUG quotes.ex:222-230: los errores de lookup activo/configuration deben clasificar como finish_request validation_failed configuration_unavailable terminal por contracts/calculation.md, no caer en retry generico (lineas 173-174). (3) Confirmación: valida el lease fence ANTES del insert/actualización de quote y rechaza transacciones calleras (plan ID y scoring/commit contract); muestra en tests de immutability/concurrency. (4) Completa la matriz de cobertura determinista: crash/rollback pre-commit, lost-ack, missing-original fail, no-quote restart, multi-scope/multi-player imports, dos imports antes de dispatch, legacy intent unreproducible, consumer dedup de effective work en followup_test. (5) El driver scripts/verify_quote_runtime.exs debe PRODUCIR el flujo real por quickstart: primer proceso BEAM acepta import/pins membership, mata dispatch antes del cálculo, segundo proceso recupera+ confirma quote, luego replay original y unchanged financial state; exit nonzero ante fallos. (6) Cambios de esquema solo dentro de lo ya declarado (migraciones 600/700 y allowance actual). Tras implementar, la cadena de checks Developer completa SIN --reuse está en receipts frescos, marca tareas T023a-T025 afinadas y corre el probe de readiness.

## Feedback 9

- Time: 2026-10-18T17:47:48+00:00
- Author: ezequielgonzalez
- Restart from: develop
- Impact: implementation
- Required regressions: cited discrepancy plus required manifest checks

Tu sandbox de codex tenia OUTBOUND bloqueado (tcp connect :eperm not owner) por eso preflight fallo tres veces: ya corregido via wrapper (workspace-write + network_access=true) — ahora puedes correr los checks LOCALES. Completa entonces lo pendiente del feedback #8: (1) driver scripts/verify_quote_runtime.exs produciendo el flujo completo del quickstart (import→pin→kill dispatch→recover→confirm quote→replay original en proceso BEAM fresco + unchanged financial state). (2) matrix de cobertura determinista: no-quote restart, unreproducible legacy intent, multi-scope/multi-player import con dos aceptaciones antes de dispatch, consumer dedup de effective work, retry 60/300/exhausted ya presente pero verifica. (3) re-certifica tus regression cases (recovery/immutability) corriendolos. Luego ejecuta TODA la cadena: preflight, format, compile, unit (todos --reuse), integration --reuse, runtime sin reuse, workflow_artifact_probe develop --readiness; marca T021/T025/T027/T029 con evidencia y deja solo T030/T031. Mantén tus propias reglas de dos fallos.

