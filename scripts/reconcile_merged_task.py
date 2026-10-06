#!/usr/bin/env python3
"""Finalize a reviewed Agentflow task after its implementation PR is merged."""
from __future__ import annotations
import argparse
from pathlib import Path

try:
    from scripts.agentflow_feature import task_id_from_head, task_for_id, complete_reviewed_task
except ModuleNotFoundError:
    from agentflow_feature import task_id_from_head, task_for_id, complete_reviewed_task

ROOT = Path(__file__).resolve().parents[1]

def reconcile(root: Path, head_ref: str) -> Path | None:
    task = task_for_id(root, task_id_from_head(head_ref))
    return complete_reviewed_task(root, task, head_ref=head_ref, allow_done_noop=True)

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('--head-ref', required=True)
    parser.add_argument('--root', type=Path, default=ROOT)
    args = parser.parse_args()
    try:
        changed = reconcile(args.root.resolve(), args.head_ref)
    except ValueError as error:
        parser.exit(1, f'{error}\n')
    print(f'Finalized {changed.relative_to(args.root.resolve())}' if changed else 'Task already finalized')
    return 0

if __name__ == '__main__':
    raise SystemExit(main())
