# Removal boundary

Delete the TASK-015 acceptance-only additions and superseded feature documents. Restore its incidental Node pin/check, browser harness change and docs theme change to origin/main. Keep the seed failure ownership/logging correction and its delayed-output regression. Preserve TASK-053 implementation and independently reviewed artifacts.

Retain TASK-015 as the reviewed withdrawal record, so branch-based Agentflow finalization can reconcile it after a human merge. Clear its active run association; the interrupted historical run is obsolete and remains private. Remove TASK-035 and repair its dependent release task. Existing build, tests, coverage profiles, Sonar and domain scenario tests remain in scope; no equivalent CP2/CP3 acceptance workflow exists.

Use focused removal tests, Agentflow regression tests, formatter, warnings-as-errors compilation and the complete locked baseline. QA and final review run independently against this superseding scope. Push the result to the existing PR, update its title/body, and inspect hosted checks; do not merge.
