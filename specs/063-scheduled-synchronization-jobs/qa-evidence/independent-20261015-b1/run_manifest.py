import json, os, subprocess, time
from pathlib import Path
root=Path.cwd()
out=root/'specs/063-scheduled-synchronization-jobs/qa-evidence/independent-20261015-b1'
manifest=json.loads((root/'specs/063-scheduled-synchronization-jobs/verification.json').read_text())
results=json.loads((out/"results.json").read_text())
for c in manifest['checks']:
    if any(r['id']==c['id'] and r['exit_code']==0 for r in results): continue
    start=time.monotonic()
    with (out/(c['id']+'.log')).open('w') as f:
        p=subprocess.run(c['argv'],env={**os.environ,**c.get('env',{})},stdout=f,stderr=subprocess.STDOUT)
    r={'id':c['id'],'argv':c['argv'],'exit_code':p.returncode,'seconds':round(time.monotonic()-start,3)}
    results.append(r)
    (out/'results.json').write_text(json.dumps(results,indent=2)+'\n')
    print(json.dumps(r),flush=True)
    if p.returncode: break
