# Speed playbook — fast lane and shared compile cache

Herramientas para acortar wall-clock sin debilitar ningún gate del flujo
(`docs/METODOLOGIA_AGENTICA.md` y `docs/WORKFLOW_OPTIMIZATIONS.md` siguen
mandando). Nada aquí cambia cómo se entrega una tarea de producto; se limita a
(a) una vía proporcional para cambios sin comportamiento y (b) un caché local de
compilación de Mix. Ningún ahorro se declara sin medirlo; ver la sección de
medición al final.

## Fast lane para cambios sin comportamiento

Solo aplica cuando el diff **no toca** código de aplicación. Vía: una sesión +
guard mecánico + CI + PR con merge humano. No hay QA/review sessions porque no
hay comportamiento que verificar ni arquitectura que defender.

Ámbito permitido (fail-closed: lo no listado está prohibido):

- `docs/`, `backlog/`, `.agents/`, `.opencode/`
- `AGENTS.md`, `CLAUDE.md`, `README.md`

Uso antes de abrir el PR:

```sh
python3 scripts/fast_lane_check.py --base origin/main
```

Si el guard deniega, el cambio corre el flujo completo de siempre. El guard es
un chequeo de rutas por prefijo, es mecánico y no reemplaza el juicio humano:
el PR sigue pasando CI y merge manual. Las reglas de `AGENTS.md` (por ejemplo,
la regla 4 sobre tests para cambios de comportamiento) no cambian: lo que
cambia es que, sin código, no hay pruebas de comportamiento que escribir.

## Caché local de compilación compartida

Cada task-worktree nueva recompila `deps/` y la aplicación desde cero. El
wrapper redirige `MIX_DEPS_PATH` y `MIX_BUILD_PATH` a un directorio compartido
en `~/.cache/desapp-grupo-m-2026s2/mix`, particionado por `MIX_ENV`:

```sh
scripts/mix_cache.sh mix test          # un comando con caché
eval "$(scripts/mix_cache.sh --env)"   # exportarlo para toda la sesión
```

Efecto: la compilación fría de Phoenix se paga una vez y las tareas siguientes
reutilizan artefactos. Esperable del orden de minutos por tarea; no se presume
ningún porcentaje hasta medirlo.

Límites y alcances explícitos:

- El caché es **local**: CI (GitHub Actions) mantiene su entorno aislado y jamás
  debe apuntar al cache compartido ni fijar `MIX_*_PATH`.
- Es seguro porque las tareas van una a la vez (`AGENTS.md` regla 1); dos
  tareas concurrentes que compilen a la vez pueden pisar `deps/`. Si algún día
  se paraleliza, particionar el caché por worktree antes que compartirlo.
- Conmutar ramas con cambios de dependencias recompila el delta: comportamiento
  estándar de Mix y nunca invalida el caché de forma destructiva.
- Limpiar el caché es siempre seguro: `rm -rf ~/.cache/desapp-grupo-m-2026s2/mix`.

## Procedimiento proporcional para cambios pequeños (Vibecode)

Opt-in para un cambio claro, reversible y de bajo riesgo. La especificación
breve debe registrar alcance, criterio de aceptación, riesgo y rollback. Ejecutar
preflight del entorno efectivo del hijo y pruebas enfocadas; mantener CI, QA y
review independientes con veredictos PASS proporcionales, además del merge
humano. Resolver decisiones ya asentadas en un único plan breve, sin sesiones
de deliberación redundantes. Una decisión material sin resolver vuelve al flujo
completo.

No aplica a seguridad, autenticación o permisos, finanzas, integridad de datos,
migraciones, contratos externos, cambios del workflow/gates/herramientas ni
cambios de impacto incierto. Lo no clasificado usa el flujo completo. TASK-070
queda explícitamente excluida; este procedimiento no agrega un selector ni un
bypass ejecutable.

## Medición (obligatoria, la prueba está en el resultado)

El [stage token audit](WORKFLOW_STAGE_TOKEN_AUDIT.md) mostró que los reintentos
posteriores al primer intento concentran 43.15% del consumo retenido; atacar
varianza importa más que acortar la secuencia base. Para validar este playbook
sin fabricar ahorros:

1. La próxima tarea de producto corre el protocolo de
   [AGENTFLOW_PILOT.md](AGENTFLOW_PILOT.md) **incluyendo elapsed time por
   etapa**, que `metrics.jsonl` ya registra: `./agentflow metrics TASK-NNN`.
2. Comparar wall-clock y rondas de feedback antes/después de adoptar el fast
   lane y el caché en tareas de la misma índole.
3. Bajo la política de evidencia vigente, los porcentajes restan desconocidos
   mientras no haya la comparación reproducible de dos tareas equivalentes.

## Fuera de alcance

- Correr QA y review en paralelo, automaticar merges o saltar el crítico de
  producto: son la independencia que sostiene el `Verdict: PASS`.
- Reintentos de harness tipo Harness² (ejecuciones candidatas por tarea): es
  costoso por diseño y su retorno está desbalanceado frente a este flujo con
  ground truth ejecutable en los gates.
