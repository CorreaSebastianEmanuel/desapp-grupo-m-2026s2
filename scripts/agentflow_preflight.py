#!/usr/bin/env python3
"""Read-only, bounded prerequisite checks for the effective child context."""
from __future__ import annotations

import argparse
import glob
import json
import os
import re
import shutil
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path

try:
    from .agentflow_runtime import safe_diagnostic
except ImportError:
    from agentflow_runtime import safe_diagnostic


@dataclass(frozen=True)
class LaunchContext:
    stage: str
    provider: str
    argv: tuple[str, ...]
    cwd: Path
    env: dict[str, str]


def node24_path(path: str | None = None) -> str | None:
    """Return the nvm v24 bin directory when the effective PATH lacks Node 24."""
    current = shutil.which("node", path=path)
    probe_env = {**os.environ, "PATH": path or os.environ.get("PATH", "")}
    if current:
        try:
            probe = subprocess.run([current, "--version"], env=probe_env,
                                   capture_output=True, text=True, timeout=5, check=False)
            if probe.returncode == 0 and probe.stdout.strip().startswith("v24."):
                return None
        except (OSError, subprocess.TimeoutExpired):
            pass
    candidates = sorted(glob.glob(str(Path.home() / ".nvm/versions/node/v24*/bin")), reverse=True)
    return next((entry for entry in candidates if Path(entry, "node").is_file()), None)


def build_context(stage: str, provider: str, argv, *, root=None, cwd=None, env=None) -> LaunchContext:
    root = Path(root or Path.cwd()).resolve()
    final_env = dict(os.environ if env is None else env)
    final_cwd = Path(cwd or root).resolve()
    values = tuple(str(item) for item in argv)
    if not values or any("\0" in item for item in values) or not final_cwd.is_dir():
        raise ValueError("Invalid launch context")
    return LaunchContext(stage=stage, provider=provider, argv=values, cwd=final_cwd, env=final_env)


def _probe(context: LaunchContext, name: str, expected: str, executable: str | None = None):
    resolved = shutil.which(executable or name, path=context.env.get("PATH"))
    if not resolved:
        return safe_diagnostic(stage=context.stage, check=name, category="prerequisite-missing",
                               expected=expected, observed="missing")
    if name == "python3":
        try:
            completed = subprocess.run([resolved, "--version"], cwd=context.cwd, env=context.env,
                                        capture_output=True, text=True, timeout=5, check=False)
        except (OSError, subprocess.TimeoutExpired):
            return safe_diagnostic(stage=context.stage, check=name, category="prerequisite-unknown",
                                   expected=expected, observed="probe-failed")
        version = (completed.stdout + completed.stderr).strip().split()[-1:] or [""]
        if completed.returncode or not version[0].startswith("3."):
            return safe_diagnostic(stage=context.stage, check=name, category="prerequisite-incompatible",
                                   expected=expected, observed="version-mismatch")
    return None


