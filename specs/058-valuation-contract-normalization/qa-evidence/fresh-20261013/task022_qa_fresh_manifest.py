import json, os, pathlib, subprocess, time
root = pathlib.Path('/home/sebo/desapp-grupo-m-2026s2')
out = pathlib.Path('/tmp/task022-qa-fresh-evidence')
out.mkdir(exist_ok=True)
manifest = json.loads((root / 'specs/058-valuation-contract-normalization/verification.json').read_text())
results = []
for check in manifest['checks']:
    if check['id'] in ['toolchain', 'format']:
        continue  # Already independently executed in this QA session, exit 0.
    env = os.environ.copy()
    env.update(check.get('env', {}))
    start = time.monotonic()
    with (out / (check['id'] + '-local.log')).open('w') as log:
        run = subprocess.run(check['argv'], cwd=root, env=env, stdout=log, stderr=subprocess.STDOUT)
    result = dict(id=check['id'], argv=check['argv'], env=check.get('env', {}), exit=run.returncode, elapsed=round(time.monotonic()-start, 3))
    results.append(result)
    (out / 'results-local.json').write_text(json.dumps(results, indent=2)+'\n')
    print(json.dumps(result), flush=True)
    if run.returncode:
        print('STOP: failed check; no retries or downstream checks performed.', flush=True)
        raise SystemExit(run.returncode)
