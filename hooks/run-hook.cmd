#!/usr/bin/env bash
# Cross-platform hook dispatcher. Called as: run-hook.cmd <hook-name>
# On Windows, bash runs via WSL/Git Bash. On macOS/Linux, runs natively.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOOK_NAME="${1:?Usage: run-hook.cmd <hook-name>}"
exec "$SCRIPT_DIR/${HOOK_NAME}.sh"
