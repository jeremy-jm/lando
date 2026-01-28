#!/bin/bash
# Count lines of code excluding build artifacts and generated files
#
# Usage: ./tools/cloc.sh
# Or from project root: bash tools/cloc.sh

# Get the project root directory (parent of tools/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT" || exit 1

cloc . \
  --fullpath \
  --not-match-d='(\.dart_tool|build|ios/Pods|macos/Pods|android/\.gradle|\.flutter-plugins-dependencies)' \
  --exclude-ext=s,S,asm,ASM
