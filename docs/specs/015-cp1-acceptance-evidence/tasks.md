# Withdrawal tasks

- [X] T001 Remove checkpoint acceptance runtime, fixtures, obsolete docs and workflow; restore incidental TASK-015-only changes.
- [X] T002 Remove TASK-035, repair TASK-052 dependency and record manual demonstration boundaries in TASK-051/TASK-052.
- [X] T003 Add withdrawal regression checks in tests/test_checkpoint_scope.py.
- [X] T004 Run focused removal/Agentflow regressions and the locked application quality checks.
- [X] T005 Obtain independent QA and final review for the withdrawal.
- [X] T006 Update and push PR #25; observe hosted checks without merging.

Publication observation: PR #25 was updated and commit a87e8dba4749ea84856a1ca6aab2697c3eec03f5 pushed. GitHub scheduled only the retained quality baseline and Sonar jobs; the removed CP1 acceptance workflow did not run. These hosted checks were pending at this observation. No merge or CP1 acceptance verdict is recorded here.
