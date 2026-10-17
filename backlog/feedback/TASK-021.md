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

