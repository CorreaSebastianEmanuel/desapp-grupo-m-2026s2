"""QA-only exact rational oracle. Bulk vectors live solely in a temporary file."""
import hashlib
import json
import os
from pathlib import Path
from fractions import Fraction
import subprocess
import tempfile
import time

out = Path(__file__).parent
metrics = ['goals', 'assists', 'shots_on_target', 'tackles', 'interceptions', 'saves', 'goals_conceded', 'yellow_cards', 'red_cards']
groups = ['goalkeeper', 'defender', 'midfielder', 'forward']
weight_pool = [0, 1, -3, '0.0000005', '-0.0000005', '0.125', '-7.123456789012345678901', 10**38 + 3, '-1000000000000000000000000.000000000001']
reference_pool = [1, 2, 3, 6, '0.125', '11.0000001', '1000000000000000000000.001']

def round6(value):
    scaled = abs(value) * 10**6
    whole, rest = divmod(scaled.numerator, scaled.denominator)
    return Fraction((whole + (2 * rest >= scaled.denominator)) * (-1 if value < 0 else 1), 10**6)

def fixed6(value):
    n = round6(value) * 10**6
    assert n.denominator == 1
    sign = '-' if n < 0 else ''
    a = abs(n.numerator)
    return f'{sign}{a // 10**6}.{a % 10**6:06d}'

vectors = []
for strategy in ['balanced', 'position_aware']:
    for i in range(45):
        references = {metric: reference_pool[(i + j * 2) % len(reference_pool)] for j, metric in enumerate(metrics)}
        group_weights = {group: {metric: weight_pool[(i * 3 + j * 2 + k) % len(weight_pool)] for j, metric in enumerate(metrics)} for k, group in enumerate(groups)}
        weights = group_weights['goalkeeper'] if strategy == 'balanced' else group_weights
        if i < 3:
            references = {'goals': 1}
            signed = ['0.0000005', '-0.0000005', 0][i]
            weights = {'goals': signed} if strategy == 'balanced' else {group: {'goals': signed if k == 0 else 0} for k, group in enumerate(groups)}
        exact = Fraction(0)
        contributions = [(10, weights)] if strategy == 'balanced' else [(k + 1, weights[group]) for k, group in enumerate(groups)]
        for total, metric_weights in contributions:
            for metric, weight in metric_weights.items():
                feature = round6(min(Fraction(1), Fraction(total) / Fraction(references[metric])))
                exact += feature * Fraction(weight)
        vectors.append({'id': f'{strategy}-{i}', 'strategy': strategy, 'references': references, 'weights': weights, 'expected': fixed6(exact)})

data = json.dumps(vectors, separators=(',', ':')).encode()
started = time.monotonic()
with tempfile.TemporaryDirectory(prefix='task025-qa-oracle-') as temporary:
    path = Path(temporary) / 'vectors.json'
    path.write_bytes(data)
    argv = ['mix', 'test', '--warnings-as-errors', str(out / 'oracle_test.exs')]
    with (out / 'oracle.log').open('w') as stream:
        result = subprocess.run(argv, env={**os.environ, 'MIX_ENV': 'test', 'QA_ORACLE_PATH': str(path)}, stdout=stream, stderr=subprocess.STDOUT)
record = {'argv': argv, 'exit_code': result.returncode, 'elapsed_seconds': round(time.monotonic()-started, 3), 'vectors': 90, 'oracle': 'Python Fraction; feature cap then six-place ties-away rounding, exact signed sum then final ties-away rounding', 'vector_sha256': hashlib.sha256(data).hexdigest(), 'log_sha256': hashlib.sha256((out / 'oracle.log').read_bytes()).hexdigest()}
(out / 'oracle-result.json').write_text(json.dumps(record, indent=2) + '\n')
print(json.dumps(record))
for line in (out / 'oracle.log').read_text().splitlines():
    if any(s in line for s in ['QA_', 'failure', 'test)', '** (', 'Error']):
        print(line[:500])
raise SystemExit(result.returncode)
