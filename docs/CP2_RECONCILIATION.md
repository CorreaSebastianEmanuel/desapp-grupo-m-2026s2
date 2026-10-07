# Reconciliación de main, PRs y planificación

Fecha: 2026-10-07.

- Base remota revisada: main 092469f. TASK-016 completada por PR #27 (53dc806); QA y review publicados terminan PASS. No continuar el intento local duplicado en specs/055-external-football-provider-contract.
- Único PR abierto al revisar: #28, TASK-017 Football-Data.org. Su alcance obtiene catálogo actual; no cumple actuaciones necesarias para valoración. Se mantiene como trabajo opcional y se solicita revisión de producto antes de habilitar merge; TASK-055 separa el scraper elegido.
- TASK-054 de main es una mejora de Agentflow ya mergeada. Se conserva intacta. La tarea local de TTL se renumera TASK-056; tampoco se confundirá su ID con el directorio histórico specs/054-player-match-statistics.
- ADR-0013 de main define Providers; ADR-0014 define asociación de features. Se conservan. La arquitectura local anterior pasa a ADR-0016, respetando números 0014/0015 propuestos en PR #28.
- Este cambio toca documentación y backlog, no contratos/specs de tareas ya mergeadas ni código del proveedor.
- Requisitos de CP2 alineados con el anuncio del docente; reglas de órdenes quedan propuestas para su especificación y revisión antes de implementar.

La planificación se entrega en un PR separado. El merge sigue siendo humano conforme a AGENTS.md; no se marca ninguna nueva tarea done por documentar su alcance.

El intento local duplicado se preservó en un stash con mensaje `Preserve duplicate TASK-016 attempt before CP2 reconciliation`, y el commit de arquitectura anterior en `archive/local-main-architecture-20261007`. El checkout principal vuelve a main, limpio e igual a origin/main. La rama de planificación se mantiene en un worktree separado; el contenido nuevo requiere merge humano de su PR.
