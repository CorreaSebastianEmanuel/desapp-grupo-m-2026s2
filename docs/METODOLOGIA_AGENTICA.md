# Metodología de trabajo: ThinFlow

La metodología conserva SDD donde aporta valor: un contrato de resultado
pequeño, un dueño de implementación, sensores determinísticos y una mirada
independiente antes del merge. Evita usar agentes para producir documentos o
handoffs que no cambian una decisión.

## Principios

1. `spec.md` expresa Outcome, Acceptance, Scope, Non-goals, Risk y decisiones
   materiales. Es comportamiento, no un diseño prescriptivo.
2. Un builder mantiene el contexto desde el contrato hasta el candidato.
3. `.agentflow/thinflow.json` selecciona checks por rutas y máxima severidad.
   Lo desconocido no obtiene un PASS por inferencia.
4. Un evaluador no-builder revisa aceptación, riesgo, arquitectura, seguridad,
   regresión y evidencia. No modifica la implementación.
5. La reparación es agrupada: vuelve al builder una vez. La recurrencia exige
   decisión humana o una tarea más pequeña.
6. `ThinFlow required` agrega Quality, E2E y Sonar para el SHA publicado. El
   merge sigue siendo humano.

## Artefactos

| Artefacto | Cuándo existe |
|---|---|
| Backlog task | Intención y prioridad |
| `spec.md` | Siempre; contrato compacto |
| Código y tests | Cuando el outcome lo requiere |
| ADR o contrato | Sólo para una decisión o interfaz durable |
| `evaluation.md` | Un dictamen independiente |
| Recibos locales | Siempre que corre un check; nunca versionados |

`plan.md`, `tasks.md`, research, data-model, quickstart y handoffs no son
obligatorios en ThinFlow. El workflow 2.3 se conserva únicamente para reanudar
runs históricos. Véase [THINFLOW.md](THINFLOW.md).