def _pinned_toolchain(context: LaunchContext):
    """Validate project pins through mise in the exact child environment."""
    pin_file = context.cwd / ".tool-versions"
    if not pin_file.is_file():
        if context.env.get("AGENTFLOW_TOOLCHAIN_REQUIRED") == "true":
            return [safe_diagnostic(stage=context.stage, check="toolchain", category="prerequisite-missing",
                                    expected="file-readable", observed="missing")]
        return []
    try:
        versions = {}
        for line in pin_file.read_text(encoding="utf-8").splitlines():
            fields = line.split()
            if len(fields) == 2:
                versions[fields[0]] = fields[1]
    except (OSError, UnicodeError):
        return [safe_diagnostic(stage=context.stage, check="toolchain", category="prerequisite-unknown",
                                expected="registered-version", observed="unknown")]
    elixir_pin, erlang_pin = versions.get("elixir"), versions.get("erlang")
    elixir_match = re.fullmatch(r"(\d+\.\d+\.\d+)-otp-(\d+)", elixir_pin or "")
    erlang_match = re.match(r"(\d+)", erlang_pin or "")
    if not elixir_match or not erlang_match:
        return [safe_diagnostic(stage=context.stage, check="toolchain", category="configuration",
                                expected="registered-version", observed="unknown")]
    mise = shutil.which("mise", path=context.env.get("PATH"))
    if not mise:
        return [safe_diagnostic(stage=context.stage, check="mise", category="prerequisite-missing",
                                expected="executable", observed="missing")]
    probes = [
        ("elixir", [mise, "exec", "--", "elixir", "--version"]),
        ("erlang", [mise, "exec", "--", "erl", "-noshell", "-eval",
                    'io:format("~s", [erlang:system_info(otp_release)]), halt().']),
    ]
    failures = []
    for name, argv in probes:
        try:
            result = subprocess.run(argv, cwd=context.cwd, env=context.env, capture_output=True,
                                    text=True, timeout=8, check=False)
        except (OSError, subprocess.TimeoutExpired):
            failures.append(safe_diagnostic(stage=context.stage, check=name,
                                            category="prerequisite-unknown",
                                            expected="registered-version", observed="probe-failed"))
            continue
        output = result.stdout + result.stderr
        if name == "elixir":
            match = re.search(r"\bElixir\s+(\d+\.\d+\.\d+).*?Erlang/OTP\s+(\d+)", output, re.S)
            valid = bool(result.returncode == 0 and match and
                         match.group(1) == elixir_match.group(1) and
                         match.group(2) == elixir_match.group(2))
        elif name == "erlang":
            valid = result.returncode == 0 and output.strip() == erlang_match.group(1)
        if not valid:
            failures.append(safe_diagnostic(stage=context.stage, check=name,
                                            category="prerequisite-incompatible",
                                            expected="registered-version", observed="version-mismatch"))
    node_exec = shutil.which("node", path=context.env.get("PATH"))
    if not node_exec:
        failures.append(safe_diagnostic(stage=context.stage, check="node",
                                        category="prerequisite-missing", expected="executable",
                                        observed="missing"))
    else:
        try:
            node = subprocess.run([node_exec, "--version"], cwd=context.cwd, env=context.env,
                                  capture_output=True, text=True, timeout=5, check=False)
            node_match = re.fullmatch(r"v?(\d+)\.\d+\.\d+", node.stdout.strip())
            valid_node = node.returncode == 0 and node_match and node_match.group(1) == "24"
        except (OSError, subprocess.TimeoutExpired):
            valid_node = False
        if not valid_node:
            failures.append(safe_diagnostic(stage=context.stage, check="node",
                                            category="prerequisite-incompatible",
                                            expected="registered-version", observed="version-mismatch"))
    return failures


def evaluate(context: LaunchContext, *, inventory=None):
    """Evaluate only bounded executable/context properties; never persist state."""
    checks = inventory or [
        ("python3", "python-3"), ("git", "executable"), ("specify", "executable"),
    ]
    if inventory is None and context.stage in ("develop", "qa"):
        checks.extend([("mix", "executable"), ("node", "executable")])
    failures = []
    for name, expected in checks:
        diagnostic = _probe(context, name, expected)
        if diagnostic:
            failures.append(diagnostic)
    toolchain_required = context.env.get("AGENTFLOW_TOOLCHAIN_REQUIRED")
    if inventory is None and toolchain_required != "false" and (
            toolchain_required == "true" or (context.cwd / ".tool-versions").is_file()):
        failures.extend(_pinned_toolchain(context))
    if inventory is None:
        launch_executable = context.argv[0]
        diagnostic = _probe(context, "launch-command", "executable", executable=launch_executable)
        if diagnostic:
            failures.append(diagnostic)
        integration_key = ("SPECKIT_INTEGRATION_CODEX_EXECUTABLE" if context.provider == "codex"
                           else "SPECKIT_INTEGRATION_OPENCODE_EXECUTABLE")
        provider_key = "AGENTFLOW_CODEX_REAL" if context.provider == "codex" else "AGENTFLOW_OPENCODE_REAL"
        provider_executable = context.env.get(integration_key) or context.env.get(provider_key, context.provider)
        diagnostic = _probe(context, context.provider, "provider-executable", executable=provider_executable)
        if diagnostic:
            failures.append(diagnostic)
    if not context.cwd.is_dir():
        failures.append(safe_diagnostic(stage=context.stage, check="cwd", category="prerequisite-missing",
                                        expected="readable-directory", observed="missing"))
    if inventory is None and context.stage in ("develop", "qa"):
        service_probe = context.cwd / "scripts/local_services.sh"
        if not service_probe.is_file():
            failures.append(safe_diagnostic(stage=context.stage, check="local-services",
                                            category="prerequisite-unknown", expected="service-ready",
                                            observed="missing"))
        else:
            try:
                probe = subprocess.run(["sh", str(service_probe), "ready"], cwd=context.cwd,
                                       env=context.env, stdout=subprocess.DEVNULL,
                                       stderr=subprocess.DEVNULL, timeout=5, check=False)
                if probe.returncode:
                    failures.append(safe_diagnostic(stage=context.stage, check="local-services",
                                                    category="prerequisite-unavailable",
                                                    expected="service-ready", observed="not-ready"))
            except (OSError, subprocess.TimeoutExpired):
                failures.append(safe_diagnostic(stage=context.stage, check="local-services",
                                                category="prerequisite-unknown",
                                                expected="service-ready", observed="probe-failed"))
    return {"ready": not failures, "stage": context.stage, "provider": context.provider,
            "prerequisites": failures}


