# Feedback — TASK-006

## Feedback 1

- Time: 2026-09-24T00:14:53+00:00
- Author: sebo
- Restart from: develop

Corregir todos los bloqueos del QA independiente en specs/006-development-seed-data/qa-report.md: (1) alinear el manifiesto implementado y sus tests con los valores estables autoritativos de data-model.md; (2) hacer que Manifest.validate/1 rechace distribuciones inválidas, exigiendo por temporada exactamente dos equipos, cuatro jugadores, dos jugadores por equipo y cobertura única GK/DEF/MID/FWD, con pruebas adversariales; (3) impedir que la salida completa del proceso mix catalog.seed exponga UUIDs u otros datos sensibles mediante logs SQL debug, agregando una prueba real de CLI; (4) garantizar que entornos MIX_ENV desconocidos fallen con el Mix.Error de capability deshabilitada en vez de File.Error, con prueba de proceso. Reejecutar formato, compilación warnings-as-errors, tests focalizados, suite completa, seed fresh/repeat, prueba de conflicto y guards de producción/entorno desconocido.

## Feedback 2

- Time: 2026-09-24T00:33:49+00:00
- Author: sebo
- Restart from: develop

Corregir los tres bloqueos del segundo QA independiente en specs/006-development-seed-data/qa-report.md: (1) Manifest.validate/1 debe rechazar registros estructuralmente incompletos o malformados con {:error, ...} y nunca lanzar KeyError; agregar pruebas adversariales por tipo de entidad/campos requeridos. (2) mix catalog.seed contra PostgreSQL inaccesible debe suprimir logs de conexión, capturar DBConnection/Postgrex exits y devolver solo un Mix.Error sanitizado con causa allowlisted, sin host/puerto, credenciales, excepción cruda, consejos operativos ni stack trace; agregar prueba real de proceso. (3) reemplazar cause=attribute_or_relationship por las causas públicas allowlisted attribute_mismatch o relationship_mismatch según corresponda, con pruebas de ambos casos. Reejecutar formato, compilación warnings-as-errors, tests focalizados, suite completa, seed fresh/repeat, conflicto de atributo y relación, DB inaccesible, producción y entorno desconocido.

## Feedback 3

- Time: 2026-09-24T00:55:51+00:00
- Author: sebo
- Restart from: develop

Final review blocker: align the documented failure taxonomy, service errors, and Mix task output on one explicit public allowlist. Map alternate identity, misplaced relationship, invalid manifest, database/write failures, concurrency, and unavailable database to documented public causes; make the command boundary reject or safely map unknown internal category/cause values instead of interpolating them; add command-level assertions for every failure class; rerun focused and full verification.

