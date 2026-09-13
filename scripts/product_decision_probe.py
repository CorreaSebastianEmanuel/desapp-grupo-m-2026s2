#!/usr/bin/env python3
"""Validate the product critic's machine-readable human-check decision."""

from __future__ import annotations

import json
from pathlib import Path


def probe(root: Path) -> dict[str, object]:
    state_path = root / ".specify" / "feature.json"
    try:
        feature_value = json.loads(state_path.read_text(encoding="utf-8"))["feature_directory"]
    except (OSError, KeyError, TypeError, json.JSONDecodeError) as error:
        raise RuntimeError("Cannot resolve the active feature from .specify/feature.json") from error

    feature = Path(feature_value)
    if not feature.is_absolute():
        feature = root / feature
    feature = feature.resolve()
    specs = (root / "specs").resolve()
    if feature.parent != specs:
        raise RuntimeError(f"Active feature must be an immediate child of {specs}")

    required_product = (
        feature / "spec.md",
        feature / "handoffs" / "product.md",
        feature / "handoffs" / "product-challenge.md",
        feature / "handoffs" / "product-decision.md",
    )
    missing = [str(path) for path in required_product if not path.is_file()]
    if missing:
        raise RuntimeError("Missing required product artifact(s): " + ", ".join(missing))

    decision = feature / "handoffs" / "product-decision.md"
    try:
        first_line = decision.read_text(encoding="utf-8").splitlines()[0].strip()
    except (OSError, IndexError) as error:
        raise RuntimeError(f"Missing or empty product decision: {decision}") from error

    markers = {
        "human_check_required: true": True,
        "human_check_required: false": False,
    }
    if first_line not in markers:
        raise RuntimeError(
            "product-decision.md must start exactly with "
            "'human_check_required: true' or 'human_check_required: false'"
        )
    return {"required": markers[first_line], "file": str(decision)}


if __name__ == "__main__":
    try:
        print(json.dumps(probe(Path.cwd())))
    except RuntimeError as error:
        raise SystemExit(str(error)) from error
