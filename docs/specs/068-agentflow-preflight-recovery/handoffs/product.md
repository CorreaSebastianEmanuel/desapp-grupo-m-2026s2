# Product handoff

- No unresolved product decisions remain; proceed to architecture and tasks from the canonical spec.
- Keep branch identity tied to `070-agentflow-preflight-and-efficient-failure-recovery`; the sequential feature directory is `068-agentflow-preflight-recovery`.
- During design, define “relevant inputs” narrowly enough to avoid unrelated-change resets while including every input that can affect the repeated failure. Preserve the established two-failure policy.
- Use the prior child-environment failure lesson as a regression prompt: verify the child sees the intended executable path after login-shell/launcher behavior, rather than inferring it from the parent shell.
- Make failure-report tests assert redaction of sensitive setting values and truthful partial outcomes, including interrupted QA.