def preflight_or_raise(context: LaunchContext):
    result = evaluate(context)
    if not result["ready"]:
        raise RuntimeError(json.dumps(result, sort_keys=True))
    return context


def evaluate_declarations(context: LaunchContext, declarations):
    """Evaluate validated manifest prerequisite declarations without shell eval."""
    results = []
    root = context.cwd.resolve()
    for item in declarations:
        kind, target, expected = item["kind"], item["target"], item["expected"]
        ok = False
        category, observed = "prerequisite-unknown", "unsupported"
        if kind == "executable":
            path = shutil.which(target, path=context.env.get("PATH"))
            ok, observed = bool(path), "present" if path else "missing"
            category = "prerequisite-missing"
        elif kind == "setting":
            present = target in context.env and bool(context.env[target])
            ok = present if expected == "setting-present" else present and context.env[target] == "true"
            observed = "present" if present else "missing"
            category = "prerequisite-missing"
        elif kind == "file":
            path = (root / target).resolve()
            if path.is_relative_to(root):
                ok = path.is_file() and os.access(path, os.R_OK)
                observed = "readable" if ok else "missing"
                category = "prerequisite-missing"
        elif kind == "service":
            try:
                ready = subprocess.run(["sh", str(root / "scripts/local_services.sh"), "ready"],
                                       cwd=root, env=context.env, stdout=subprocess.DEVNULL,
                                       stderr=subprocess.DEVNULL, timeout=5, check=False).returncode == 0
                ok, observed = ready, "ready" if ready else "not-ready"
                category = "prerequisite-unavailable"
            except (OSError, subprocess.TimeoutExpired):
                category, observed = "prerequisite-unknown", "probe-failed"
        if not ok:
            results.append(safe_diagnostic(stage=context.stage, check=item["id"], category=category,
                                           expected=expected, observed=observed))
    return results


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--stage", required=True,
                        choices=("product", "product_challenge", "architecture", "tasks", "develop", "qa", "review", "unknown"))
    parser.add_argument("--provider", required=True, choices=("codex", "opencode"))
    parser.add_argument("--check")
    args = parser.parse_args(argv)
    if args.check:
        try:
            from .agentflow_verification import manifest
            from .workflow_artifact_probe import active_feature
        except ImportError:
            from agentflow_verification import manifest
            from workflow_artifact_probe import active_feature
        data = manifest(active_feature(Path.cwd().resolve()))
        check = next((value for value in data["checks"] if value["id"] == args.check), None)
        if check is None:
            result = {"ready": False, "stage": args.stage, "provider": args.provider,
                      "prerequisites": [safe_diagnostic(stage=args.stage, check=args.check,
                      category="configuration", expected="registered-check", observed="unknown")]}
            print(json.dumps(result, sort_keys=True)); return 2
        context = build_context(args.stage, args.provider, check["argv"], env={**os.environ, **check.get("env", {})})
        failures = evaluate_declarations(context, check.get("prerequisites", []))
        result = {"ready": not failures, "stage": args.stage, "provider": args.provider,
                  "check": check["id"], "prerequisites": failures}
        print(json.dumps(result, sort_keys=True)); return 0 if result["ready"] else 2
    context = build_context(args.stage, args.provider, [sys.executable, *sys.argv])
    result = evaluate(context)
    print(json.dumps(result, sort_keys=True))
    return 0 if result["ready"] else 2


if __name__ == "__main__":
    raise SystemExit(main())
