#!/bin/bash

# Apply patches for coverity

# Directory to cd into before applying patches
TARGET_DIR="$1"

# Check environment
[ -z "$CI_PATCH_DIR" ] && echo "ERROR: CI_PATCH_DIR must be set" && exit 1

set -x

pushd "$TARGET_DIR"
for p in $CI_PATCH_DIR/cov-*
do
	echo "$p"
	patch --verbose -p1 < "$p"
done

popd
