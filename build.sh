#!/usr/bin/env bash
set -ex

cd "$(dirname "$0")"

./set-solana-release-tag.sh

# Build from /src into /build
pnpm run build
echo $?
