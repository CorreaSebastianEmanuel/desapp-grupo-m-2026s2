# Feedback — TASK-021

## Feedback 1

- Time: 2026-10-04T16:49:52+00:00
- Author: ezequielgonzalez
- Restart from: product

Decisión de producto del usuario: para suplentes que ingresan, usar su posición más frecuente para la valoración y preservar la posición elegida junto con la actuación histórica. No equivale a usar automáticamente la posición habitual publicada por FotMob: la investigación encontró positionId en titulares y usualPosition en suplentes, pero no demostró frecuencia por posición. Antes de especificar o implementar el cálculo, confirmar la ventana consultada al usuario: partidos anteriores de la misma temporada o todo el historial anterior disponible; respuesta aún pendiente. Resolver también empates e historial insuficiente sin fabricar frecuencias ni usar partidos posteriores al partido valorado. En producto, reconciliar explícitamente esta regla con FR-003 de specs/054-player-match-statistics/spec.md y definir procedencia de posiciones derivadas. No cambiar silenciosamente la posición efectiva de titulares ni el proveedor definitivo. TASK-020 está en review y el comando feedback rechazó un cuarto ciclo por límite de tres; esta decisión se registra en TASK-021, que corresponde a ingestión y procedencia, sin editar estado manualmente ni reabrir implementación. Evidencia exploratoria: /private/tmp/fotmob-scraping-feasibility.md.

## Feedback 2

- Time: 2026-10-06T10:51:00+00:00
- Author: ezequielgonzalez
- Restart from: architecture

Arquitectura aceptada por el usuario el 2026-10-06: todo local, Phoenix modular, Oban con cola durable en PostgreSQL y Redis solo cache. Seguir docs/adr/0016-local-search-and-background-refresh.md y docs/PLAYER_SEARCH_WORKFLOW.md. Frescura mediante TTL configurable desde last_checked_at de una comprobacion completa y exitosa por alcance jugador/proveedor/temporada; no comparar calendarios en cada apertura. Ingesta valida y timestamp se persisten atomicamente; fallo o respuesta incompleta no renuevan fecha, y una comprobacion completa sin cambios si puede renovarla. Solicitudes deduplicadas y retries acotados; cambios confirmados disparan calculo retry-safe e invalidacion. Importacion y cotizacion tienen estados independientes. TASK-056 define solicitud y lectura de frescura, CP3 conserva cache/UI. No reabrir TASK-020 ni sobrescribir hechos historicos. El candidato scraper y limitaciones estan documentados; falta resolver acceso regular permitido y las decisiones de posicion de suplentes del feedback anterior.

## Feedback 3

- Time: 2026-10-07T12:24:21+00:00
- Author: ezequielgonzalez
- Restart from: architecture

Planificacion CP2 reconciliada con main: reutilizar TASK-016 del PR #27; no usar el intento local duplicado. TASK-055 es el scraper, TASK-056 la frescura TTL (TASK-054 en main pertenece a Agentflow). Seguir ADR-0016 y ADR-0017. PR #28/TASK-017 ofrece catalogo Football-Data.org opcional, no estadisticas por partido suficientes. Conservar las decisiones pendientes de posicion mas frecuente: ventana, empates e historial insuficiente requieren especificacion antes de derivar; no usar usualPosition como frecuencia demostrada. Graficos y ordenes condicionales son nuevos requisitos CP2; no ampliar ingesta a implementarlos.

