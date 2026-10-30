# Arquitectura completa CP2 — versión acordada (octubre 2026)

Frecuencia diaria de recálculo. El diagrama está dividido en dos flujos:
**de día** (lo que dispara el usuario) y **de noche** (lo que hace el sistema solo).

## Cómo leer las formas

| Forma | Significa | Qué es |
|---|---|---|
| 🗄 **Cilindro** | Base de datos / tabla | PostgreSQL: donde TODO queda guardado, incluida la cola |
| ⚙️ **Rectángulo** | Servicio | Lógica del negocio ejecutándose ahora (atiende al usuario) |
| ⏰ **Rectángulo** (zonas "Workers") | Worker | Proceso de fondo: trabaja sin que nadie espere (cola Oban) |
| ☁️ Caja gris | Externo | Proveedor de datos deportivos (refresh por demanda durante el día y sync nocturno) |
| Línea **llena** | Llamada / espera → | "a destino" |
| Línea **punteada** | Aviso opcional (PubSub) | nunca es la fuente de verdad, solo despierta a la pantalla |

La clave conceptual: **la cola NO es un servidor aparte — es una tabla dentro de PostgreSQL**.
Eso es lo que hace a Oban "durable": si el servidor muere, el trabajo queda en la base.

## Diagrama 1 — DE DÍA (lo que dispara el usuario)

```mermaid
flowchart TB
    subgraph UX["🖥️ PANTALLAS — lo que el usuario ve (solo lee y pide)"]
        direction LR
        P1["Búsqueda y ficha<br/>(lectura local + refresh de stats si vencen)"]
        P2["Comprar / vender"]
        P3["Órdenes condicionales"]
        P4["LiveView (se refresca sola)"]
    end

    subgraph SVC["⚙️ SERVICIOS — la lógica del negocio (rectángulos = código ejecutándose ahora)"]
        direction LR
        S1["Motor de compra / venta<br/>(transacción atómica e idempotente)"]
        S2["Gestor de órdenes"]
    end

    subgraph DB["🗄️ BASE DE DATOS — PostgreSQL: única autoridad (cilindros = tablas donde todo queda guardado)"]
        direction LR
        D1[("Datos del mercado:<br/>catálogo · estadísticas · cotizaciones")]
        D2[("Estado del usuario:<br/>saldo · tokens · compras · órdenes")]
        Q[("📬 COLA DE JOBS:<br/>¡es solo UNA TABLA dentro de<br/>esta misma base! (Oban)")]
    end

    P1 -->|"1 · lectura instantánea"| D1
    P1 -->|"si vencen estadísticas: pedir refresh asíncrono"| Q
    P2 -->|"2 · pide operar"| S1
    P3 -->|"2 · crea / cancela"| S2
    S1 -->|"3 · escribe TODO en una sola transacción"| D2
    S2 -->|"3 · escribe la orden"| D2
    S2 -->|"4 · deja trabajo encolado para después"| Q
    S1 -.->|"5 · aviso (PubSub): algo cambió → relee"| P4
    S2 -.->|"5 · aviso (PubSub): algo cambió → relee"| P4
```

## Diagrama 2 — DE NOCHE (lo que el sistema hace sin nadie esperando)

```mermaid
flowchart TB
    Q_STATS[("📬 COLA DE REFRESH<br/>(Oban durable en PostgreSQL)")]
    PENDING[("Solicitudes de cotización<br/>pendientes en PostgreSQL")]
    Q_QUOTES[("📬 COLA DE CÁLCULO<br/>(Oban, admitida al cierre)")]
    Q_EVAL[("📬 EVALUACIONES<br/>(trabajo durable)")]
    D1[("🗄️ DATOS DEL MERCADO<br/>estadísticas · cotizaciones<br/>(cotizaciones: INSERT, nunca UPDATE)")]
    D2[("🗄️ ESTADO DEL USUARIO<br/>saldo · tokens · compras")]
    S1["⚙️ SERVICIO Motor de compra/venta<br/>(el MISMO que atiende las pantallas)"]
    EXT["☁️ PROVEEDOR EXTERNO<br/>refresh por demanda o sync nocturno"]
    CLOSE["Cierre nocturno<br/>por liga/temporada"]

    subgraph WK["⏰ WORKERS — procesos de fondo (una lista de tareas que van cumpliendo)"]
        direction TB
        W1["Worker ESTADÍSTICAS —<br/>busca, valida y persiste hechos"]
        W2["Worker COTIZACIÓN —<br/>calcula con hechos aceptados"]
        W3["Worker EVALUADOR —<br/>decide ejecutar o esperar"]
    end

    Q_STATS -->|"por demanda durante el día o sync"| W1
    W1 -->|"consulta fuente"| EXT
    W1 -->|"guarda estadísticas aceptadas"| D1
    W1 -->|"si cambian hechos: registra solicitud pendiente; no calcula"| PENDING
    CLOSE -->|"admite pendientes + respaldo TTL"| Q_QUOTES
    PENDING --> CLOSE
    Q_QUOTES -->|"solo tras el cierre"| W2
    W2 -->|"cotización inmutable + evento de evaluación atómicos"| D1
    W2 --> Q_EVAL
    Q_EVAL --> W3
    W3 -->|"si el precio cumple → solicita compra"| S1
    S1 -->|"compra atómica e idempotente"| D2
```

