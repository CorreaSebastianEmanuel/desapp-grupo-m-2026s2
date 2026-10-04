import os,json,subprocess,pathlib,time
root=pathlib.Path.cwd(); dest=root/'specs/054-player-match-statistics/qa-evidence'; dest.mkdir(exist_ok=True)
env=os.environ.copy(); env['PATH']='/private/tmp/task020-elixir-1.20.3/bin:/private/tmp/node-v24.0.0-darwin-x64/bin:'+env['PATH']
# Isolate the coverage snapshot index and objects from the shared repository index.
tmp=pathlib.Path('/private/tmp/task020-qa-git'); tmp.mkdir(exist_ok=True); (tmp/'objects').mkdir(exist_ok=True)
env['GIT_INDEX_FILE']=str(tmp/'index'); env['GIT_OBJECT_DIRECTORY']=str(tmp/'objects'); env['GIT_ALTERNATE_OBJECT_DIRECTORIES']=str(root/'.git/objects')
for argv in [['git','read-tree','HEAD'],['git','add','--intent-to-add','--','.']]:
 p=subprocess.run(argv,env=env,capture_output=True,text=True); assert p.returncode==0,p.stderr
results=[]
for check in json.loads((root/'specs/054-player-match-statistics/verification.json').read_text())['checks']:
 e=env.copy(); e.update(check.get('env',{})); start=time.time()
 with (dest/(check['id']+'.log')).open('w') as f:
  p=subprocess.run(check['argv'],env=e,stdout=f,stderr=subprocess.STDOUT)
 result={'id':check['id'],'argv':check['argv'],'env':check.get('env',{}),'exit':p.returncode,'seconds':round(time.time()-start,2)}; results.append(result)
 (dest/'results.json').write_text(json.dumps(results,indent=2)+'\n')
 print(json.dumps(result),flush=True)
