# Consumo por etapa — extensión de TASK-053, 2026-10-01

## Método y cobertura

Reproducir con `python3 scripts/workflow_token_audit.py --stages`. El script separa sesiones por el encabezado de Codex, lee exclusivamente el prompt inicial para atribuir el rol y toma su contador final `tokens used`. Las invocaciones `$speckit-specify/plan/tasks/implement` y los roles explícitos de crítico, QA y reviewer identifican la etapa. No busca nombres de etapas dentro de comandos o respuestas posteriores. Ambigüedades se registran como `unknown`, sin adivinar por posición. Los identificadores de sesión se comparan internamente y nunca se imprimen.

**Cobertura: 100% de los 116 conteos retenidos tiene una etapa identificable.** La suma coincide exactamente con los 7.515.783 tokens reportados en la auditoría anterior. Hay ocho encabezados de intentos sin contador: su consumo es desconocido y no se incluye en los porcentajes. Faltan los logs de TASK-006/007/008/012/014. La muestra no representa el consumo total del proyecto.

### Riesgo detectado en TASK-001

TASK-001 presenta un mismo identificador de sesión en cinco encabezados, tres con conteos finales (37.371, 58.596 y 55.318). Estos datos no establecen si son contadores incrementales o acumulativos. No corresponde deduplicarlos arbitrariamente, ni sumarlos como consumo incremental exacto. Por eso conservamos el análisis de todos los contadores y presentamos como comparación principal la muestra sin TASK-001. Tampoco interpretamos sus etapas ausentes como consumo cero.

## Comparación principal: nueve tareas sin identificadores reutilizados

**Base: 6.492.123 tokens reportados, 102 sesiones con conteo**, en TASK-002/003/004/005/009/010/011/013/015. Las tareas sin logs no aportan al denominador. TASK-015 está inconclusa y puede sesgar el reparto; esta muestra también tiene fallos/reintentos y no es un flujo ideal.

| Etapa | Tokens reportados | % del total | Sesiones con conteo | Primera ejecución medida | Ejecuciones posteriores | % posterior dentro de la etapa |
|---|---:|---:|---:|---:|---:|---:|
| Producto | 446,681 | 6.88% | 11 | 383,697 | 62,984 | 14.1% |
| Crítica de producto | 256,831 | 3.96% | 11 | 211,492 | 45,339 | 17.7% |
| Arquitectura | 658,459 | 10.14% | 10 | 591,102 | 67,357 | 10.2% |
| Planificación de tareas | 480,990 | 7.41% | 10 | 440,500 | 40,490 | 8.4% |
| Desarrollo | 2,501,302 | 38.53% | 25 | 1,089,098 | 1,412,204 | 56.5% |
| QA | 1,673,264 | 25.77% | 24 | 679,358 | 993,906 | 59.4% |
| Revisión final | 474,596 | 7.31% | 11 | 295,318 | 179,278 | 37.8% |

Las cuatro etapas previas al código suman **28,39%**; desarrollo + QA, **64,30%**; revisión final, **7,31%**. Las diferencias de centésimas al sumar se deben al redondeo.

Las ejecuciones posteriores acumulan **2,801,558 tokens (43.15%)**. Las posteriores de desarrollo y QA juntas acumulan **2,406,110 (37.06% del total)**. “Posterior” significa después de la primera sesión con contador para el mismo par task/etapa. Una sesión interrumpida sin contador anterior no cambia esa definición. No significa desperdicio, y no permite atribuir cada repetición a un defecto, feedback o una falla del runner.

## Todos los conteos conservados, incluida TASK-001

| Etapa | Tokens reportados | % del total | Sesiones con conteo | Intentos sin conteo |
|---|---:|---:|---:|---:|
| Producto | 480,929 | 6.40% | 12 | 1 |
| Crítica de producto | 301,314 | 4.01% | 12 | 0 |
| Arquitectura | 658,459 | 8.76% | 10 | 2 |
| Planificación de tareas | 535,125 | 7.12% | 11 | 0 |
| Desarrollo | 2,782,887 | 37.03% | 28 | 2 |
| QA | 1,900,099 | 25.28% | 26 | 1 |
| Revisión final | 856,970 | 11.40% | 17 | 2 |

## Distribución por tarea

Cada porcentaje usa el total de esa tarea como denominador. `—` significa sin sesión medida para esa etapa; no afirma costo cero. “Posteriores” incluye todas las etapas de la tarea, con la definición anterior.

