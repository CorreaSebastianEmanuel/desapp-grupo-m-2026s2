# Arquitectura interactiva — Football Player Market

Abre [el diagrama HTML interactivo](arquitectura_interactiva.html) en un navegador. Selecciona uno de los cinco flujos y avanza con los controles, con las flechas del teclado o con la barra espaciadora. Al seleccionar un componente del mapa, el diagrama salta al primer paso que lo utiliza.

## Componentes

- **Navegador / cliente API:** accede por LiveView o REST/JSON.
- **Phoenix web:** router, controladores, LiveView y autenticación de navegador/API.
- **Contextos de dominio:** Accounts, Catalog, Statistics, Quotes, Valuation, Market, Ranking y Analytics. Aplican las reglas del producto y no exponen payloads externos al dominio.
- **Oban y workers:** ejecutan sincronización, ingesta, cotizaciones, evaluación de órdenes y recuperación dentro del despliegue de la aplicación.
- **PostgreSQL / Ecto:** autoridad de datos de dominio e historial; también almacena los trabajos durables de Oban.
- **Adaptadores de proveedores:** consultan fuentes deportivas configuradas y validan los datos externos.
- **Phoenix PubSub:** avisa cambios confirmados a LiveView; la interfaz relee el estado persistido.
- **Telemetría y logs:** instrumentación transversal del endpoint y los jobs.

## Flujos disponibles

1. **Buscar jugador:** consulta el catálogo local. No necesita un proveedor externo ni una caché.
2. **Actualizar estadísticas:** el refresh es asíncrono; los hechos aceptados se persisten y una intención de cotización espera al cierre.
3. **Cierre nocturno:** Oban Cron admite los cálculos pendientes; se inserta una cotización inmutable y un evento durable de evaluación.
4. **Evaluación de orden condicional:** no hay un listener continuo de jugadores. Al confirmar una cotización, Quotes guarda atómicamente el evento y el primer job Oban en PostgreSQL. Un worker acepta el evento y encola el pase; también se solicita evaluación al crear una orden y mediante recuperación periódica. El pase captura y revisa todas las órdenes pendientes de todos los jugadores en orden estable. Cada orden se compara con la cotización vigente de su propio jugador; solo las que cumplen el límite pueden comprar. PostgreSQL persiste los jobs y resultados, Oban ejecuta el trabajo y PubSub avisa a la interfaz después del commit.
5. **Comprar / vender:** las operaciones validan cotización, saldo e inventario y actualizan movimientos e historial atómicamente e idempotentemente.

## Alcance y lectura

Es el mapa de la topología CP2 documentada en `docs/ARCHITECTURE.md` y `docs/CP2_ARCHITECTURE.md`, con nombres contrastados contra `lib/football_market/application.ex`, `lib/football_market_web/router.ex` y `config/synchronization.exs`.

El HTML muestra una sola topología y no cambia entre despliegues. No dibuja Redis en los recorridos: el adaptador de conectividad existe, pero el caché de búsquedas/ranking está planificado para CP3. Tampoco representa un servidor de cola aparte: Oban corre en la aplicación y persiste jobs en PostgreSQL. Los proveedores externos solo se consultan cuando el adaptador y el alcance están configurados.

Las líneas y los pasos representan handoffs del flujo, no servicios desplegados por separado. Dentro de la aplicación, Phoenix, los contextos, los workers, PubSub y la telemetría forman parte del mismo monolito modular.
