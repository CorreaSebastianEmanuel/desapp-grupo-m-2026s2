#!/usr/bin/env python3
"""Run the CI suite on the working snapshot in a shallow clone without workflow state."""
from pathlib import Path
import hashlib
import os
import shutil
import subprocess
import tempfile


def git(root, *args):
    return subprocess.check_output(["git", *args], cwd=root)


def main():
    root = Path(__file__).resolve().parents[1]
    with tempfile.TemporaryDirectory(prefix="task017-clean-checkout-") as directory:
        checkout = Path(directory) / "repo"
        subprocess.run(
            ["git", "clone", "--quiet", "--depth", "1", "--no-hardlinks",
             root.as_uri(), str(checkout)], check=True,
        )
        assert git(checkout, "rev-parse", "--is-shallow-repository").strip() == b"true"
        assert not (checkout / ".specify/feature.json").exists()

        # Include staged, unstaged, new and deleted inputs; no commit is needed.
        paths = git(root, "ls-files", "--cached", "--others", "--exclude-standard", "-z")
        for raw in set(paths.split(b"\0")) - {b""}:
            relative = Path(os.fsdecode(raw))
            source, target = root / relative, checkout / relative
            if target.is_file() or target.is_symlink():
                target.unlink()
            if source.exists() or source.is_symlink():
                target.parent.mkdir(parents=True, exist_ok=True)
                if source.is_symlink():
                    target.symlink_to(os.readlink(source))
                else:
                    shutil.copy2(source, target)

        assert not (checkout / ".specify/feature.json").exists()
        # Reuse installed dependency sources, with an isolated build cache.
        # Git inputs, HEAD and workflow metadata remain those of the clean clone.
        (checkout / "deps").symlink_to(root / "deps", target_is_directory=True)
        if (root / "_build").is_dir():
            shutil.copytree(root / "_build", checkout / "_build", symlinks=True)
        browser_dependencies = Path("tools/openapi/node_modules")
        if (root / browser_dependencies).is_dir():
            (checkout / browser_dependencies).symlink_to(
                root / browser_dependencies, target_is_directory=True,
            )
        print("clean-checkout: shallow=true feature_metadata=absent working_snapshot=applied", flush=True)
        result = subprocess.run(["sh", "scripts/ci_unit_tests.sh"], cwd=checkout)
        assert not (checkout / ".specify/feature.json").exists()
        if result.returncode:
            return result.returncode

    # Portable equivalents run in the CI suite above. Retain and rerun the
    # original independent probes when this workspace still has them.
    probes = [
        Path("/tmp/task017-independent-qa/delay-acceptance.exs"),
        Path("/tmp/task017-independent-qa/delay-http.exs"),
        Path("/tmp/task017-review/http-date-precision.exs"),
    ]
    for probe in probes:
        if probe.is_file():
            before = hashlib.sha256(probe.read_bytes()).digest()
            print(f"preserved-probe: {probe}", flush=True)
            result = subprocess.run(
                ["mix", "run", "--no-start", "--no-compile", str(probe)], cwd=root,
            )
            assert hashlib.sha256(probe.read_bytes()).digest() == before
            if result.returncode:
                return result.returncode
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
