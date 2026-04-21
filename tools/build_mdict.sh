#!/bin/bash
# Build ECDICT MDX dictionary for Lando app
#
# Prerequisites:
#   pip3 install writemdict
#   git clone https://github.com/skywind3000/ECDICT.git
#
# Usage:
#   1. Clone ECDICT: git clone https://github.com/skywind3000/ECDICT.git
#   2. Install dependencies: pip install writemdict
#   3. Run: ./build_mdict.sh [output_path]
#
# Output: ecdict.mdx file in the specified output directory

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="${1:-$PROJECT_ROOT/assets/mdict}"

echo "=========================================="
echo "  ECDICT MDX Builder for Lando"
echo "=========================================="
echo ""

# Create output directory if not exists
mkdir -p "$OUTPUT_DIR"

# Check if ECDICT source exists
ECDICT_DIR="$PROJECT_ROOT/../ECDICT"
if [ ! -d "$ECDICT_DIR" ]; then
    echo "ECDICT not found. Cloning from GitHub..."
    cd "$PROJECT_ROOT/.."
    git clone https://github.com/skywind3000/ECDICT.git
    cd "$PROJECT_ROOT"
    ECDICT_DIR="$PROJECT_ROOT/../ECDICT"
fi

cd "$ECDICT_DIR"

# Check Python environment
if ! command -v python3 &> /dev/null; then
    echo "Error: Python3 not found. Please install Python 3.8+"
    exit 1
fi

# Install writemdict if not installed
if ! python3 -c "import writemdict" 2>/dev/null; then
    echo "Installing writemdict..."
    pip3 install --user writemdict
fi

echo "Building ECDICT MDX file..."
echo "Source: $ECDICT_DIR"
echo "Output: $OUTPUT_DIR/ecdict.mdx"
echo ""

# Run the conversion
python3 -c "
import sys
sys.path.insert(0, '$ECDICT_DIR')
from stardict import DictHelper

helper = DictHelper()

# Load the database (ecdict.db or stardict.db)
db_path = '$ECDICT_DIR/ecdict.db'
if not helper.open_dict(db_path):
    # Try stardict.db
    db_path = '$ECDICT_DIR/stardict.db'
    if not helper.open_dict(db_path):
        print('Error: Could not find ecdict.db in $ECDICT_DIR')
        sys.exit(1)

print(f'Loaded database from: {db_path}')

# Generate word map
word_map = helper.dump_map(db_path, split_definition=False)
print(f'Loaded {len(word_map)} entries')

# Export to MDX
output_path = '$OUTPUT_DIR/ecdict.mdx'
print(f'Exporting to MDX: {output_path}')
helper.export_mdx(
    word_map,
    output_path,
    title='ECDICT',
    desc='English-Chinese Dictionary - Open Source'
)

print('')
print('Build complete!')
print(f'Output: {output_path}')
"

# Check file size
if [ -f "$OUTPUT_DIR/ecdict.mdx" ]; then
    SIZE=$(du -h "$OUTPUT_DIR/ecdict.mdx" | cut -f1)
    echo "File size: $SIZE"
fi

echo ""
echo "Done! Copy the ecdict.mdx to your assets/mdict/ directory."
