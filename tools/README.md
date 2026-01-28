# Tools

This directory contains utility scripts and tools for the Lando project.

## Available Tools

### cloc.sh

Counts lines of code in the project, excluding build artifacts and generated files.

**Usage:**
```bash
# From project root
./tools/cloc.sh

# Or
bash tools/cloc.sh
```

**What it excludes:**
- `.dart_tool/` - Flutter build artifacts
- `build/` - Build output directories
- `ios/Pods/` - iOS dependencies
- `macos/Pods/` - macOS dependencies
- `android/.gradle/` - Android build cache
- `.flutter-plugins-dependencies` - Flutter plugin dependencies
- Assembly files (`.s`, `.S`, `.asm`, `.ASM`) - Generated assembly files

### .clocignore

Configuration file for cloc (code line counter) that lists directories and file patterns to exclude from code statistics.
