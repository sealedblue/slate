#!/usr/bin/bash
set -euo pipefail
MAIN_BRANCH=main
SIGSTORE_PUB=$(echo keys/*.pub)
SIGSTORE_PREFIX=${SIGSTORE_PUB%.*}
[ ${GITHUB_REPOSITORY-} ] && IMAGE_PREFIX=ghcr.io/${GITHUB_REPOSITORY%/*}
IMAGE_NAME="$(basename $PWD)"
TAG="$(git branch --show-current)"
IMAGE="${IMAGE_PREFIX}/${IMAGE_NAME}:${TAG}-unsealed"
MAIN_IMAGE="${IMAGE_PREFIX}/${IMAGE_NAME}:${MAIN_BRANCH}-unsealed"
DIGEST_NAME=$(systemd-escape "$IMAGE")

BASE_IMAGE="${IMAGE_PREFIX}/silverblue-nvidia:${TAG}-unsealed"
