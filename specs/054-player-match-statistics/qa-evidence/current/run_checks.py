import json, os, pathlib, subprocess, tempfile, time
root=pathlib.Path.cwd()
out=root/'specs/054-player-match-statistics/qa-evidence/current'
env=os.environ.copy()
env['PATH']='/private/tmp/task020-elixir-1.20.3/bin:/private/tmp/node-v24.0.0-darwin-x64/bin:'+env['PATH']
env['ERL_FLAGS']='+S 4:4'
manifest=json.loads((root/'specs/054-player-match-statistics/verification.json').read_text())
previous=json.loads((out/'results.json').read_text())
(out/'sandbox-attempt.json').write_text(json.dumps(previous,indent=2)+'\n')
results=[r for r in previous if r['exit']==0]
for check in manifest['checks']:
    if any(r['id']==check['id'] for r in results): continue
    local=env.copy(); local.update(check.get('env',{}))
    if check['id']=='coverage':
        snap=pathlib.Path(tempfile.mkdtemp(prefix='task020-independent-qa-'))
        (snap/'objects').mkdir()
        local.update(GIT_INDEX_FILE=str(snap/'index'),GIT_OBJECT_DIRECTORY=str(snap/'objects'),GIT_ALTERNATE_OBJECT_DIRECTORIES=str(root/'.git/objects'))
        subprocess.run(['git','read-tree','HEAD'],env=local,check=True)
        subprocess.run(['git','add','--all'],env=local,check=True)
    print('RUN '+check['id'],flush=True)
    start=time.monotonic()
    with (out/(check['id']+'.log')).open('w') as log:
        p=subprocess.run(check['argv'],env=local,stdout=log,stderr=subprocess.STDOUT)
    result={'id':check['id'],'argv':check['argv'],'exit':p.returncode,'seconds':round(time.monotonic()-start,1)}
    results.append(result)
    (out/'results.json').write_text(json.dumps(results,indent=2)+'\n')
    print(json.dumps(result),flush=True)
