# ADR-0017: CP2 con gráficos del usuario y órdenes condicionadas

**Estado**: Arquitectura y planificación acordadas para preparar revisión; reglas de producto propuestas deben pasar especificación y challenge antes de implementación.
**Fecha**: 2026-10-07

## Contexto

El anuncio docente incorpora gráficos de datos del usuario y un feature adicional, manteniendo entrega el 3 de noviembre. El usuario pidió alinear backlog, arquitectura y PRs. Ya existe TASK-016 mergeada; no se debe reemplazar su implementación por el intento local duplicado. TASK-054 identifica una mejora de Agentflow completada; la tarea de frescura recibe TASK-056. La arquitectura local acordada se registra ahora como ADR-0016, preservando ADR-0013/0014 de main.

## Arquitectura

Mantener un monolito modular Phoenix/LiveView con PostgreSQL local. Oban es la cola durable en PostgreSQL y ejecuta workers dentro de la aplicación. Redis es cache de lectura de CP3; no es necesario para gráficos ni órdenes de CP2. PubSub actualiza pantallas conectadas tras commits; no es una cola durable. Reconexión y carga inicial leen estado autoritativo de PostgreSQL.

Separar frontend/web, contexto de trading/órdenes, valoración, analítica, persistencia, jobs y adaptadores externos. Workers delegan en el dominio. El scraper reutiliza Providers del PR #27 y no condiciona las lecturas locales. TASK-055 resuelve fuente, acceso recurrente permitido y cobertura antes de activar scraping; fixtures y demo controlada no necesitan llamadas en vivo.

## Gráficos requeridos

TASK-057 produce series y composición del portfolio usando operaciones y cotizaciones persistidas, solo para su dueño autenticado. TASK-058 presenta composición actual, evolución de valor y ganancias/pérdidas, con unidades y fecha de corte. Cantidades históricas se reconstruyen de operaciones hasta el punto de corte; precios se toman de la última cotización efectiva disponible hasta ese punto. No usar tenencias actuales para todos los puntos históricos ni cotizaciones futuras.

Definir en la especificación la granularidad temporal, zona horaria (propuesta UTC), tratamiento de flujos de compras/ventas y distinción entre valor de cartera, ganancia realizada y no realizada. Evitar presentar aportes como rendimiento. Sin cotización histórica válida, mostrar falta de datos; no inventar ceros ni cambios. Decimal en cálculos; conversión a representación gráfica solo en la capa de presentación. Mantener media de compra y rentabilidad conforme al dominio existente.

## Feature adicional propuesto: órdenes de compra condicionadas

Valor de producto: permitir que un usuario deje una instrucción de compra con un precio máximo sin vigilar continuamente la pantalla. Se evalúa cuando hay cotizaciones locales confirmadas; no es un feed externo en tiempo real.

Propuesta para TASK-059:

- Crear una orden del usuario para un jugador, cantidad entera positiva (sujeta a suministro 100), máximo precio unitario decimal positivo y vencimiento futuro explícito. Propuesta inicial de UI: vencimiento 24 horas editable.
- No reservar saldo ni inventario. Informarlo al crear: alcanzar el precio no garantiza compra si luego no hay fondos o tokens disponibles.
- Evaluar contra la cotización actual autoritativa y estrategia vigente, no contra Redis ni el precio de un evento antiguo. Aceptar si precio actual <= máximo y la orden no venció.
- Estados propuestos: pending, executed, cancelled, expired y rejected. La orden puede cancelarse mientras está pending; carrera con ejecución resuelta mediante bloqueo/compare-and-set en la misma transacción.
- Compra todo-o-nada. Al cumplir precio pero faltar saldo o inventario, propuesta: rejected terminal con motivo visible. El usuario puede crear otra orden; no reintentar una instrucción rechazada silenciosamente.
- Si el precio no cumple, permanece pending. Fallos temporales de infraestructura reintentan el job, no duplican compras ni convierten un fallo técnico en rechazo de negocio.
- Usar el ID de orden como clave de idempotencia y la misma operación de compra existente, con locks y verificación de fondos/inventario. Orden, movimiento de saldo/tokens y operación se confirman atómicamente. No agregar partial fills, venta condicional ni reservas en este alcance.

Estas reglas son propuestas concretas para revisión de producto, no behavior ya implementado. Si el challenge de TASK-059 revela un cambio material, se obtiene la decisión del equipo antes de codificar.

## Entrega durable y seguimiento

Tras confirmar una cotización, registrar la necesidad de evaluar órdenes en la misma transacción de PostgreSQL (job/outbox según plan de implementación), evitando una ventana en que la cotización persista pero se pierda el trabajo. Evaluar también al crear una orden, y recuperar periódicamente órdenes pending, vencimientos y notificaciones pendientes. Concurrencia y retries se apoyan en unicidad más invariantes/locks del dominio; Oban unique por sí solo no garantiza una única compra.

Empezar con concurrencia acotada y ordenar órdenes elegibles por creación más identificador para una política reproducible; TASK-059/060 deben especificar la política y demostrar no sobregiro/sobreventa. No prometer prioridad global estricta ni ejecución instantánea. Emitir PubSub después del commit; recuperar estado por lectura al reconectar. Mostrar estado de importación, cotización y orden por separado.

## PRs y proveedor

PR #27 está mergeado y TASK-016 done: reutilizar sus contratos. PR #28 implementa catálogos actuales de Football-Data.org, con actuaciones e históricos no soportados. Conservarlo como integración opcional, en draft hasta revisión de producto; no contabilizarlo como el scraper ni como fuente suficiente para valoración. Su QA/PASS corresponde a su alcance técnico anterior, no demuestra cumplimiento del nuevo CP2. No merge automático.

## Entregas

CP2: mercado funcional, mínimo frontend autenticado, gráficos, feature adicional completo (dominio, workers y UI), perfiles unit/E2E y demo manual. TASK-056 TTL es mejora de apoyo, posponible frente a requisitos obligatorios. CP3: Redis, invalidación avanzada, métricas, audit, performance y completar/pulir interfaz responsiva.

No implementación de features en esta actualización de planificación. Las tareas mantienen SDD y gates independientes.
