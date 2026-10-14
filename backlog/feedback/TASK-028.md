# Feedback — TASK-028

## Feedback 1

- Time: 2026-10-14T03:13:06+00:00
- Author: sebo
- Restart from: develop

Origen: revision final independiente, R1/P2, specs/062-initial-player-token-issuance/review-report.md. Corregir exclusivamente la insercion inicial de market_initialization_locks en la migracion: calificar el INSERT con el prefijo explicito de Ecto, incluso cuando difiere del search_path de la conexion. Agregar regresion permanente que migre al esquema destino con search_path apuntando a otro esquema y verifique singleton del destino y filas origen sin cambios. Reutilizar el probe retenido en review-evidence/prefix_test.exs. Mantener alcance y comportamiento de producto; refrescar comprobaciones afectadas, QA independiente y revision final. No publicar hasta ambos Verdict: PASS.

## Feedback 2

- Time: 2026-10-14T03:49:42+00:00
- Author: sebo
- Restart from: develop

Origen: fallo real de CI del PR #37, Quality baseline, run 38507437540. Unit tests: 467/468 passed; Market.ScopeTest test/football_market/market/scope_test.exs:114-120 compara config/config.exs normalizado contra git show HEAD:config/config.exs. Antes de commit HEAD es la base; tras commit HEAD ya incluye initial_issuance_recipients, por lo que falla siempre. Corregir exclusivamente la comprobacion de limites para que preserve sus garantias sin depender de HEAD previo, refs remotas o profundidad de checkout. Agregar/verificar evidencia de comportamiento en checkout commiteado. Ejecutar el comando real de CI scripts/ci_unit_tests.sh ademas de comprobaciones requeridas; inspeccionar el workflow para cubrir checks afectados sin omitir garantias. QA y revision deben verificar la correccion post-commit y evidencia fresca. Mantener el alcance y actualizar PR #37 solo tras ambos Verdict: PASS.

## Feedback 3

- Time: 2026-10-14T03:54:46+00:00
- Author: sebo
- Restart from: develop

Continuacion de Feedback 2: el intento anterior dejo la prueba RED sin aplicar la correccion porque conto una restriccion sandbox y la reproduccion esperada como dos fallos. Ahora hay un cambio correctivo real en assert_config_boundary: SHA-256 fijo del contenido aprobado (b2f9904816f5efed3b630e782e7519058f96b18dc8b5d101dcbeb81ec8577251), incluyendo default vacio; sin comparacion contra HEAD ni dependencia Git. Conservar controles negativos existentes. Completar T020/T022-T024, ejecutar scope_regression y el comando real de CI con permisos adecuados, todos los checks requeridos, QA y revision independientes; actualizar PR #37 solo tras ambos PASS. Este cambio de fuente resuelve la causa y permite nuevos intentos; no es reintentar entradas sin cambios.

