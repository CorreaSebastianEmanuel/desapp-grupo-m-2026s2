#!/bin/sh
set -eu

expected_elixir=1.20.3
expected_otp_release=29
expected_erts=17.0.6

command -v elixir >/dev/null 2>&1 || { echo 'error: elixir is not installed' >&2; exit 1; }
command -v mix >/dev/null 2>&1 || { echo 'error: mix is not installed' >&2; exit 1; }
command -v erl >/dev/null 2>&1 || { echo 'error: erl is not installed' >&2; exit 1; }

elixir_version=$(elixir -e 'IO.write(System.version())')
otp_release=$(erl -noshell -eval 'io:format("~s", [erlang:system_info(otp_release)]), halt().' 2>/dev/null)
erts_version=$(erl -noshell -eval 'io:format("~s", [erlang:system_info(version)]), halt().' 2>/dev/null)

[ "$elixir_version" = "$expected_elixir" ] || {
  printf 'error: expected Elixir %s, found %s\n' "$expected_elixir" "$elixir_version" >&2
  exit 1
}
[ "$otp_release" = "$expected_otp_release" ] || {
  printf 'error: expected Erlang/OTP release %s, found %s\n' "$expected_otp_release" "$otp_release" >&2
  exit 1
}
[ "$erts_version" = "$expected_erts" ] || {
  printf 'error: expected ERTS %s (OTP 29.0.6), found %s\n' "$expected_erts" "$erts_version" >&2
  exit 1
}

printf 'toolchain ok: Elixir %s, Erlang/OTP 29.0.6 (ERTS %s), %s\n' \
  "$elixir_version" "$erts_version" "$(mix --version | tail -n 1)"
