#!/usr/bin/env python3
"""Finalize a bounded portable summary after fresh independent verification."""
from __future__ import annotations
import argparse
import json
import subprocess
from datetime import datetime,timezone
from pathlib import Path
try:
    from .agentflow_feature import task_for_id, resolve_feature, require_reports
    from .agentflow_verification import (manifest, readiness, source_fingerprint, input_fingerprint,
                                         current_receipt, digest, atomic_json, load_json)
except ImportError:
    from agentflow_feature import task_for_id, resolve_feature, require_reports
    from agentflow_verification import (manifest, readiness, source_fingerprint, input_fingerprint,
                                        current_receipt, digest, atomic_json, load_json)


def finalize(root, task_id):
    task = task_for_id(root, task_id)
    branch = subprocess.check_output(['git','branch','--show-current'],cwd=root,text=True).strip()
    association = resolve_feature(root, task, head_ref=branch)
    feature = association.feature
    require_reports(association)
    readiness(root, feature)
    data = manifest(feature)
    source, inputs = source_fingerprint(root), input_fingerprint(feature)
    attestations={}
    for stage in ('qa','review'):
        attestation=load_json(root/'.agentflow/runs/attestations'/task_id/(stage+'.json'))
        report=feature/('qa-report.md' if stage=='qa' else 'review-report.md')
        if attestation.get('source') != source or attestation.get('inputs') != inputs or attestation.get('exit_code') != 0 or attestation.get('stage') != stage or attestation.get('report_sha256') != digest(report.read_bytes()) or not attestation.get('session_hash'):
            raise RuntimeError('Independent report provenance is missing, stale or mismatched')
        attestations[stage]=attestation
    if attestations['qa']['session_hash']==attestations['review']['session_hash'] or attestations['qa']['attempt']==attestations['review']['attempt']:
        raise RuntimeError('QA and review require independent sessions and attempts')
    rows = []
    for stage in ('develop','qa'):
        for check in data['checks']:
            receipt = current_receipt(root,feature,check,source,inputs,stage=stage)
            rows.append({'id':check['id'],'stage':stage,'status':'passed',
                         'command_identity':receipt['check_identity'],
                         'elapsed_seconds':receipt['elapsed_seconds'],
                         'output_sha256':receipt['evidence_sha256'],
                         'evidence':{'availability':'workspace-local; absent in another checkout',
                                     'reference':receipt['evidence']},
                         'environment':check.get('env',{}),
                         'coverage':sorted(req for req,checks in data['coverage'].items() if check['id'] in checks)})
    summary={'schema_version':1,'task':task_id,'feature':feature.name,
             'base_revision':subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip(),
             'verified_source':source,'canonical_inputs':inputs,
             'manifest_sha256':digest((feature/'verification.json').read_bytes()),
             'ci':data.get('ci_workflow_digests',{}),'checks':rows,'coverage':data['coverage'],
             'independent_reports':{name:{'verdict':'PASS','sha256':digest((feature/name).read_bytes())}
                                    for name in ('qa-report.md','review-report.md')},
             'complete':True,'limitations':['Portable summary does not authorize workspace reuse; run local checks.']}
    path=feature/'evidence-summary.json'
    if path.exists():
        previous=json.loads(path.read_text())
        comparable={key:value for key,value in previous.items() if key!='finalized_at'}
        if comparable==summary: return previous
    summary['finalized_at']=datetime.now(timezone.utc).isoformat()
    atomic_json(path,summary)
    return summary


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('command',choices=['finalize'])
    parser.add_argument('task')
    args=parser.parse_args()
    try:
        finalize(Path.cwd().resolve(),args.task)
        print(json.dumps({'task':args.task,'finalized':True}))
    except (RuntimeError,OSError,subprocess.SubprocessError) as error:
        raise SystemExit(str(error)) from error
