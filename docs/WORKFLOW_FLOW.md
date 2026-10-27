# Flujo de desarrollo

ThinFlow 3.0 es el default para tareas nuevas. El contrato operativo completo
está en [THINFLOW.md](THINFLOW.md).

```mermaid
flowchart TB
    subgraph OLD["ANTES · Agentflow 2.3"]
        direction LR
        O0[Tarea] --> O1["1 · Producto<br/>spec + handoff"]
        O1 --> O2["2 · Crítico<br/>challenge + decisión"]
        O2 --> O3["3 · Arquitectura<br/>plan + tasks + manifest"]
        O3 --> O4["4 · Desarrollo<br/>código + receipts + handoff"]
        O4 --> O5["5 · QA<br/>repite checks + report"]
        O5 --> O6["6 · Review<br/>otro report"]
        O6 --> O7[PR]
        O5 -.->|"FAIL · rebobina etapas<br/>hasta 3 ciclos"| O1
        O6 -.->|"FAIL · nuevo ciclo"| O4
    end

    subgraph NEW["AHORA · ThinFlow 3.0"]
        direction LR
        N0["Tarea con outcome"] --> N1["spec.md compacto"]
        N1 --> N2["1 · Builder único"]
        N2 --> N3{"Riesgo + checks<br/>determinísticos"}
        N3 -->|PASS| N4["2 · Evaluador<br/>contexto fresco"]
        N4 -->|PASS| N5[Un PR]
        N5 --> N6{"ThinFlow required<br/>Quality + E2E + Sonar"}
        N6 -->|PASS exact head| N7[Merge humano]
        N3 -.->|FAIL| NR["Una reparación<br/>agrupada"]
        N4 -.->|"Sólo blocker<br/>con evidencia"| NR
        NR -.-> N2
    end

    O7 --> OC["CI + merge humano"]
```

Puntos de control:

- El diff real determina el riesgo; rutas desconocidas fallan cerradas.
- El builder itera con pruebas enfocadas. La regresión completa corre una vez
  en CI y no se duplica entre agentes.
- Existe un solo dictamen independiente, `evaluation.md`.
- Un segundo bloqueo requiere decisión humana o dividir la tarea.
- Los runs 2.3 guardados continúan con su snapshot original.
