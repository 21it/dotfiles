#!/bin/sh

set -eu pipefail

THISDIR="$(dirname "$(realpath "$0")")"
VERSION="0.1"

# for PLATFORM in arm64 x86_64; do
#   docker buildx build \
#     -t "21it/pihole:$PLATFORM-$VERSION" \
#     -f "Dockerfile.pihole" \
#     --platform "linux/$PLATFORM" .
# done

( cd "$THISDIR"
  docker build \
    -t "21it/pihole:$VERSION" \
    -f "Dockerfile.pihole" . )
