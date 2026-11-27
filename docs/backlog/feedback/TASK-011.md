# Feedback — TASK-011

## Feedback 1

- Time: 2026-09-26T23:43:59+00:00
- Author: ezequielgonzalez
- Restart from: product

Decisión humana: GET /api/players debe incluir paginación desde TASK-011. Definir un tamaño de página predeterminado y máximo conservadores, cursor estable basado en el orden documentado, metadatos/continuación inequívocos y pruebas de límites y estabilidad. No mantener una respuesta completa sin límite ni truncar silenciosamente.

## Feedback 2

- Time: 2026-09-27T17:20:41+00:00
- Author: ezequielgonzalez
- Restart from: develop

QA blocker: las solicitudes de continuación registran el valor completo de cursor en los logs de parámetros de Phoenix. Redactar/filtrar el parámetro cursor, agregar una prueba de captura de logs que demuestre ausencia del token completo y del anchor decodificado, y repetir la verificación HTTP real antes de QA.

## Feedback 3

- Time: 2026-09-28T12:24:36+00:00
- Author: ezequielgonzalez
- Restart from: develop

Bloqueo de revisión final: config :phoenix, filter_parameters: ["cursor"] reemplaza los filtros predeterminados de Phoenix y vuelve registrables password y token. Preservar como mínimo ["password", "token", "cursor"], agregar una prueba de regresión sobre la configuración efectiva o logs capturados para los tres nombres sensibles, y repetir las verificaciones de seguridad, QA y revisión final.

