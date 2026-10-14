import json, pathlib, subprocess, os, time, hashlib, sys
root=pathlib.Path.cwd()
feature=root/'specs/061-valuation-strategy-versioning'
evidence=feature/'qa-evidence/independent-20261013'
evidence.mkdir(parents=True,exist_ok=True)
manifest=json.loads((feature/'verification.json').read_text())
results=[]
for check in manifest['checks']:
    for attempt in (1,2):
        path=evidence/f"{check['id']}-{attempt}.log"
        start=time.monotonic()
        env={**os.environ,**check.get('env',{})}
        with path.open('w') as out:
            code=subprocess.run(check['argv'],env=env,stdout=out,stderr=subprocess.STDOUT).returncode
        result={'check':check['id'],'argv':check['argv'],'env':check.get('env',{}),'attempt':attempt,'exit_code':code,'elapsed_seconds':round(time.monotonic()-start,3),'evidence':str(path.relative_to(root)),'sha256':hashlib.sha256(path.read_bytes()).hexdigest()}
        results.append(result)
        (evidence/'results.json').write_text(json.dumps(results,indent=2)+'\n')
        print(json.dumps(result),flush=True)
        lines=path.read_text().splitlines()
        if code:
            print('\n'.join(lines[-24:]),flush=True)
            if attempt==2:
                print('STOP: two unchanged failures; no remaining checks executed',flush=True)
                sys.exit(code)
        else:
            print('\n'.join(x for x in lines if 'Result:' in x or 'CP1_PROFILE_RECEIPT' in x or 'failures' in x or 'PONG' in x),flush=True)
            break
