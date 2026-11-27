# Feedback — TASK-093

## Feedback 1

- Time: 2026-11-16T21:18:30+00:00
- Author: shebi
- Restart from: develop
- Impact: implementation, verification
- Required regressions: cited discrepancy plus required manifest checks

Fallo observado por el agente en CI del PR #104, head 2c1d8ba7348e608d52743ceae91e4488d0ed9f59, run 43957951569: Quality baseline falla en Sobelow security analysis: lib/football_market/catalog.ex:249 SQL.Query low_confidence; accepted=6 blocking=1. Credo y SonarCloud pasan; Dialyzer/cobertura se omiten por el fallo previo. Diagnosticar con Sobelow nativo si list_players_for_statistics desplazó las coordenadas de una aceptación existente; mantener la consulta parametrizada y el gate, sin ignorar nuevos hallazgos ni añadir supresiones generales. Reconciliar sólo la identidad/coordenada de la aceptación si se prueba que es el mismo hallazgo previamente revisado, o corregir la causa real con mínimo cambio. Ejecutar python3 scripts/sobelow_ci.py y sus controles; revisar también Dialyzer nativo y contratos de integración afectados antes de publicar para agrupar discrepancias. Preservar alcance TASK-093 y PR #104, actualizar lección canónica proporcional, checks seleccionados y evaluación independiente fresca del delta.

## Feedback 2 — excepción autorizada por el usuario

- Time: 2026-11-16T22:38:07+00:00
- Author: shebi (autorización explícita en conversación)
- Restart from: develop
- Impact: implementation, verification
- Required regressions: contrato cron citado, perfil de integración completo y checks seleccionados
- Authorization: segundo ciclo acotado aprobado; el CLI rechazó registrarlo por su límite fijo. No se cambió la política ni el estado interno del run.

CI del PR #104, head e449dab452b185cd1126057dd459ea76e879ad77, run 43962568350: Credo, Sobelow, Dialyzer, SonarCloud y E2E PASS. El perfil integration falla en test/football_market/synchronization/scope_test.exs:112. Reproducción local confirma que la expectativa exacta del cron omite StatisticsPreload horario. Actualizar esa expectativa preservando las tres tareas previas, ejecutar integración completa con el wrapper mantenido, checks por riesgo y evaluación independiente fresca. Conservar el PR #104 y no hacer merge. Este permiso es sólo para esta segunda reparación; no autoriza más ciclos ni cambios en el harness.

