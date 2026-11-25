# Feedback — TASK-050

## Feedback 1

- Time: 2026-11-25T02:36:45+00:00
- Author: shebi
- Restart from: develop
- Impact: verification
- Required regressions: cited discrepancy plus required manifest checks

El perfil unitario pasó la preparación de Dialyzer tras calentar la caché, pero falla reproduciblemente en test.scripts.sobelow_ci_test.SobelowCiTest.test_real_finding_and_recovery_reach_the_pr_summary, línea 307. En un checkout bajo /tmp con fixture temporal hermano, Sobelow elimina el segmento ../ inicial del root relativo y emite quality-summary-control-*/lib/probe.ex. normalize_finding_paths no reconoce esa variante exacta y el resumen genera un enlace con el nombre del fixture. Corregir en forma acotada la normalización del root relativo exacto ante esta representación, con regresión y controles negativos, sin suprimir hallazgos ni cambiar gates. Comprobar también la variante de ruta actual. Conservar alcance defensivo de TASK-050 y ejecutar el caso focalizado antes de devolver a ThinFlow.

