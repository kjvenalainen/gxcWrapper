#!/usr/bin/env bash

# Wrapper script for an xcodebuild command that invokes the build with `-gen-cdb-fragment-path`
# to generate clangd-compatible compilation database fragments and appends them to `compile_commands.json`.
#
# Example usage:
#  ./gxcWrapper.sh xcodebuild -workspace MyWorkspace.xcworkspace -scheme MyScheme build

readonly GXC_SCRIPT_DIR="$(dirname "$0")"
readonly FRAGMENT_DIR="cdb"
readonly OUTPUT_FILE="compile_commands.json"

# Ensure that python3 is installed.
if ! command -v python3 &> /dev/null; then
  echo "Python 3 is required to run this script and must be present on your PATH." >&2
  exit 1
fi

# Ensure that the build command does not contain `OTHER_CFLAGS`.
if grep -q 'OTHER_CFLAGS' <<< "$*"; then
  echo "OTHER_CLAGS detected in build command! This is unsupported as they will be overridden." >&2
  exit 1
fi

# Delete FRAGMENT_DIR contents.
rm -rf $FRAGMENT_DIR/*

# Invoke the wrapped compile command.
"$@" OTHER_CFLAGS="-gen-cdb-fragment-path $FRAGMENT_DIR"

# Invoke `gxcWrapper.py` to append the compilation database fragments to `compile_commands.json`.
python3 $GXC_SCRIPT_DIR/gxcWrapper.py "$FRAGMENT_DIR" "$OUTPUT_FILE"