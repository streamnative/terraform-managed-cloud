#!/usr/bin/env python3
"""Read-only first-install collision check. Called only by approved apply."""

import json
import os
import subprocess
import sys
import uuid


def collisions(groups, prefix, names):
    names = {name.lower() for name in names}
    return sorted(
        group["name"] for group in groups
        if (prefix and group["name"].lower().startswith(prefix.lower()))
        or group["name"].lower() in names
    )


def main():
    try:
        subscription = str(uuid.UUID(os.environ["AZURE_SUBSCRIPTION_ID"]))
        prefix = os.environ["WORKLOAD_RG_PREFIX"]
        names = json.loads(os.environ["RESERVED_GROUP_NAMES"])
        if (prefix and not prefix.startswith("snce-")) or not isinstance(names, list) or not all(isinstance(n, str) and n for n in names) or not names:
            raise ValueError("unexpected namespace")
        result = subprocess.run(
            ["az", "group", "list", "--subscription", subscription,
             "--query", "[].{name:name}", "--output", "json", "--only-show-errors"],
            capture_output=True, text=True, check=True, timeout=60,
        )
        conflicts = collisions(json.loads(result.stdout), prefix, names)
        if conflicts:
            print("Reserved Azure namespace is already occupied; refusing adoption: " + ", ".join(conflicts), file=sys.stderr)
            return 1
        print("First-install namespace check passed; concurrent creation is not excluded.")
        return 0
    except (KeyError, ValueError, TypeError, OSError, subprocess.SubprocessError):
        print("Cannot establish that the reserved namespace is empty; refusing installation.", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
