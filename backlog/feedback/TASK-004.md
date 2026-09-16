# Feedback — TASK-004

## Feedback 1

- Time: 2026-09-16T21:13:05+00:00
- Author: ezequielgonzalez
- Restart from: product

El repositorio no aceptará contribuciones desde forks. Todos los cambios se realizan en ramas internas y confiables; por lo tanto, el análisis de SonarCloud debe ejecutarse obligatoriamente en cada pull request y en main, sin flujo especial para contextos no confiables.

## Feedback 2

- Time: 2026-09-16T22:23:56+00:00
- Author: ezequielgonzalez
- Restart from: qa

El PR interno #10 ya fue publicado en https://github.com/CorreaSebastianEmanuel/desapp-grupo-m-2026s2/pull/10. La ejecución alojada de Quality baseline pasó; SonarCloud falló porque el repositorio no tiene SONAR_TOKEN y el proyecto/organización aún no están vinculados. Se agregó set -o pipefail con contrato automatizado y se publicó el commit bc08750. Revalidar la evidencia real del PR; no exigir evidencia post-merge de main para declarar el PR listo, ya que los agentes no están autorizados a fusionar. Mantener la evidencia post-merge como requisito posterior de aceptación de TASK-004.

