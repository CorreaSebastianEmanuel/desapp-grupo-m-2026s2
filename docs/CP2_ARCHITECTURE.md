# Arquitectura y plan de entrega CP2

Actualización de planificación 2026-10-07. [Anuncio docente](CP2_SCOPE_CHANGE.md), [decisiones](adr/0017-cp2-charts-and-conditional-orders.md) y [flujo de búsqueda](PLAYER_SEARCH_WORKFLOW.md).

## Servicios locales

```text
Frontend LiveView
     | búsqueda, gráficos, creación/cancelación de órdenes
     v
Phoenix web --> contextos de dominio --> PostgreSQL
     |                                   | datos y hechos históricos
     |                                   | saldo, tokens, órdenes y operaciones
     |                                   | cola Oban durable
     |                                   v
     |                              Oban ejecuta workers
     |                                   |
     |                   +---------------+----------------+
     |                   |                                |
     |            adaptador scraper                valorar / evaluar órdenes
     |                   |                                |
     |              datos externos                    dominio + transacciones
     |                   |                                |
     +<------ PubSub después de confirmar cambios --------+

Redis: optimización de búsquedas/ranking en CP3.
PostgreSQL: autoridad incluso cuando exista cache.
```

## Flujo del feature adicional

```text
Usuario define cantidad, máximo precio y vencimiento
          |
          v
Validar y persistir orden pending + solicitud durable de evaluación
          |
          v
Oban toma trabajo --> leer orden y cotización actual
          |
          +-- vencida --> expired
          +-- cancelada/terminada --> no-op idempotente
          +-- precio no cumple --> sigue pending
          +-- precio cumple --> compra atómica todo-o-nada
                                   |
                                   +-- saldo/inventario insuficiente --> rejected
                                   +-- éxito --> executed + operación
                                   +-- fallo temporal --> rollback + retry acotado
          |
          v
Después del commit: notificar LiveView por PubSub
          |
          v
Frontend relee estado; reconexión recupera de PostgreSQL
```

Cada nueva cotización solicita evaluación durable; un barrido recupera órdenes pendientes y vencimientos. El precio del job no autoriza compra: siempre se verifica el precio actual dentro de la transacción.

## Orden de trabajo y alcance

| Tareas | Entrega | Dependencias/resultado |
|---|---|---|
| TASK-016 | Hecha en main | Contrato externo mergeado en PR #27 |
| TASK-017 | Opcional, PR #28 draft | Catálogo Football-Data.org; no actuaciones |
| TASK-055 → TASK-018 → TASK-019 → TASK-021 | CP2 | Scraper, catálogo, Oban y estadísticas |
| TASK-022–027 | CP2 | Estrategias y cotizaciones inmutables |
| TASK-028–033 | CP2 | Tokens, compra/venta, historia, portfolio y ranking |
| TASK-046 | CP2 | Shell LiveView autenticado mínimo |
| TASK-057 → TASK-058 | CP2 obligatorio nuevo | Analítica y gráficos del usuario |
| TASK-059 → TASK-060 → TASK-061 | CP2 obligatorio nuevo | Órdenes condicionales, workers y UI |
| TASK-063 → TASK-034 → TASK-062 | CP2 | Perfiles unit/E2E, regresión y presentación manual |
| TASK-056 | Apoyo CP2, posponible | TTL de estadísticas; antes usó ID local TASK-054 |
| TASK-041/042, TASK-036–045, TASK-047–052 | CP3 | Cache, observabilidad y completar interfaz/release |

Las nuevas tareas tienen dependencias explícitas; sus IDs no indican orden de ejecución. Trabajar una a la vez. El detalle de TASK-047 y TASK-048 se mantiene en CP3, evitando repetir los gráficos de TASK-058. Usar fixtures controlados para la demo si la fuente falla, mostrándolo explícitamente.

## Demo que debemos poder presentar

1. Autenticarse y mostrar gráficos de un portfolio con datos persistidos.
2. Crear una orden con máximo precio; mostrar pending cuando no cumple.
3. Incorporar una cotización de prueba confirmada que cumpla el precio.
4. Mostrar ejecución por Oban y actualización visible del estado/portfolio.
5. Repetir el evento/job sin comprar dos veces; mostrar rechazo por saldo insuficiente y cancelación/expiry.
6. Explicar valor de producto, límites, transacciones, idempotencia y código de worker/dominio.

Este documento planifica la demo; no afirma que los escenarios ya estén implementados o aprobados.
