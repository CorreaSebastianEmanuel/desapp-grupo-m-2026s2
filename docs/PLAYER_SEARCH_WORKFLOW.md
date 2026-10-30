# Flujo de búsqueda y actualización de jugadores

Arquitectura acordada el 2026-10-06. Todo local; implementación pendiente. Decisiones y límites en [ADR-0016](adr/0016-local-search-and-background-refresh.md).

## Búsqueda y ficha

```text
Frontend: buscar jugador
          |
          v
Phoenix: consultar Redis
          |
          +-- hit ------------> devolver resultados
          |
          +-- miss / error --> consultar PostgreSQL
                                   |
                                   v
                            cachear si Redis funciona
                                   |
                                   v
                        resultados / lista vacía
                                   |
                                   v
Frontend: abrir ficha de un jugador existente
          |
          v
PostgreSQL: datos disponibles + last_checked_at + estado
          |
          v
Mostrar datos y fecha de última consulta
          |
          v
¿Nunca se comprobó o venció el TTL de actualización?
          |
          +-- no --> mostrar ficha
          |
          +-- sí --> solicitar actualización deduplicada
                        |
                        +-- pendiente / ejecutando --> reutilizar estado
                        +-- espera por fallo -------> mostrar fallo y espera
                        +-- disponible -------------> encolar en Oban
```

La frescura se verifica al abrir la ficha, aunque la búsqueda haya salido de Redis. El TTL de actualización parte de la última comprobación exitosa, no de la última búsqueda. Valor inicial propuesto: 24 horas configurables. El TTL de Redis es independiente.

## Cola, scraper y cálculo

```text
Oban: cola durable en PostgreSQL
          |
          v
Oban toma un trabajo y ejecuta el worker
          |
          v
Adaptador de scraping consulta la fuente por identidad concreta
          |
          v
Normalizar y validar identidad, cobertura y estadísticas
          |
          +-- fallo temporal --> reintento acotado con espera
          +-- inválido / agotado --> registrar fallo; conservar datos y fecha
          |
          v
Transacción PostgreSQL:
  persistir estadísticas válidas, procedencia y last_checked_at
  (sin cambios también renueva fecha si la comprobación fue completa)
          |
          v
Si hay cambios: persistir solicitud durable de cálculo pendiente
          |             (sin job de cotización durante el día)
          v
Mostrar estadísticas aceptadas, cotización del cierre anterior y fecha de valoración
          |
          v
Cierre nocturno por liga/temporada admite solicitudes pendientes en Oban
          |
          v
Dominio calcula con hechos persistidos y estrategia versionada
          |
          v
Insertar cotización reproducible + evento de evaluación sin sobrescribir historia
          |
          v
Invalidar cachés afectadas; registrar resultado de cada trabajo
          |
          v
Frontend consulta estado mientras esté pendiente
          |
          v
Mostrar estadísticas actualizadas, cotización vigente y su fecha de valoración
```

La búsqueda puede refrescar estadísticas vencidas durante el día. Los hechos aceptados y su estado se hacen visibles inmediatamente, pero el precio conserva la cotización del último cierre hasta el cálculo nocturno. El TTL de cotización se mide desde esa última cotización; su respaldo usa el ámbito aceptado más reciente por jugador/temporada. Cada solicitud pendiente por hechos cambiados se admite por separado. Completar un partido no dispara una cotización; un disparo postpartido es una posible evolución futura. Fallos de Redis no deshacen importaciones confirmadas: se reintenta invalidación y la caché expira.

## Catálogo

```text
Carga inicial / sincronización manual / tarea programada
          |
          v
Oban --> worker --> adaptador --> validar
          |
          v
Persistir catálogo idempotentemente en PostgreSQL
          |
          v
Invalidar caché de búsquedas
```

Una búsqueda sin coincidencias no dispara scraping de un nombre arbitrario. La sincronización del catálogo permite encontrar nuevos jugadores.

## Responsabilidades y tareas

| Responsabilidad | Tarea | Entrega |
|---|---|---|
| Contrato externo, identidad y comprobación completa | TASK-016 | CP2 |
| Adaptador de scraping, fuente candidata y acceso/cobertura | TASK-055 | CP2 |
| Catálogo idempotente | TASK-018 | CP2 |
| Oban local, sincronización manual/programada y reintentos básicos | TASK-019 | CP2 |
| Ingestión de estadísticas, procedencia y posición derivada | TASK-021 | CP2 |
| Rendimiento y cotizaciones versionadas | TASK-022 a TASK-026 | CP2 |
| TTL de estadísticas, solicitud asíncrona y estado de actualización | TASK-056 | CP2 |
| Redis para búsquedas y ranking | TASK-041 | CP3, anticipable |
| Invalidación y fallback ante Redis | TASK-042 | CP3, anticipable |
| Resiliencia avanzada del proveedor | TASK-044 | CP3 |
| Ficha con fecha, estado y seguimiento de actualización | TASK-047 | CP3, anticipable |
| Administración de sincronizaciones y trabajos | TASK-049 | CP3 |

PostgreSQL es la fuente de verdad también para trading; una respuesta cacheada no autoriza una operación financiera. Redis no guarda el único registro de si un jugador fue procesado. Cada integrante desarrolla con servicios locales, migraciones, seeds y fixtures compartidos; no se crea una base de datos de equipo en la nube.
