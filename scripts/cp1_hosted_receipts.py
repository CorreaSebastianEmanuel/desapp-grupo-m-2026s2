#!/usr/bin/env python3
"""Collect allowlisted exact-SHA hosted receipts without retaining raw responses."""
import argparse, base64, datetime as dt, json, os, sys, time, urllib.parse, urllib.request
from pathlib import Path
from cp1_acceptance import local_receipts, scan_safe, InvalidEvidence

def request_json(url, token):
    request = urllib.request.Request(url, headers={"Accept":"application/vnd.github+json", "Authorization":f"Bearer {token}", "X-GitHub-Api-Version":"2022-11-28"})
    with urllib.request.urlopen(request, timeout=30) as response:
        return json.load(response)

def sonar_json(path, token):
    auth=base64.b64encode((token + ":").encode()).decode()
    request=urllib.request.Request("https://sonarcloud.io/api/" + path, headers={"Authorization":f"Basic {auth}"})
    with urllib.request.urlopen(request, timeout=30) as response: return json.load(response)

def completed_run(runs, candidate, repository, name, workflow):
    matches = [r for r in runs if r.get("name") == name and
               r.get("path") == f".github/workflows/{workflow}" and
               r.get("head_repository", {}).get("full_name") == repository and
               r.get("head_branch") == "main" and r.get("event") in {"push", "workflow_dispatch"} and
               r.get("head_sha") == candidate and r.get("status") == "completed" and
               r.get("conclusion") == "success"]
    return max(matches, key=lambda r: r.get("run_number", 0), default=None)

def main():
    parser=argparse.ArgumentParser(); parser.add_argument("--candidate",required=True); parser.add_argument("--repository",required=True); parser.add_argument("--ref",required=True); parser.add_argument("--github-api",required=True); parser.add_argument("--output",type=Path,required=True); args=parser.parse_args()
    github_token=os.environ.get("GH_TOKEN", "")
    runs=[]
    def exact(name, workflow): return completed_run(runs, args.candidate, args.repository, name, workflow)
    quality=sonar_run=None
    for attempt in range(40):
      runs=request_json(f"{args.github_api}/repos/{args.repository}/actions/runs?head_sha={args.candidate}&per_page=100", github_token)["workflow_runs"]
      quality=exact("Quality baseline", "quality-baseline.yml"); sonar_run=exact("SonarCloud analysis", "sonarcloud.yml")
      if quality and sonar_run: break
      if attempt < 39: time.sleep(15)
    is_main=args.ref=="refs/heads/main"
    sonar_token=os.environ.get("SONAR_TOKEN", "")
    sonar_revision=None; sonar_analysis_id=None; open_issues=None; profiles=[]
    if sonar_token and is_main:
      try:
        analyses=sonar_json("project_analyses/search?" + urllib.parse.urlencode({"project":"CorreaSebastianEmanuel_desapp-grupo-m-2026s2","branch":"main","ps":100}), sonar_token)
        latest = analyses.get("analyses", [None])[0] if analyses.get("analyses") else None
        analysis = latest if latest and latest.get("revision") == args.candidate else None
        sonar_revision=analysis.get("revision") if analysis else None; sonar_analysis_id=analysis.get("key") if analysis else None
        issues=sonar_json("issues/search?" + urllib.parse.urlencode({"componentKeys":"CorreaSebastianEmanuel_desapp-grupo-m-2026s2","branch":"main","issueStatuses":"OPEN","ps":1}), sonar_token)
        open_issues=issues.get("total")
        profile_data=sonar_json("qualityprofiles/search?" + urllib.parse.urlencode({"project":"CorreaSebastianEmanuel_desapp-grupo-m-2026s2"}), sonar_token)
        profiles=sorted(f"{p.get('language')}:{p.get('name')}" for p in profile_data.get("profiles",[]) if p.get("activeRuleCount",0)>0)
        confirmation = sonar_json("project_analyses/search?" + urllib.parse.urlencode({"project":"CorreaSebastianEmanuel_desapp-grupo-m-2026s2","branch":"main","ps":1}), sonar_token).get("analyses", [])
        if not confirmation or confirmation[0].get("revision") != args.candidate or confirmation[0].get("key") != sonar_analysis_id:
          sonar_revision = None
      except Exception: pass
    sonar_pass=bool(sonar_run and is_main and sonar_revision==args.candidate and type(open_issues) is int and 0 <= open_issues <= 9 and profiles)
    runs_local = test_profiles = coverage = None
    try:
      runs_local, test_profiles, coverage = local_receipts("tmp/local-receipts", args.candidate)
    except (InvalidEvidence, OSError, ValueError, KeyError, TypeError):
      pass
    local_pass = runs_local is not None and test_profiles is not None and coverage is not None
    status="PASS" if quality and sonar_pass and local_pass else "NOT PASSING"
    run_ref=lambda run: run["html_url"] if run else f"https://github.com/{args.repository}/actions"
    receipts=[
      {"kind":"repository","status":"PASS","candidate_sha":args.candidate,"observed":"repository accessible","reference":f"https://github.com/{args.repository}"},
      {"kind":"quality_build","status":"PASS" if quality else "NOT PASSING","candidate_sha":args.candidate,"observed":"exact-SHA terminal quality run" if quality else "exact-SHA quality run unavailable","reference":run_ref(quality)},
      {"kind":"sonarcloud","status":"PASS" if sonar_pass else "NOT PASSING","candidate_sha":args.candidate,"observed":f"{open_issues} open issues" if sonar_pass else "authoritative main analysis unavailable or non-passing","reference":"https://sonarcloud.io/project/overview?id=CorreaSebastianEmanuel_desapp-grupo-m-2026s2","project":"CorreaSebastianEmanuel_desapp-grupo-m-2026s2","branch":"main","analysis_status":"completed" if sonar_revision else "unavailable","analysis_id":sonar_analysis_id,"retrieved_at":dt.datetime.now(dt.timezone.utc).replace(microsecond=0).isoformat().replace("+00:00","Z"),"metric":"open_issues","open_issues":open_issues,"profiles":profiles},
      {"kind":"demo","status":"PASS" if local_pass else "NOT PASSING","candidate_sha":args.candidate,"observed":"two local demonstrations retained safely" if local_pass else "demo receipt unavailable","reference":"specs/015-cp1-acceptance-evidence/quickstart.md"},
      {"kind":"tests","status":"PASS" if local_pass else "NOT PASSING","candidate_sha":args.candidate,"observed":"verification profiles and coverage completed" if local_pass else "test receipt unavailable","reference":run_ref(next((r for r in runs if r.get("name")=="CP1 acceptance" and r.get("head_sha")==args.candidate), None))}
    ]
    if local_pass:
      receipts[3]["runs"] = runs_local
      receipts[4]["profiles"] = test_profiles
      receipts[4]["coverage"] = coverage
    scan_safe(receipts)
    args.output.parent.mkdir(parents=True,exist_ok=True); args.output.write_text(json.dumps({"candidate_sha":args.candidate,"provenance":"committed" if is_main else "working-tree-snapshot","receipts":receipts})+"\n")
    return 0 if status=="PASS" else 1
if __name__=="__main__":
    try: sys.exit(main())
    except Exception:
      print("cp1-hosted: NOT PASSING (collection-unavailable)", file=sys.stderr)
      sys.exit(1)
