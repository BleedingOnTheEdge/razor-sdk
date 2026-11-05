#!/usr/bin/env bash
set -eo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
echo "🧪 Testing Razor SDK..."
dotnet test "${ROOT_DIR}/Sdk.slnx" -c "${1:-Release}" --verbosity minimal
echo "✓ All Razor SDK tests passed."
