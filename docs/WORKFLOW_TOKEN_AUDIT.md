# Auditoría de tokens del workflow — 2026-10-01

## Alcance y método

Auditoría del proceso de TASK-001 a TASK-014 y del avance de TASK-015, con sus cambios preexistentes preservados. No es una nueva validación funcional de cada feature: los PASS de la tabla son los veredictos registrados, no pruebas ejecutadas hoy.

Reproducción: `python3 scripts/workflow_token_audit.py`. Lee metadata del backlog, volumen de Markdown canónico y logs retenidos de Agentflow. La salida contiene exclusivamente métricas y estados; no imprime conversaciones, credenciales ni feedback. La lectura de logs es excepcional para este diagnóstico del runner, no una instrucción para etapas de producto.

## Evidencia por tarea

| Task | Estado | Palabras artefactos | Palabras handoffs | Sesiones con conteo | Tokens reportados | Invocaciones runner | QA/review registrados |
|---|---|---:|---:|---:|---:|---:|---|
| TASK-001 | done | 15533 | 7607 | 14 | 1,023,660 | 23 | PASS/PASS |
| TASK-002 | done | 8212 | 1641 | 14 | 798,372 | 8 | PASS/PASS |
| TASK-003 | done | 9184 | 1635 | 14 | 857,948 | 3 | PASS/PASS |
| TASK-004 | done | 9553 | 1600 | 9 | 423,707 | 3 | PASS/PASS |
| TASK-005 | done | 9186 | 1688 | 13 | 718,856 | 6 | PASS/PASS |
| TASK-006 | done | 9911 | 1668 | sin log | desconocido | — | PASS/PASS |
| TASK-007 | done | 6933 | 1405 | sin log | desconocido | — | PASS/PASS |
| TASK-008 | done | 7744 | 1321 | sin log | desconocido | — | PASS/PASS |
| TASK-009 | done | 8848 | 1735 | 12 | 673,722 | 3 | PASS/PASS |
| TASK-010 | done | 9181 | 1736 | 7 | 346,319 | 1 | PASS/PASS |
| TASK-011 | done | 9820 | 1659 | 15 | 1,109,274 | 5 | PASS/PASS |
| TASK-012 | done | 9329 | 1166 | sin log | desconocido | — | PASS/PASS |
| TASK-013 | done | 9261 | 1357 | 9 | 590,573 | 4 | PASS/PASS |
| TASK-014 | done | 9271 | 1710 | sin log | desconocido | — | PASS/PASS |
| TASK-015 | blocked | 10185 | 1835 | 9 | 973,352 | 5 | FAIL/— |

Total observado: **7.515.783 tokens reportados en 116 sesiones**, en diez logs. Cinco tareas no tienen log retenido. Nueve de los logs corresponden a tareas finalizadas y uno a TASK-015. Los quince directorios suman **142.151 palabras** de artefactos; esto mide documentación, no tokens consumidos.

Limitaciones: `tokens used` no separa entrada, salida, razonamiento ni caché y no permite calcular facturación. Los logs pueden estar incompletos, incluir varios intentos o carecer de sesiones interrumpidas. Su suma es consumo reportado conservado, no el total exacto del proyecto. Una invocación `resume` puede no ejecutar agentes. Una sesión adicional puede venir de feedback, una revisión repetida o una etapa del workflow antiguo: no equivale automáticamente a desperdicio.

## Hallazgos

1. **El runner no pasa el historial entero a cada agente.** `agentflow.task_context` pasa la tarea y feedback a la entrada de producto. En Spec Kit instalado, `workflows/steps/command/__init__.py` resuelve el input de la etapa y `workflows/steps/prompt/__init__.py` resuelve su prompt; la integración `integrations/codex/__init__.py` inicia `codex exec`. El workflow no interpola las conversaciones de etapas anteriores. No encontramos una inyección automática de logs como causa del costo. Esta observación aplica a esta instalación y definición.
2. **Sí hay reconstrucción reiterada de contexto desde archivos.** Cada rol arranca su sesión y vuelve a leer documentos. Spec, plan y tasks reaparecen en desarrollo, QA y review; además se producen research, data-model, contratos, quickstart y handoffs. Las tareas recientes siguen alrededor de 9.000 palabras de documentación. Es una fuente plausible de costo, pero estos logs no permiten atribuirle un porcentaje exacto.
3. **El feedback humano es pequeño:** 89–351 palabras por archivo existente. Reducirlo o resumirlo tendría poco beneficio frente al riesgo de perder instrucciones. Se conserva íntegro.
4. **Hay repeticiones significativas.** El flujo actual tiene siete roles con agentes. Los diez logs acumulan 46 sesiones por encima de siete por tarea; es una comparación orientativa, porque hubo versiones con más etapas. TASK-010 registra siete sesiones/346.319 tokens; TASK-011, quince/1.109.274. La diferencia no demuestra causalidad porque cambian complejidad, modelo y requisitos. Sí justifica medir ciclos y motivos antes de optimizar.
5. **TASK-001 es un caso histórico atípico:** sus handoffs suman 7.607 palabras frente a 1.166–1.835 en las otras tareas. Los límites recientes ya redujeron ese volumen; no corresponde proyectar ese ahorro histórico sobre el workflow actual.
6. **Parte de la optimización ya existe.** La versión previa limita handoffs, restringe lecturas, evita analizar todo el backlog y pide al revisor reutilizar evidencia fresca de QA. También mantiene gates baratos para artefactos ausentes y QA fallida. No proponemos esas reglas como novedades.
7. **TASK-015 sigue bloqueada:** QA registrado FAIL, sin review final. Sus nueve sesiones/973.352 tokens y cinco invocaciones ameritan resolver el bloqueo concreto antes de reejecutar etapas anteriores. Esta auditoría no la reanuda ni modifica su run.

