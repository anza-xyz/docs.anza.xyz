#!/usr/bin/env bash
set -ex

cd "$(dirname "$0")"

./convert-ascii-to-svg.sh
./set-solana-release-tag.sh

# Build from /src into /build
pnpm run build
echo $?
