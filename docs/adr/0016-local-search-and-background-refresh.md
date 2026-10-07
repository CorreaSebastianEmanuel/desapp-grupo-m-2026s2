# ADR-0016: Búsqueda local y actualización asíncrona por TTL

**Estado**: Aceptado por el usuario para la arquitectura; implementación pendiente.
**Fecha**: 2026-10-06

## Contexto

El equipo necesita consultar jugadores sin esperar consultas externas y actualizar estadísticas mediante scraping en segundo plano. El usuario eligió ejecutar todo localmente y simplificar la detección de datos antiguos usando un TTL, en lugar de comparar calendarios y partidos en cada consulta.

## Decisión

- Mantener el monolito modular Phoenix. PostgreSQL y Redis se ejecutan localmente; Oban administra trabajos persistidos en PostgreSQL y ejecuta workers dentro de la aplicación. No agregar RabbitMQ, Kafka ni despliegue en la nube.
- Buscar exclusivamente en el catálogo local: Redis para resultados temporales, PostgreSQL ante un miss o fallo de Redis. Una búsqueda sin coincidencias devuelve una lista vacía y no dispara scraping por texto libre.
- Cargar el catálogo mediante sincronización inicial, manual o programada. Los trabajos externos usan identidades concretas del proveedor, no nombres ambiguos.
- Consultar la frescura de las estadísticas de una ficha en PostgreSQL. `last_checked_at` representa la última comprobación exitosa y validada de la fuente para el alcance importado. Una ficha nunca consultada o con TTL vencido solicita actualización sin bloquear la lectura. Propuesta inicial: 24 horas configurables.
- Definir el alcance de frescura por jugador, proveedor y temporada/conjunto de estadísticas solicitado. Consultar una temporada no vuelve vigentes todas las temporadas del jugador. La especificación de TASK-056 concretará este alcance y el contrato de lectura/solicitud.
- Registrar `last_checked_at` también si una comprobación completa y válida no encontró cambios. No renovarlo al buscar, encolar, comenzar un trabajo, recibir una respuesta incompleta o fallar. Persistirlo junto con el resultado de importación de forma atómica.
- Deduplicar solicitudes concurrentes del mismo alcance mientras existe un trabajo pendiente o ejecutándose. Oban conserva el estado de ejecución; PostgreSQL conserva procedencia, avance de importación y datos completos. La unicidad de trabajos no reemplaza restricciones e idempotencia de dominio.
- El worker obtiene datos mediante un adaptador, los normaliza y valida, y delega la persistencia al dominio. Después de confirmar cambios, solicita el cálculo de rendimiento y cotizaciones con entradas locales y versiones de estrategia. Un reintento no duplica actuaciones, cotizaciones ni operaciones.
- No sobrescribir hechos históricos ni cotizaciones inmutables. Una discrepancia con datos históricos exige tratamiento explícito según la especificación; no convertirla silenciosamente en una importación exitosa.
- Invalidar cachés afectadas al cambiar catálogo, estadísticas, estado visible o cotizaciones. La ficha lee frescura/estado autoritativo, de modo que un hit del caché de búsqueda no evita la comprobación por TTL. Reintentar invalidaciones fallidas y usar expiración como límite adicional de antigüedad.
- El frontend consulta el estado mientras espera y distingue actualización de estadísticas de cálculo pendiente de cotización. Nunca presentar una cotización anterior como recalculada. Mostrar última consulta, datos disponibles y fallos sin perder la lectura local.
- Ante fallos temporales, usar reintentos acotados con espera. Datos inválidos o restricciones de acceso no se resuelven mediante reintentos infinitos. Los datos anteriores siguen disponibles y el TTL no se renueva. Antes de solicitar otro trabajo, respetar el trabajo pendiente y la política de espera tras fallos para evitar tormentas de solicitudes.

## Fuente externa y límites

La investigación favorece un adaptador de scraping con FotMob como candidato principal, reemplazando la selección previa de Football-Data.org. Las pruebas exploratorias hallaron calendarios de cinco ligas y estadísticas de partidos, pero no validaron una temporada completa de importación ni una posición histórica para todos los suplentes. La regla aceptada de posición más frecuente conserva decisiones pendientes sobre ventana, empates e historial insuficiente; ver feedback de TASK-021.

El acceso regular a la fuente no queda autorizado por este ADR. FotMob publica restricciones a la extracción automática sistemática en sus [términos](https://www.fotmob.com/terms). TASK-055 debe resolver acceso permitido y cobertura antes de habilitar sincronización real; las pruebas automatizadas usan fixtures deterministas y no requieren scraping en vivo. Mantener el adaptador reemplazable y no eludir controles de acceso.

## Consecuencias y alternativas

Aceptamos un retraso de actualización de hasta el TTL en condiciones normales; si falla la fuente puede ser mayor y debe quedar visible. El TTL no demuestra que los datos coincidan con la fuente en tiempo real. Separamos el TTL deportivo persistido del TTL de caché de Redis.

Se descarta para esta etapa comparar calendarios en cada apertura y obtener datos externos durante una búsqueda. La cola basada en PostgreSQL evita agregar infraestructura. Localmente, los trabajos avanzan mientras la aplicación y los servicios estén encendidos; los trabajos persistidos pendientes se retoman al reiniciar.

El anuncio docente de CP2 incorpora gráficos del usuario y un feature adicional: ver ADR-0017 y CHECKPOINTS.md. Jobs e ingestión se planifican en CP2; frescura por TTL es una mejora de apoyo. El frontend necesario para gráficos y órdenes se adelanta a CP2; Redis permanece en CP3.

## Trazabilidad

Ver [flujo completo y tareas](../PLAYER_SEARCH_WORKFLOW.md). Las tareas futuras deben generar sus especificaciones y pruebas antes de implementar estos cambios. Esta decisión no reabre TASK-020 ni modifica su especificación o estado de revisión.
