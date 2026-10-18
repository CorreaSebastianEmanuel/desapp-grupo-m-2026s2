# Flujo de desarrollo (vista completa)

Vista consolidada del flujo Agentflow v2.3 + ledger de lecciones. El detalle
normativo vive en [METODOLOGIA_AGENTICA.md](METODOLOGIA_AGENTICA.md) y las
optimizaciones de etapas en [WORKFLOW_OPTIMIZATIONS.md](WORKFLOW_OPTIMIZATIONS.md).

```mermaid
flowchart TD
    LS[(docs/WORKFLOW_LESSONS.md<br/>ledger de lecciones)]

    IN([Siguiente tarea del backlog]) -->|el flujo LEE el ledger<br/>regla 2 de AGENTS.md| START[Selección de tarea<br/>click en dependencias ready]

    subgraph SES["Sesiones 1-2 · Producto"]
        P[Agente de producto<br/>spec.md] --> C[Critico independiente<br/>product-challenge]
        C --> H{Decisión material<br/>humana?}
    end

    START --> P

    subgraph SES3["Sesión 3 · Arquitectura"]
        A[Arquitecto: arquitectura + plan + tasks<br/>en una sesión]
    end

    H -->|sí: aprueba| A
    H -->|no: ajusta| P

    A -->|plan.md + tasks.md + verification.json| G1[Gate de artefactos y readiness]
    G1 --> DEV[Implementador<br/>código + tests + docs]
    DEV --> GV[Gate de frescura, cobertura<br/>y checks con receipts]
    GV --> Q[QA independiente adversarial]
    Q --> GQ{PASS?}
    GQ -->|no| FB
    Q -->|sí| R[Review final independiente]
    R --> GR{PASS?}

    GR -->|sí| PR[Agentflow: commit + push + PR]
    PR --> HM{Merge humano}
    HM -->|aprueba| DONE([Tarea completada])
    HM -->|solicita cambios| FB[Feedback versionado<br/>máximo 3 ciclos]
    GR -->|no| BLOCK[BLOCKED con evidencia]
    BLOCK --> FB

    FB -->|rebobina a la etapa más<br/>temprana afectada| P
    FB --> WR
    DONE --> WR[Append ≤ 3 líneas al ledger<br/>regla 11]
    WR --> IN

    LS -.lectura al iniciar.-> START
    WR -.escritura.-> LS

    classDef ledger fill:#FDE68A,stroke:#92400E,color:#451A03,stroke-width:2px;
    classDef gate fill:#EDE9FE,stroke:#7E22CE,color:#3B0764;
    classDef human fill:#FDBA74,stroke:#9A3412,color:#431407;
    class LS,WR ledger;
    class G1,GQ,GR gate;
    class H,HM human;
```

## Puntos clave

- **Seis sesiones independientes**: producto, crítico, arquitectura (arquitectura +
  plan + tasks en una sesión), implementación, QA y review final.
- **Dos PASS independientes** (QA y review) son condición para el PR; el merge
  siempre es humano.
- **Feedback versionado** rebobina a la etapa más temprana afectada; los
  artefactos ya aprobados se conservan intactos.
- **Ledger de lecciones**: la única memoria cross-task del flujo. Se lee al
  iniciar toda tarea y se escribe (máximo tres líneas) al completar o grabar
  feedback. Los archivos `backlog/feedback/` por tarea quedan intactos y son
  la fuente canónica.
