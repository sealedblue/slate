#!/usr/bin/bash
set -euo pipefail
SIGSTORE_PUB=$(echo keys/*.pub)
SIGSTORE_PREFIX=${SIGSTORE_PUB%.*}
[ ${GITHUB_REPOSITORY-} ] && IMAGE_PREFIX=ghcr.io/${GITHUB_REPOSITORY%/*}
IMAGE_NAME="$(basename $PWD)"
TAG="$(git branch --show-current)"
BASE_IMAGE="${IMAGE_PREFIX}/silverblue-nvidia:${TAG}-unsealed"
IMAGE="${IMAGE_PREFIX}/${IMAGE_NAME}:${TAG}-unsealed"
