#!/usr/bin/env bash
set -eo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
echo "🔨 Building Razor SDK..."
dotnet build "${ROOT_DIR}/Sdk.slnx" -c "${1:-Release}"
echo "✓ Razor SDK build succeeded."
