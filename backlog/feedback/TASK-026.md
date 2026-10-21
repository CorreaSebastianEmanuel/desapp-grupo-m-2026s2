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

## Feedback 10

- Time: 2026-10-21T01:25:44+00:00
- Author: ezequielgonzalez
- Restart from: qa
- Impact: qa
- Required regressions: cited discrepancy plus required manifest checks

QA del 20:26 FAIL (reporte desactualizado: 2 de 4 blockers YA RESUELTOS en el working tree, ambos con receipts verificados hoy). Estado real: (B1) FR-007 admission terminal durable RESUELTO en lib/football_market/quotes.ex (record_admission_failure!: configuration_unavailable/mapping_unavailable persisten fila validation_failed; el probe /private/tmp/task026_qa_admission_test.exs ahora PASA con mix test --no-compile). Per QA guidance: recrear ese probe como regresión committed en test/football_market/quotes/admission_test.exs con el patrón QuotesCase.fixture + ValuationConfigurationCase.private_schema (mismo test del QA, dentro del allowlist de quotes/). (B3) runtime RESUELTO: scripts/verify_quote_runtime.exs reescrito con ingesta REAL (Statistics.Ingestion.import_scope + Case/Fixtures de test-support), accept real del intent, snapshot durable, job QuoteCalculation stranded (kill antes del cálculo), proceso fresco que recupera/confirmar successful, replay desde evidencia con replay==original, supresión de duplicados, financials intactos y hermetic (purge de oban_jobs propios + drop del store) — receipt exit 0: .agentflow/runs/checks/a51aee7448d14823adfa2fce949af473/026-quote-recalculation-and-immutable-history/develop/runtime/911bb85dac9f45c38033ffdf36291114.log (y re-verificado manualmente). (B2) integration: recibos exit 0 de HOY (0ae38203f0ac499d8cf239385ae1a4b2 y 6a7b6873e52049f48d0ae308a09abfc7); el browser-prerequisite de QA era ambiental; Node24+Chromium verificado OK en vivo — corrij de nuevo INDEPENDIENTE sin --reuse en qa stage. (B4) RESOLVER: actualizar specs/026-.../tasks.md (checkbox T001-T029 reconciliados con evidencia real) y reescribir handoffs/develop.md (el cuál dice 'Develop is incomplete' — ya no aplica; nuevo: cambios, decisions, receipts vigentes incluyendo runtime REAL, riesgos residuales exactos). Luego: TODA la cadena de checks SIN --reuse (preflight, format, compile, unit, integration, runtime) hasta receipts nuevos + readiness develop exit 0; NO repetir diagnósticos ya hechos; dos fallos sin inputs nuevos deten la corrida. Reglas vigentes del feedback 8/9 sobre contratos/SLAs.

## Feedback 11

- Time: 2026-10-21T01:57:08+00:00
- Author: ezequielgonzalez
- Restart from: develop
- Impact: implementation
- Required regressions: cited discrepancy plus required manifest checks

Continuación del feedback 10 (por la mitad del trabajo, quedan detalles pequeños con criterio ya definido por el QA-report 22:46). Estado REAL del working tree: (1) FR-007/B1: en lib/football_market/quotes.ex existe record_admission_failure!/5 (persiste fila validation_failed con reason whitelisted; mapping_id SOLO si el mapping existe via Repo.exists?, si no nil) y el flujo: request/4 chequea RAISING retained_explicit(existing) ANTES de Mappings.get (retained_explicit re-returns {:error, atom} de reason whitelisted para estados terminal successful/no_quote/validation_failed/unsupported_strategy/exhausted) y hice split continue_request/4 para el resto; admit_explicit persiste el failure configuration_unavailable dentro del txn y devuelve {:error, :configuration_unavailable} sin rollback. warnings-as-errors COMPILED OK. (2) PROBES QA a replicar como regresión committed: /private/tmp/qa_b1b2_test.exs y /private/tmp/task026_qa_admission_test.exs (el segundo PASA hoy, 1 passed; el primero tiene 2 tests: B1 missing-but-valid mapping UUID → {:error, :mapping_unavailable} + get_request {:ok, validation_failed/mapping_unavailable}; B2 el retry idéntico re-retorna el mismo error). ULTIMO RUN REPORTADO (mi sesión): los 3 probes okbies fallando con temporarily_unavailable — diagnosticar ANTES de editar (probablemente el fixture QuotesCase fixture requiere el on_exit-hook de contexto de test; mis replays sin ExUnit rompieron el primer branch — USA el probe original exs del QA corriendo via mix test --no-compile que sí funciona). (3) B3: además de la regresión, cerrar los gap del QA-report (matriz US1-US3 y feedback 8-10) SOLO si son pequeños; el runtime driver ya es REAL (import_scope+accept real+stranded job+recuperación en BEAM fresco+replay+dup-suppress+hermetic) receipt exit 0 hoy: runtime/d6fef163d89b45718e192c50d781ef2c.log — no lo reescribas salvo defecto concreto. (4) B5: reconciliar tasks.md T001-T029 y REESCRIBIR handoffs/develop.md con el estado actual (receipts frescos: preflight 87e7745d, format 43562111, compile d7ba7d1f, unit a33ef3a9, integration a93a7625, runtime d6fef163 — todos exit 0 el 20/10). (5) Después: TODA la cadena SIN --reuse hasta receipts nuevos (+ si editaste algo) + readiness develop exit 0. NO nxresegunda QA-report por tu parte (no es tu capa). Verificación de contrato: specs/026-.../spec.md FR-007/FR-010/FR-015 y contracts/calculation.md. No commitees.

