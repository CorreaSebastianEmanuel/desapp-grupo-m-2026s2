#!/bin/sh
# Shared mix compilation cache for local Agentflow sessions.
#
# Per-task Agentflow worktrees normally recompile deps and the application from
# scratch; this wrapper redirects MIX_DEPS_PATH/MIX_BUILD_PATH to a shared local
# directory so sequential tasks reuse compiled artifacts (AGENTS.md rule 1 keeps
# this single-task-at-a-time, which also avoids concurrent compile races).
#
# Local-only: CI (GitHub Actions) must keep its own isolated environment; never
# point a CI run at this cache.
#
# Usage:
#   scripts/mix_cache.sh mix test           # run a mix command with the cache
#   eval "$(scripts/mix_cache.sh --env)"    # export it for the whole session
set -eu

cache_root="${MIX_SHARED_CACHE:-$HOME/.cache/desapp-grupo-m-2026s2/mix}"
build_dir="$cache_root/build/${MIX_ENV:-dev}"

if [ "${1:-}" = "--env" ]; then
  printf 'export MIX_DEPS_PATH="%s"\nexport MIX_BUILD_PATH="%s"\n' "$cache_root/deps" "$build_dir"
  exit 0
fi

[ "$#" -gt 0 ] || { echo "usage: $0 [--env] <command> [args...]" >&2; exit 2; }

mkdir -p "$cache_root/deps" "$build_dir"
MIX_DEPS_PATH="$cache_root/deps" MIX_BUILD_PATH="$build_dir" exec "$@"
