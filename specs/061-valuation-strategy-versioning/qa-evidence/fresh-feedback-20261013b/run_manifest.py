import hashlib, json, os, subprocess, time
from pathlib import Path
feature=Path("specs/061-valuation-strategy-versioning")
out=Path(__file__).parent
manifest=json.loads((feature/"verification.json").read_text())
results=json.loads((out/"results.json").read_text()) if (out/"results.json").exists() else []
for check in manifest["checks"]:
    previous=[r for r in results if r["id"]==check["id"]]
    if previous and previous[-1]["exit_code"]==0: continue
    if sum(r["exit_code"]!=0 for r in previous)>=2: raise SystemExit("STOP: two failures for unchanged inputs")
    started=time.monotonic()
    log=out/(check["id"]+("-retry" if previous else "")+".log")
    with log.open("w") as stream:
        result=subprocess.run(check["argv"], env={**os.environ, **check.get("env",{})},stdout=stream,stderr=subprocess.STDOUT)
    record={"id":check["id"],"argv":check["argv"],"exit_code":result.returncode,"elapsed_seconds":round(time.monotonic()-started,3),"evidence":str(log),"sha256":hashlib.sha256(log.read_bytes()).hexdigest()}
    results.append(record)
    (out/"results.json").write_text(json.dumps(results,indent=2)+"\n")
    print(json.dumps(record),flush=True)
    for line in log.read_text().splitlines():
        if any(s in line for s in [" failures", "test modules", "PONG", "Verified", "Error", "** (", " FAIL", "audit", "PostgreSQL"]): print(line[:400],flush=True)
    if result.returncode:
        print("STOP: inspect failure before further checks",flush=True)
        break