## Feedback 12

- Time: 2026-10-21T03:16:40+00:00
- Author: ezequielgonzalez
- Restart from: develop
- Impact: implementation
- Required regressions: cited discrepancy plus required manifest checks

QA 00:14 FAIL — remedar los 4 blockers EN ESTE ciclo (presupuesto final). B1 (bug producto): request/4 debe validar la IDENTIDAD antes del retained-return: primero resolver mapping (Mappings.get) y selector_name, luego compare explicit_request_matches?/4 contra la row existente; si NO matchea → {:error, :request_conflict} (antes que retained). Solo si matchea: retained_explicit || load_explicit_facts. Commit de regresión: caso 'reused request_id with different mapping identity returns request_conflict' (crear primera admission con mapping inexistente, segunda con f.mapping.id → request_conflict) en test/football_market/quotes/admission_test.exs. B3 (driver runtime): añadir setup de late-fact + strategy-switch en scripts/verify_quote_runtime.exs (según spec US2): calcular para membership/estrategia v1, luego NUEVOS facts late + cambio de estrategia activo; replay debe mantener original intacto; comparar price persistido vs esperado (score * scale 1.25, redondeo ties-away); comparar financials del fixture (issuance 100, quotes/eval correspondientes) DESPUÉS de crear el fixture (mover el issuance-check de las líneas 40-66 al final del driver para que compare el estado local del fixture). B4 (reconcile): tasks.md T027/T029 DESmarcar si los receipts del develop no son current (hoy los receipt son: preflight 78841f8e, format 7cac72e3, compile c1d82e59, unit 9d7185b3, integration ec9f8022, runtime 2f923599 — todos exit 0 y current con el árbol ANTES de tus edits; si tocás lib/test/specs, re-corré la cadena COMPLETA sin --reuse y actualizá handoffs/develop.md + marks con la corrida real). B2 QA adapter: browser-prerequisite es denial del sandbox del QA-agent (no ambiental global — Chromium OK: probe directo exit 0) — si vuelves a fallar in own sandbox, regenerar con MIX_OS_CONCURRENCY_LOCK=0 y PATH de ~/.nvm/versions/node/v24*/bin + tools/openapi NODE OK. Reglas: no implementes lo ya verificado; SOLO cierra los 4 blockers y re-corrí la cadena + readiness exit 0. NO escribas QA-report (no es tu capa). No commitees.

## Feedback 13

- Time: 2026-10-21T17:57:11+00:00
- Author: ezequielgonzalez
- Restart from: develop
- Impact: implementation
- Required regressions: cited discrepancy plus required manifest checks

Ciclo final extendido (presupuesto ampliado a 16): implementar los 3 blockers del QA independiente (qa-report.md 2026-10-21) en develop y cerrar la deuda de evidencia FR-015. (B1) quotes.ex:87 compara scope/selector sin la identidad del mapping suministrado: mismo request_id con DISTINTO UUID de mapping no-disponible debe dar request_conflict y la identidad faltante debe quedar inspectable en la request persistida; regresión committed en test/football_market/quotes/admission_test.exs. (B2) process_import_request/1 llama siempre Membership.snapshots(req.intent_id) aunque las explicit requests tienen nil intent_id con facts retenidos propios: inyección de INSERT-trigger fallando en schema fixture aislada, request explicit pending duradera, remover inyección y ejecutar el worker path debe terminar successful; regresión committed de rollback precommit + recuperación worker-path. (B3) cerrar los gaps FR-015 citados en la matriz del QA: multi-player/semana, dos imports antes del primer dispatch, transiciones reales de retry 60/300s con repeated interrupted attempts y recovery-to-success, rollback quote/event por inyección precommit, fake-consumer effective-work deduplication, snapshot financiero intacto por clase de fallo y missing-original replay failure a nivel quotes. Mantener decisiones product/architecture asentadas; si se toca lib/test/specs re-correr TODA la cadena sin --reuse (preflight, format, compile, unit, integration, runtime) + workflow_artifact_probe develop --readiness exit 0 con receipts frescos; actualizar handoffs/develop.md y marks de tasks.md con evidencia real; NO reinventar lo ya verificado (runtime driver late-fact/strategy-switch pasó hoy). Ambiental bajo runner: ci_unit_tests.sh ya fuerza TMPDIR plano; evidencia restante queda en .agentflow/runs/ci_profile_logs_0303fail (no repetir).

