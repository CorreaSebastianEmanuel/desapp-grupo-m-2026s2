import json, os, subprocess, time
from pathlib import Path
root = Path.cwd()
feature = root / 'specs/057-idempotent-catalog-ingestion'
evidence = feature / 'qa-evidence'
manifest = json.loads((feature / 'verification.json').read_text())
results = []
for check in manifest['checks']:
    started = time.monotonic()
    env = {**os.environ, **check.get('env', {})}
    with (evidence / (check['id'] + '.log')).open('w') as out:
        code = subprocess.run(check['argv'], env=env, stdout=out, stderr=subprocess.STDOUT).returncode
    result = {'id': check['id'], 'argv': check['argv'], 'env': check.get('env', {}), 'exit_code': code, 'seconds': round(time.monotonic()-started, 3)}
    results.append(result)
    (evidence / 'results.json').write_text(json.dumps(results, indent=2)+'\n')
    print(json.dumps(result), flush=True)
    if code:
        print('Stopped for diagnosis; no repeated unchanged attempt.', flush=True)
        break
