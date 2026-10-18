# Feedback — TASK-021

## Feedback 1

- Time: 2026-10-04T16:49:52+00:00
- Author: ezequielgonzalez
- Restart from: product
- Impact: product

Decisión de producto del usuario: para suplentes que ingresan, usar su posición más frecuente para la valoración y preservar la posición elegida junto con la actuación histórica. No equivale a usar automáticamente la posición habitual publicada por FotMob: la investigación encontró positionId en titulares y usualPosition en suplentes, pero no demostró frecuencia por posición. Resolución del usuario (2026-10-16): contar partidos anteriores de la misma temporada, sin incluir el partido valorado ni partidos posteriores; ante empate o historial insuficiente, conservar posición desconocida. No usar usualPosition como sustituto de una frecuencia demostrada. En producto, reconciliar explícitamente esta regla con FR-003 de specs/054-player-match-statistics/spec.md y definir procedencia de posiciones derivadas. No cambiar silenciosamente la posición efectiva de titulares ni el proveedor definitivo. TASK-020 está en review y el comando feedback rechazó un cuarto ciclo por límite de tres; esta decisión se registra en TASK-021, que corresponde a ingestión y procedencia, sin editar estado manualmente ni reabrir implementación. Evidencia exploratoria: /private/tmp/fotmob-scraping-feasibility.md.

## Feedback 2

- Time: 2026-10-06T10:51:00+00:00
- Author: ezequielgonzalez
- Restart from: architecture
- Impact: architecture

Arquitectura aceptada por el usuario el 2026-10-06: todo local, Phoenix modular, Oban con cola durable en PostgreSQL y Redis solo cache. Seguir docs/adr/0016-local-search-and-background-refresh.md y docs/PLAYER_SEARCH_WORKFLOW.md. Frescura mediante TTL configurable desde last_checked_at de una comprobacion completa y exitosa por alcance jugador/proveedor/temporada; no comparar calendarios en cada apertura. Ingesta valida y timestamp se persisten atomicamente; fallo o respuesta incompleta no renuevan fecha, y una comprobacion completa sin cambios si puede renovarla. Solicitudes deduplicadas y retries acotados; cambios confirmados disparan calculo retry-safe e invalidacion. Importacion y cotizacion tienen estados independientes. TASK-056 define solicitud y lectura de frescura, CP3 conserva cache/UI. No reabrir TASK-020 ni sobrescribir hechos historicos. El candidato scraper y limitaciones estan documentados; falta resolver acceso regular permitido y las decisiones de posicion de suplentes del feedback anterior.

## Feedback 3

- Time: 2026-10-07T12:24:21+00:00
- Author: ezequielgonzalez
- Restart from: architecture
- Impact: architecture

Planificacion CP2 reconciliada con main: reutilizar TASK-016 del PR #27; no usar el intento local duplicado. TASK-055 es el scraper, TASK-056 la frescura TTL (TASK-054 en main pertenece a Agentflow). Seguir ADR-0016 y ADR-0017. PR #28/TASK-017 ofrece catalogo Football-Data.org opcional, no estadisticas por partido suficientes. Conservar las decisiones pendientes de posicion mas frecuente: ventana, empates e historial insuficiente requieren especificacion antes de derivar; no usar usualPosition como frecuencia demostrada. Graficos y ordenes condicionales son nuevos requisitos CP2; no ampliar ingesta a implementarlos.
## Feedback 4

- Time: 2026-10-17T18:24:41+00:00
- Author: ezequielgonzalez
- Restart from: develop
- Impact: implementation
- Required regressions: cited discrepancy plus required manifest checks

QA independiente del run 4913d038 termino Verdict: FAIL y el gate qa_ready lo bloqueo. Remediar en desarrollo los tres hallazgos exactos de specs/065-statistics-ingestion-pipeline/qa-report.md: QA-01 (alta) el prevalidado de replay en lib/football_market/statistics/ingestion/publisher.ex:50-79 y :266-277 omite match mappings, acepta mappings conflictivos silenciosamente y avanza el successful pointer (outcome replay/accepted_unchanged); debe validar mappings contra identities ya aceptadas y bindings existentes con resultado immutable_conflict y pointer sin cambios; QA-02 (media) integrity_test.exs:119 codifica registros como Jason.encode! y los puedo guardar como JSONB string, reemplazar por maps tipados con un control positivo y variantes non-object que rechacen; QA-03 (alta) la migracion 20261016000100 valida evidencia solo sobre INSERT en player_match_performances, un INSERT posterior de performance con kickoff anterior y su basis pueden cambiar la explicacion de una base ya aceptada sin validacion de frecuencias o reason, debe proteger INSERTs hijos contra sujetos ya commiteados y validar consistencia de evidencia en esa ruta con transacciones commiteadas separadas (no pruebas en la misma transaccion). Regresiones requeridas del manifiesto verification.json: python3 scripts/agentflow_check.py unit --reuse e integration, mas los casos nuevos de replay mapping conflictivo, tipo de dato JSONB y basis tardia; QA re-ejecuta cada check sin --reuse.

