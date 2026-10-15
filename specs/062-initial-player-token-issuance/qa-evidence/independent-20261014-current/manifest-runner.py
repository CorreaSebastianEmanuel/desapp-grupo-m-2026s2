import json, os, subprocess, time
from pathlib import Path

root = Path('/home/sebo/desapp-grupo-m-2026s2')
evidence = root / 'specs/062-initial-player-token-issuance/qa-evidence/independent-20261014-current'
evidence.mkdir(parents=True, exist_ok=True)
manifest = json.loads((root / 'specs/062-initial-player-token-issuance/verification.json').read_text())
results = []
for check in manifest['checks']:
    start = time.monotonic()
    print('START ' + check['id'], flush=True)
    env = os.environ.copy()
    env.update(check.get('env', {}))
    path = evidence / (check['id'] + '.log')
    with path.open('w') as output:
        result = subprocess.run(check['argv'], cwd=root, env=env, stdout=output, stderr=subprocess.STDOUT)
    entry = dict(id=check['id'], argv=check['argv'], env=check.get('env', {}), exit_code=result.returncode, seconds=round(time.monotonic()-start, 3), output=str(path.relative_to(root)))
    results.append(entry)
    (evidence / 'results.json').write_text(json.dumps(results, indent=2) + '\n')
    print('END ' + check['id'] + ' exit=' + str(result.returncode) + ' seconds=' + str(entry['seconds']), flush=True)
    if result.returncode:
        print('FAILED; remaining dependent checks not run', flush=True)
        break