| Task | Producto | Crítica | Arquitectura | Tareas | Desarrollo | QA | Review | Posteriores | Muestra principal |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---|
| TASK-001 | 3.4% | 4.3% | — | 5.3% | 27.5% | 22.2% | 37.4% | 68.5% | sesión reutilizada |
| TASK-002 | 3.6% | 2.6% | 6.4% | 5.8% | 37.1% | 33.6% | 10.8% | 51.2% | incluida |
| TASK-003 | 3.5% | 2.6% | 14.7% | 11.7% | 31.8% | 25.6% | 10.2% | 53.0% | incluida |
| TASK-004 | 13.5% | 9.1% | 17.7% | 10.5% | 21.2% | 27.9% | — | 28.9% | incluida |
| TASK-005 | 5.8% | 3.0% | 9.2% | 6.3% | 43.4% | 22.9% | 9.4% | 53.2% | incluida |
| TASK-006 | — | — | — | — | — | — | — | — | sin log |
| TASK-007 | — | — | — | — | — | — | — | — | sin log |
| TASK-008 | — | — | — | — | — | — | — | — | sin log |
| TASK-009 | 7.5% | 4.6% | 6.8% | 7.4% | 41.4% | 21.2% | 11.1% | 35.8% | incluida |
| TASK-010 | 11.6% | 8.2% | 15.4% | 14.1% | 25.3% | 10.8% | 14.7% | 0.0% | incluida |
| TASK-011 | 8.7% | 3.7% | 5.4% | 4.3% | 41.9% | 26.5% | 9.5% | 60.4% | incluida |
| TASK-012 | — | — | — | — | — | — | — | — | sin log |
| TASK-013 | 10.0% | 5.2% | 19.5% | 7.3% | 30.4% | 27.1% | 0.4% | 21.8% | incluida |
| TASK-014 | — | — | — | — | — | — | — | — | sin log |
| TASK-015 | 4.4% | 2.3% | 6.8% | 5.7% | 53.5% | 27.4% | — | 40.5% | incluida |

## Qué atacar primero

| Prioridad | Evidencia | Ajuste a evaluar | Condición de éxito |
|---|---|---|---|
| 1. Ciclos de desarrollo → QA → desarrollo | Desarrollo 38,53%; QA 25,77%; repeticiones de ambos 37,06% del total | Antes de QA, implementar una matriz breve aceptación → test/comando/archivo y preflight determinista de artefactos, entorno y servicios. Ante FAIL, corregir la discrepancia desde la etapa afectada y preservar decisiones no afectadas | Menos ciclos con todos los criterios verificados; QA conserva ejecución independiente y HTTP real |
| 2. Salida y exploración dentro de desarrollo/QA | Son 64,30% del total medido; el prompt inicial no describe todo el contexto que se carga después | Aplicar la política ya agregada; registrar volumen de salidas y búsquedas por sesión para ubicar lecturas masivas, diffs y comandos repetidos. Mantener output completo local cuando haga falta y mostrar fallos relevantes | Menos tokens por sesión de complejidad comparable sin pérdida de evidencia |
| 3. Arquitectura y generación de tareas | Suman 17,55%; tasks por sí sola 7,41% | Piloto que produzca `plan.md` y `tasks.md` en una sola sesión, con ambos gates y trazabilidad; limitar research a incógnitas concretas | Plan/tasks completos y consistentes; QA/review independientes sin cambios |
| 4. Review | 7,31% de la muestra principal; 37,8% de su propio consumo en ejecuciones posteriores | Reutilizar evidencia fresca de QA y ejecutar pruebas dirigidas; registrar cuándo un FAIL revela un problema que QA debió cubrir | Mantener la segunda perspectiva sin repetir suites completas por defecto |
| 5. Producto y crítico | Suman 10,84% | Mantenerlos independientes; acotar documentos secundarios y resolver feedback sin reabrir decisiones válidas | Misma claridad, seguridad y cobertura con documentos proporcionales |

Una etapa cara puede estar realizando trabajo necesario. El objetivo es reducir exploración y vueltas evitables, no recortar sus verificaciones. Fusionar arquitectura/tasks no elimina automáticamente su 17,55%: buena parte del trabajo sigue siendo necesaria. Ninguna reducción de tokens se midió todavía.

## Qué falta para atribuir el contexto

Los contadores disponibles no separan entrada, salida, razonamiento ni caché. Por lo tanto **no podemos afirmar qué porcentaje exacto corresponde al traspaso de contexto**, a los tests o a escribir código. Los porcentajes aquí son por sesión/etapa, no por actividad interna. Shell gates y aprobación humana no tienen una sesión Codex propia en estos logs: no reciben porcentajes separados y esto no mide supervisión fuera del runner, agentes auxiliares no registrados ni costo del servicio.

El siguiente paso de instrumentación debería registrar por task/etapa/intento: inicio y fin, identificación privada de sesión para evitar solapamientos, estado/veredicto, tokens de entrada/salida/caché cuando el CLI los entregue, causa del reintento y referencia a evidencia. Usar eventos del runner como fuente de etapa futura; mantener el parser de prompts únicamente para el histórico. No alterar sesiones guardadas para obtener métricas retroactivas.

## Cambios de esta extensión

Se agregaron atribución, conciliación de totales, intentos sin contador, primera ejecución/posteriores, detección privada de IDs reutilizados, muestra principal y tests sintéticos. El comando por defecto conserva su formato anterior. No cambiaron etapas, gates, modelos, permisos ni snapshots de TASK-015. Los informes QA/review de TASK-053 se actualizan para revisar esta extensión.
