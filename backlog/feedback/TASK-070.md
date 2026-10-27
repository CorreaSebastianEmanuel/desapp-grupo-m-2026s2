# Feedback — TASK-070

## Feedback 1

- Time: 2026-10-25T01:23:25+00:00
- Author: ezequielgonzalez
- Restart from: architecture
- Impact: architecture, verification
- Required regressions: cited discrepancy plus required manifest checks

Incorporar al diseño tres ajustes: (1) para desarrollo iterativo, ejecutar pruebas enfocadas al cambio y checks baratos; al estabilizar el código, ejecutar el manifiesto completo una vez. Evitar que el baseline local vuelva a correr unit e integración completas cuando ya están cubiertas por el manifiesto: sustituirlo por un chequeo rápido de contrato/paridad del wrapper y conservar CI real remoto, QA independiente completo en trabajo financiero/de seguridad/alto riesgo, E2E y aceptación HTTP real. En QA, continuar checks independientes después de un fallo aislado, parar dependencias afectadas por prerrequisitos y nunca repetir más de dos veces el mismo check con inputs iguales. (2) Diseñar una vía Vibecode para cambios pequeños, claros, reversibles y de bajo riesgo: especificación breve y preflight obligatorios, sin sesiones de deliberación redundantes, pruebas enfocadas, CI y revisión proporcional; no aplica a seguridad, finanzas ni cambios del workflow. (3) Paralelizar primero checks estáticos independientes; no ejecutar perfiles Mix/E2E concurrentes hasta aislar build/cache, base de datos, puertos y navegador y probar estabilidad. Medir. Mantener los gates de CI, QA independiente y merge humano; alinear el límite de feedback a tres ciclos o una política explícita de división, sin resets silenciosos.
