"""Assert baseline equality and reproducible evidence without writing vectors."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

BASELINE = "b14ad23cab3b13ef0a8446afac79f3382b592c59"
evidence = Path(__file__).resolve().parent
root = evidence.parents[3]
dataset = evidence / "oracle-vectors.json"
assert not dataset.exists(), "expanded dataset must remain absent"
before = {p.name: hashlib.sha256(p.read_bytes()).hexdigest()
          for p in evidence.iterdir() if p.is_file()}
output = subprocess.check_output([sys.executable, str(evidence / "generate_oracle.py")])
summary = json.loads((evidence / "oracle-summary.json").read_text())
vectors = json.loads(output)
original = json.loads(subprocess.check_output(
    ["git", "show", f"{BASELINE}:{dataset.relative_to(root).as_posix()}"], cwd=root))
assert vectors == original, "regenerated cases differ from approved baseline"
assert summary["subsets"] == len(vectors) == 511
assert summary["seed"] == 23059 and summary["arithmetic"] == "Fraction"
assert hashlib.sha256(output.rstrip(b"\n")).hexdigest() == summary["canonical_vectors_sha256"]
after = {p.name: hashlib.sha256(p.read_bytes()).hexdigest()
         for p in evidence.iterdir() if p.is_file()}
assert before == after and not dataset.exists(), "generation wrote evidence files"
paths = subprocess.check_output(
    ["git", "ls-tree", "-r", "--name-only", BASELINE, "--", "lib", "test"], cwd=root
).decode().splitlines()
current = subprocess.check_output(
    ["git", "ls-files", "--cached", "--others", "--exclude-standard", "--", "lib", "test"],
    cwd=root).decode().splitlines()
assert sorted(set(current)) == sorted(paths), "application source inventory changed"
for name in paths:
    original_bytes = subprocess.check_output(["git", "show", f"{BASELINE}:{name}"], cwd=root)
    assert hashlib.sha256((root / name).read_bytes()).digest() == hashlib.sha256(original_bytes).digest(), name
print(f"CLEANUP subsets=511 fingerprint={summary['canonical_vectors_sha256']} "
      f"application_files={len(paths)} baseline={BASELINE} writes=0 status=complete")
