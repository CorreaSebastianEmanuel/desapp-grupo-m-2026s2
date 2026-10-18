"""Actual supervisor termination must clean only its registered test schema."""
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import tempfile
import time
import uuid

sys.path.insert(0, str(Path(__file__).resolve().parents[3] / 'scripts'))
import test_profile_runner as runner


def query(code):
    result = subprocess.run(['mix', 'run', '-e', code], stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT, text=True, timeout=30)
    if result.returncode:
        raise RuntimeError('database-probe')
    return result.stdout


def worker():
    signal.signal(signal.SIGTERM, runner.interrupted)
    runner.run(['mix', 'run', 'test/support/e2e/interrupted_runtime.exs'], os.environ.copy(), 60)


def probe(mode):
    sentinel = 'e2e_' + uuid.uuid4().hex
    query('Ecto.Adapters.SQL.Sandbox.unboxed_run(FootballMarket.Repo, fn -> '
          f'Ecto.Adapters.SQL.query!(FootballMarket.Repo, "CREATE SCHEMA {sentinel}", []) end)')
    try:
        with tempfile.TemporaryDirectory(prefix='e2e-interrupt-') as directory:
            marker = Path(directory) / 'ready'
            env = {**os.environ, 'E2E_INTERRUPT_MARKER': str(marker)}
            if mode == 'timeout':
                try:
                    runner.run(['mix', 'run', 'test/support/e2e/interrupted_runtime.exs'], env, 20)
                except ValueError as error:
                    if str(error) != 'timeout':
                        raise
                else:
                    raise RuntimeError('timeout-not-enforced')
            elif mode == 'terminate':
                child = subprocess.Popen([sys.executable, __file__, 'worker'], env=env,
                                         stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                try:
                    deadline = time.monotonic() + 30
                    while not marker.exists() and child.poll() is None and time.monotonic() < deadline:
                        time.sleep(.025)
                    if not marker.exists():
                        raise RuntimeError('runtime-not-ready')
                    child.send_signal(signal.SIGTERM)
                    if child.wait(timeout=35) != 143:
                        raise RuntimeError('termination-status')
                finally:
                    if child.poll() is None:
                        child.kill()
                    child.wait()
            else:
                raise RuntimeError('invalid-mode')
            schema = marker.read_text()
            if not __import__('re').fullmatch(r'e2e_[a-f0-9]{32}', schema):
                raise RuntimeError('invalid-owned-schema')
            code = ('Ecto.Adapters.SQL.Sandbox.unboxed_run(FootballMarket.Repo, fn -> '
                    'r = Ecto.Adapters.SQL.query!(FootballMarket.Repo, '
                    '"SELECT nspname FROM pg_namespace WHERE nspname = ANY($1) ORDER BY nspname", '
                    f'[["{schema}", "{sentinel}"]]); '
                    f'if r.rows != [["{sentinel}"]], do: raise("owned cleanup failed"); '
                    'IO.puts("E2E_OWNERSHIP_VERIFIED") end)')
            if 'E2E_OWNERSHIP_VERIFIED' not in query(code):
                raise RuntimeError('missing-proof')
        print('E2E_SUPERVISOR status=complete mode=' + mode)
    finally:
        query('Ecto.Adapters.SQL.Sandbox.unboxed_run(FootballMarket.Repo, fn -> '
              f'Ecto.Adapters.SQL.query!(FootballMarket.Repo, "DROP SCHEMA {sentinel} CASCADE", []) end)')


if __name__ == '__main__':
    try:
        if sys.argv[1] == 'worker':
            worker()
        else:
            probe(sys.argv[1])
    except Exception:
        print('E2E_SUPERVISOR status=failed category=cleanup', file=sys.stderr)
        sys.exit(1)
