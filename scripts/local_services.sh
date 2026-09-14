#!/bin/sh
set -eu

project=football_market_local
compose="docker compose --project-name $project"
lock_dir="${TMPDIR:-/tmp}/football_market_local_services.lock"

release_lock() {
  [ ! -f "$lock_dir/pid" ] || [ "$(cat "$lock_dir/pid" 2>/dev/null || true)" != "$$" ] || rm -f "$lock_dir/pid"
  rmdir "$lock_dir" 2>/dev/null || true
}

acquire_lock() {
  elapsed=0
  while ! mkdir "$lock_dir" 2>/dev/null; do
    owner=$(cat "$lock_dir/pid" 2>/dev/null || true)
    case "$owner" in
      ''|*[!0-9]*) owner_alive=0 ;;
      *) kill -0 "$owner" 2>/dev/null && owner_alive=1 || owner_alive=0 ;;
    esac

    if [ "$owner_alive" -eq 0 ] && [ "$(cat "$lock_dir/pid" 2>/dev/null || true)" = "$owner" ]; then
      rm -f "$lock_dir/pid"
      rmdir "$lock_dir" 2>/dev/null || true
      continue
    fi

    elapsed=$((elapsed + 1))
    [ "$elapsed" -lt 30 ] || {
      echo "local services: another lifecycle operation did not finish within 30 seconds" >&2
      exit 1
    }
    sleep 1
  done
  printf '%s\n' "$$" >"$lock_dir/pid"
  trap release_lock EXIT HUP INT TERM
}

status() {
  service=$1
  container=$($compose ps -q "$service")
  [ -n "$container" ] || return 1
  [ "$(docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' "$container")" = healthy ]
}

ready() {
  elapsed=0
  pg=1
  redis=1
  while [ "$elapsed" -lt 30 ]; do
    status postgres && pg=0 || pg=1
    status redis && redis=0 || redis=1
    [ "$pg" -eq 0 ] && [ "$redis" -eq 0 ] && break
    sleep 1
    elapsed=$((elapsed + 1))
  done
  [ "$pg" -eq 0 ] && echo "PostgreSQL: ready (127.0.0.1:${POSTGRES_PORT:-5432})" || echo "PostgreSQL: unavailable or unready (127.0.0.1:${POSTGRES_PORT:-5432})" >&2
  [ "$redis" -eq 0 ] && echo "Redis: ready (127.0.0.1:${REDIS_PORT:-6379})" || echo "Redis: unavailable or unready (127.0.0.1:${REDIS_PORT:-6379})" >&2
  [ "$pg" -eq 0 ] && [ "$redis" -eq 0 ]
}

case "${1:-}" in
  start) acquire_lock; $compose up -d ;;
  inspect) $compose ps ;;
  ready) ready ;;
  stop) acquire_lock; $compose stop --timeout 10 ;;
  restart) acquire_lock; $compose up -d --force-recreate; ready ;;
  reset)
    [ "${2:-}" = "--confirm" ] || { echo "reset is destructive; rerun: $0 reset --confirm" >&2; exit 2; }
    acquire_lock
    $compose down --volumes --remove-orphans
    ;;
  *) echo "usage: $0 {start|inspect|ready|stop|restart|reset --confirm}" >&2; exit 2 ;;
esac