Imágenes renderizadas: `cp2_dia.png` y `cp2_noche.png` (en esta misma carpeta).

## El ritmo del sistema en un día

| Hora | Qué pasa |
|---|---|
| Todo el día | Búsqueda local; abrir una ficha puede encolar refresh deduplicado de estadísticas vencidas. Los hechos aceptados se guardan y se muestran al confirmarse; el precio sigue siendo el del cierre anterior. |
| 00:00 | Cierre programado por liga/temporada: admite solicitudes pendientes de hechos cambiados y el respaldo TTL en la cola de cálculo de cotizaciones |
| 00:00–0X | Worker calcula solo con estadísticas aceptadas y persistidas; inserta la cotización inmutable y el evento de evaluación en la misma transacción |
| 00:0X | El evento despierta el worker de Oban, que evalúa las órdenes pendientes de ese jugador: cumplió el precio → compra atómica delegada; no cumplió → queda `pending`; sin saldo/tokens → `rejected` |
| Cada 1 min | Barrido de seguridad repara jobs perdidos, vence órdenes expiradas, retoma pasadas cortadas |
| Post-commit | PubSub avisa el LiveView, que relee de PostgreSQL (el mensaje es solo aviso, nunca autoridad) |

## Decisiones que defendemos

| # | Decisión | Por qué |
|---|---|---|
| 1 | Precio cambia en el cierre nocturno (recálculo diario) | Los hechos se pueden actualizar durante el día; solo el cierre actualiza el precio. El disparo postpartido queda como posible evolución futura, no como la regla vigente |
| 2 | La ficha puede pedir refresh asíncrono de estadísticas vencidas | Las estadísticas aceptadas se actualizan al confirmarse; consultar una ficha no recalcula ni cambia la cotización del día |
| 3 | Búsqueda 100% local (Redis CP3 como caché, PostgreSQL autoridad) | La falla del proveedor nunca rompe lecturas (invariante 6) |
| 4 | Sin bloqueo de mercado durante el recálculo | La cotización se inserta; el trading siempre lee la vigente y su fecha efectiva |
| 5 | Cotizaciones inmutables, versionadas y reproducibles | Invariante 7: mismos inputs + estrategia → mismo precio. Nadie "mueve" el precio |
| 6 | Todo lo que puede ejecutarse más de una vez va por Oban | Cola durable: at-least-once + idempotencia del dominio = efectivamente una vez |
| 7 | Una sola transacción por operación | Orden + compra + saldo + tokens se confirman juntos, o no existen |
| 8 | PostgreSQL es autoridad; PubSub solo aviso | Reconectar no pierde nada: la pantalla relee la base |

## Frase síntesis para la diapositiva

> "Arquitectura event-driven duradera: PostgreSQL es la única autoridad; las estadísticas aceptadas pueden actualizarse durante el día, mientras que la cotización cambia solo en el cierre nocturno; cada cotización confirmada despierta —en la misma transacción— la evaluación de órdenes; y toda compra, manual o condicionada, se ejecuta con el mismo motor atómico e idempotente."

## Limitación declarada y camino elegido

Si un partido ocurre durante el día, las estadísticas pueden reflejarlo cuando se confirme un
refresh; la cotización lo reflejará en el cierre nocturno — una ventana de hasta ~24 h. El camino
vigente es el cierre diario. Un futuro disparo postpartido podría reutilizar el mismo pipeline
(ingesta → cotización → evaluación de órdenes), pero no reemplaza ni modifica la cadencia
nocturna acordada para esta entrega.
