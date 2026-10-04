import os,json,subprocess,pathlib,time,tempfile
root=pathlib.Path.cwd()
out=root/'specs/054-player-match-statistics/qa-evidence/round3'
out.mkdir(exist_ok=True)
env=os.environ.copy(); env['PATH']='/private/tmp/task020-elixir-1.20.3/bin:/private/tmp/node-v24.0.0-darwin-x64/bin:'+env['PATH']
idx=pathlib.Path(tempfile.mkdtemp(prefix='task020-qa-index-'))/'index'
index_env=env.copy(); index_env['GIT_INDEX_FILE']=str(idx)
subprocess.run(['git','read-tree','HEAD'],env=index_env,check=True)
subprocess.run(['git','add','-N','.'],env=index_env,check=True)
results=[]
checks=json.loads((root/'specs/054-player-match-statistics/verification.json').read_text())['checks']
for c in checks:
    e=env.copy(); e.update(c.get('env',{}))
    if c['id'] == 'coverage': e['GIT_INDEX_FILE']=str(idx)
    start=time.time()
    # Output is retained outside the snapshot during coverage generation.
    logfile=pathlib.Path('/private/tmp')/('task020-qa3-'+c['id']+'.log')
    with logfile.open('w') as f:
        p=subprocess.run(c['argv'],env=e,stdout=f,stderr=subprocess.STDOUT)
    results.append(dict(id=c['id'],argv=c['argv'],env=c.get('env',{}),exit_code=p.returncode,seconds=round(time.time()-start,2),log=str(logfile)))
    print(c['id'],p.returncode,flush=True)
(out/'results.json').write_text(json.dumps(results,indent=2)+'\n')
