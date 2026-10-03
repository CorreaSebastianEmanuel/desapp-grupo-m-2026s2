# Feedback — TASK-015

## Feedback 1

- Time: 2026-10-03T12:41:19+00:00
- Author: ezequielgonzalez
- Restart from: develop

Cerrar TASK-015 junto con TASK-053 en un único PR, conservando las optimizaciones verificadas y el snapshot del run. Corregir los cuatro bloqueos de qa-report.md: validar contenido/esquema/SHA de dos demos y recibos de perfiles/cobertura antes de hosted PASS; ejecutar y comprobar viajes HTTP reales sin emitir credenciales; bloquear JWT y demás sentinelas inseguros con regresiones; documentar y activar toolchain reproducible incluyendo Node 24. Aplicar política de contexto acotado, evidencias concisas y checks completos; QA y revisión independientes deben dar PASS antes de publicar. No debilitar requisitos ni declarar CP1 hosted PASS antes de su evidencia exact-SHA. El PR debe mencionar también TASK-053, que ya tiene ambos PASS. Excluir tmp y documentos personales de la publicación.

## Feedback 2

- Time: 2026-10-03T12:43:23+00:00
- Author: ezequielgonzalez
- Restart from: develop

Corrección técnica del runner durante el piloto: el parser confundía un gate anidado con una etapa principal en snapshots YAML sin indentación. El índice de rewind ya fue corregido y probado. Reejecutar desarrollo e incorporar el feedback anterior antes de QA; no reutilizar handoff de desarrollo previo.

## Feedback 3

- Time: 2026-10-03T13:25:09+00:00
- Author: ezequielgonzalez
- Restart from: develop

Corregir los cuatro bloqueos B1–B4 del nuevo qa-report.md antes de publicar el PR: B1 correlacionar branch gobernante e identidad exacta de workflow además de nombre/SHA/status; B2 exigir recibos locales reales completos y pruebas/referencias accesibles para todo PASS clean-commit, no permitir ausencia opcional de local-evidence; B3 rechazar valores secretos en JSON citado (password, api_key_secret, secret_hash, provider_payload) y no publicarlos en observed/JSON/Markdown; B4 validar/stagear/publicar cobertura real generada por mix test.cp1_coverage sin confundir código fuente HTML legítimo con capturas de credenciales, manteniendo seguridad de runtime. Añadir regresiones de las reproducciones adversarias y cobertura HTML real, ejecutar checks y demos requeridos, actualizar guía/handoff concisos. QA observó 19 Python/7 CP1/195 baseline, perfiles completos y dos demos PASS, pero el agregado final FAIL. Conservar políticas de producto y TASK053. Ver qa-report.md y probes sanitizados referenciados solo si son necesarios para reproducir cada defecto.
