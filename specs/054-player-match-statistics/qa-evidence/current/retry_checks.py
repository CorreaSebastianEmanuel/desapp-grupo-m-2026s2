import json,os,pathlib,subprocess,time
out=pathlib.Path('specs/054-player-match-statistics/qa-evidence/current')
env=os.environ.copy(); env['PATH']='/private/tmp/task020-elixir-1.20.3/bin:/private/tmp/node-v24.0.0-darwin-x64/bin:'+env['PATH']; env['ERL_FLAGS']='+S 4:4'
checks=json.loads(pathlib.Path('specs/054-player-match-statistics/verification.json').read_text())['checks']
results=[]
for c in checks:
 if c['id'] not in ('integration_coverage','regression'):continue
 local=env.copy(); local.update(c.get('env',{}))
 print('RETRY '+c['id'],flush=True); start=time.monotonic()
 with (out/(c['id']+'-retry.log')).open('w') as f:
  p=subprocess.run(c['argv'],env=local,stdout=f,stderr=subprocess.STDOUT)
 results.append({'id':c['id'],'argv':c['argv'],'exit':p.returncode,'seconds':round(time.monotonic()-start,1)})
 (out/'retry-results.json').write_text(json.dumps(results,indent=2)+'\n')
 print(json.dumps(results[-1]),flush=True)