## Feedback 5

- Time: 2026-10-17T19:06:33+00:00
- Author: ezequielgonzalez
- Restart from: qa
- Impact: qa
- Required regressions: cited discrepancy plus required manifest checks

Re-auditoria independiente incompleta en el reingreso de QA: el agente de QA corrio preflight/format/compile/unit (exit 0) y dejo lanzado integration en segundo plano pero termino su turno sin esperar el resultado ni reescribir qa-report.md/review-report.md, por lo que el gate qa_ready conservo el FAIL heredado del audit anterior (QA-01, QA-02, QA-03 siguen redactados). Requerido: reejecutar QA completo como agente independiente sobre el arbol ya remediado (remediacion de QA-01/02/03 ya implementada y validada por develop_ready), ejecutar integration SIN --reuse Esperando la salida en primer plano, revisar el diff completo de la feature y reescribir qa-report.md y review-report.md con el veredicto actual; el FAIL debe listarse solo si un hallazgo sobrevive al re-audit. Regresiones requeridas del manifiesto verification.json: preflight, format, compile, unit e integration con python3 scripts/agentflow_check.py CHECK_ID --stage qa, sin --reuse.

## Feedback 6

- Time: 2026-10-17T20:20:15+00:00
- Author: ezequielgonzalez
- Restart from: develop
- Impact: implementation
- Required regressions: cited discrepancy plus required manifest checks

El job CI Quality baseline (mix test crudo sobre DB por defecto) falla: los nuevos tests de statistics ingestion usan Ecto.Adapters.SQL.Sandbox.unboxed_run sobre el repo principal (recovery_test.exs:21,47 y pruebas QA-03 reescritas del feedback 4) y dejan filas comprometidas en la DB compartida (synchronization_runs en estado queued/executing/failed de operation statistics y catalogo sembrado), que envenenan test paralelos por fuera del sandbox (CatalogTest falla por leagues_normalized_code_index con leagues ya presentes, DevelopmentSeedTest espera created 44 reused 0 y encuentra reused 2, RecoveryTest y RequestTest cuentan observations mayor a 0). El perfil CI sin particiones exige aislamiento real: cada prueba con datos commiteados debe usar un backend/schema independiente de dueño (como el patron de Synchronization.Case con repos dinamicos per-test registrado ya en test/support/synchronization/case.ex incluyendo la migracion 20261016000300) o limpiar de forma confiable todo lo que commits (on_exit + truncado de tablas propias) sin dejar filas al terminar cada caso. No revertir la remediacion de QA-01/02/03; solo redirigir su persistencia a backends aislados. Regresiones requeridas del manifiesto verification.json: preflight, format, compile, unit e integration con python3 scripts/agentflow_check.py CHECK_ID, mas correr la suite completa MIX_ENV=test mix test --warnings-as-errors (como CI) sin fallos de contaminacion antes de handoff; QA re-ejecuta

## Feedback 7

- Time: 2026-10-17T22:59:15+00:00
- Author: ezequielgonzalez
- Restart from: qa
- Impact: qa
- Required regressions: cited discrepancy plus required manifest checks

El audit de QA del repaso completo esta listo y positivo (QA-01/02/03 verificados muertos en el codigo, 606/606 en suite cruda CI, preflight/format/compile/unit/integration re-ejecutados en primer plano, 23/23 cobertura), PERO specs/065-statistics-ingestion-pipeline/qa-report.md termina en Residual notes sin la linea de veredicto: el gate qa_ready exige que la ultima linea del archivo sea exactamente Verdict: PASS (o FAIL). Completar tu propio reporte existente: la ultima linea del archivo QA debe quedar exactamente Verdict: PASS con el contenido actual (no re-auditar de nuevo; tus evidencias ya estan escritas). Regla que aplica tambien al review: review-report.md debe terminar exactamente con Verdict: PASS. Regresiones requeridas del manifiesto: ninguna nueva ejecucion obligatoria; si revalidas usa --stage qa sin --reuse tal como ya hiciste (preflight/format/compile/unit/integration ya exit 0 hoy). QA re-ejecuta solo si su reporte requiere restaurar evidencia.