## Mejora aplicada

Workflow 2.2.3 referencia `docs/AGENT_CONTEXT_POLICY.md` en sus siete roles. Exige leer una vez los documentos requeridos por sesión, buscar en rutas relevantes, inspeccionar diffs por archivo, mostrar resultados y fallos en vez de logs completos, evitar reproducir hechos canónicos en documentos secundarios y finalizar con referencias en vez de copiar informes. En feedback se preservan artefactos no afectados y decisiones ya resueltas.

Los documentos canónicos se leen completos; la regla limita exploración y duplicación, no requisitos. QA conserva sus pruebas independientes y HTTP real cuando corresponde; review conserva su criterio propio y pruebas específicas. No cambian modelos, permisos, siete roles, gates, feedback ni requisitos de skills. Se agregó un script reproducible y tests para conteos, datos faltantes, veredictos y salida sin contenido de logs.

Es una mejora de instrucciones, no un límite técnico de contexto: su ahorro real debe medirse en tareas futuras. Los límites previos tampoco garantizan por sí solos que los agentes los cumplan.

## Próximos experimentos, en orden

| Cambio | Beneficio esperado | Condición antes de aplicarlo |
|---|---|---|
| Registrar métricas por etapa e intento al terminar cada sesión | Saber qué parte consume y por qué se repite | Definir captura compatible con el CLI instalado, con tokens de entrada/salida/caché cuando estén disponibles; evitar duplicar conteos en resumes |
| Clasificar fallos QA/review y corregir desde la primera etapa afectada | Evitar ciclos completos para defectos locales | Conservar regresiones, evidencia vigente y la segunda verificación |
| Planificación proporcional: artefactos secundarios breves y referencias a contratos existentes | Menos documentación redundante | Ajustar skill/plantillas sin perder contratos ni archivos exigidos por tasks |
| Unificar arquitectura y generación de tasks en una sesión | Evitar reconstruir spec/plan y una sesión de planificación | Experimento con trazabilidad y gates; no tocar independencia del crítico, implementación, QA o review |
| Resumir la salida en consola del runner y conservar logs locales | Reducir contexto del agente que supervisa | Preservar mensajes y entrada de gates humanos, errores y progreso; no suprimirlos a ciegas |

No recomendamos comprimir spec/plan mediante resúmenes, retirar QA, cambiar modelos indiscriminadamente o prometer un porcentaje de ahorro sin una comparación controlada. Evaluar próximos runs por tokens/sesión y tarea, ciclos, causas de fallos y cobertura de aceptación; comparar trabajos de complejidad semejante.

## Adopción

Las dos definiciones del workflow están sincronizadas. Nuevos runs cargarán la política. `agentflow resume` utiliza el snapshot del run existente: TASK-015 no adopta esta versión automáticamente. Su snapshot se preservó. Al retomar, el agente supervisor puede seguir la política; una migración del run exige revisar explícitamente compatibilidad y etapas ya aprobadas, sin reiniciar trabajo validado. No usar feedback artificial solo para actualizar el snapshot.

Verificación de esta mejora: suite Python de `tests/`, chequeos del probe y revisión independiente registrados en `specs/053-workflow-token-audit/`. Sin publicación, commit ni merge en esta intervención.

## Extensión: distribución por etapa

Ver [Consumo por etapa](WORKFLOW_STAGE_TOKEN_AUDIT.md) y ejecutar `python3 scripts/workflow_token_audit.py --stages`. La extensión atribuye todos los conteos retenidos y detecta identidades de sesión reutilizadas en TASK-001; su comparación principal excluye esa tarea porque los logs no determinan si sus contadores se solapan. El total anterior sigue siendo una suma de reportes conservados, no consumo incremental ni facturación.

## Ajustes implementados

El usuario autorizó aplicar las mejoras: [workflow 2.3.0](WORKFLOW_OPTIMIZATIONS.md) incorpora planificación conjunta, readiness ejecutable, captura estructurada y compatibilidad con snapshots. Las mediciones históricas no cambian y todavía no prueban un ahorro realizado.
