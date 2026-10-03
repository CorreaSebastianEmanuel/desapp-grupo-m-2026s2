# CP1 acceptance fixtures

Fixtures are synthetic and contain no real credentials or copied service output. Candidate IDs use repeated hexadecimal characters, observations use fixed categories, and unsafe cases contain synthetic sentinel values. Run `python3 -m unittest test/ci/cp1_acceptance_test.py`.

Directories: `pass/` is a complete ten-obligation input; `non_pass/` contains fail-closed state vocabulary; `unsafe/` supplies prohibited synthetic material; `workflow/` models hosted conclusions and SHA correlation.

Restart verification: `python3 -m unittest test/ci/cp1_acceptance_test.py` exercises manifest membership, nested evidence, hosted collection, and fail-closed safe publication. New regressions initially failed for raw JWT/sentinels and missing demo/profile/coverage validation; the corrected suite passes. No test fixture establishes acceptance for a real candidate.
