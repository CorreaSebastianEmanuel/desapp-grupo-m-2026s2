# ThinFlow performance policy

La velocidad se obtiene reduciendo sesiones, contexto duplicado y reejecuciones,
no omitiendo salvaguardas. El selector ejecutable vive en
`.agentflow/thinflow.json` y se inspecciona con:

```sh
python3 scripts/thinflow.py select TASK-NNN
```

## Ruta proporcional

- Cambios sólo documentales ejecutan el guard `fast-lane`.
- Cambios del harness, CI, seguridad, permisos, finanzas, persistencia,
  contratos o aplicación usan el perfil high y sus checks mapeados.
- Varias reglas se acumulan y siempre gana el tier más alto.
- Una ruta sin regla, un conjunto vacío, un check ausente o evidencia stale
  bloquean publicación.

El builder usa pruebas enfocadas en su loop. ThinFlow ejecuta los checks
seleccionados una vez sobre el candidato estabilizado. GitHub ejecuta una sola
regresión completa mediante Quality/E2E/Sonar y la resume en `ThinFlow required`.
El evaluador no repite la suite salvo una discrepancia concreta.

## Presupuesto de reparación

Dos fallos con el mismo digest material bloquean un tercer intento. Una tarea
ThinFlow admite un único ciclo de feedback agrupado; otro bloqueo requiere
decisión humana o división. Cambios irrelevantes no reinician presupuestos.

El caché opcional de Mix sigue disponible mediante `scripts/mix_cache.sh`; no
se comparte con CI ni reemplaza evidencia.
