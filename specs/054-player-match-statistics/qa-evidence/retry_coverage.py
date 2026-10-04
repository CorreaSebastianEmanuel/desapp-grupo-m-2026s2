import os,subprocess,pathlib,json,time
root=pathlib.Path.cwd(); dest=root/'specs/054-player-match-statistics/qa-evidence'
env=os.environ.copy(); env['PATH']='/private/tmp/task020-elixir-1.20.3/bin:/private/tmp/node-v24.0.0-darwin-x64/bin:'+env['PATH']; env['MIX_ENV']='test'
env.update(GIT_INDEX_FILE='/private/tmp/task020-qa-git/index',GIT_OBJECT_DIRECTORY='/private/tmp/task020-qa-git/objects',GIT_ALTERNATE_OBJECT_DIRECTORIES=str(root/'.git/objects'))
subprocess.run(['git','add','--intent-to-add','--','.'],env=env,check=True)
start=time.time()
with open('/private/tmp/task020-qa-coverage.log','w') as f:
 p=subprocess.run(['mix','test.cp1_coverage'],env=env,stdout=f,stderr=subprocess.STDOUT)
(dest/'coverage-retry.log').write_text(pathlib.Path('/private/tmp/task020-qa-coverage.log').read_text())
result={'id':'coverage','argv':['mix','test.cp1_coverage'],'env':{'MIX_ENV':'test'},'exit':p.returncode,'seconds':round(time.time()-start,2),'note':'retry after indexing authored QA evidence in disposable index; capture outside repository during snapshot'}
results=json.loads((dest/'results.json').read_text()); results.append(result); (dest/'results.json').write_text(json.dumps(results,indent=2)+'\n'); print(json.dumps(result),flush=True)
