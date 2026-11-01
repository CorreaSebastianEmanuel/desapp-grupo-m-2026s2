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

Una búsqueda sin coincidencias puede admitir una exploración acotada del catálogo. Primero se valida y normaliza el nombre; una consulta inválida nunca genera trabajo externo. Los nombres equivalentes comparten una exploración activa. Cada nombre nuevo admitido cuenta contra un límite de 10 admisiones por hora; los resultados negativos se conservan durante 24 horas.

La exploración es asíncrona y usa exclusivamente la sincronización de catálogo existente. Como máximo solicita un catálogo completo por cada una de las cinco ligas para una temporada configurada, sin más de cinco solicitudes por recorrido. La búsqueda devuelve de inmediato el estado de exploración y nunca espera al proveedor. Un resultado válido se publica mediante la ingestión idempotente del catálogo; después de persistir, se notifica el estado final por PubSub. No se importan estadísticas ni se crean cotizaciones, saldos, tokens, órdenes o transacciones. Los errores del proveedor conservan disponibles las lecturas locales. Si se agota el presupuesto de solicitudes, el siguiente intento espera a la próxima ventana nocturna configurada.

Una temporada debe poder resolverse antes de admitir el recorrido. Si no hay una temporada y fuentes compatibles configuradas, la búsqueda permanece local y muestra el estado de exploración no disponible; nunca infiere una temporada ni inicia scraping arbitrario.

El operador habilita recorridos mediante `:scouting_scopes` en la configuración de `FootballMarket.Synchronization`. Cada entrada enlaza un código de liga permitido, una temporada exacta (`start_year` y `end_year`) y un `source_ref` ya presente en `:sources`. La lista está vacía por defecto; instalar el adaptador no habilita por sí solo contacto externo. El worker valida cada solicitud mediante `Synchronization.request_catalog/2` y conserva sus controles existentes.

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
