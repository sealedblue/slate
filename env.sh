#!/usr/bin/bash
set -euo pipefail
BUILD_ARGS="${BUILD_ARGS:-}"
PROJECT_NAME="$(basename $PWD)"
MAIN_BRANCH=main
CURRENT_BRANCH="$(git branch --show-current)"
SIGSTORE_PUB=$(echo keys/*.pub)
SIGSTORE_PREFIX=${SIGSTORE_PUB%.*}
[ -z ${GITHUB_REPOSITORY-} ] || IMAGE_PREFIX=ghcr.io/${GITHUB_REPOSITORY%/*}
IMAGE_NAME="${IMAGE_PREFIX}/${PROJECT_NAME}"
IMAGE="${IMAGE_NAME}:${CURRENT_BRANCH}-unsealed"
MAIN_IMAGE="${IMAGE_NAME}:${MAIN_BRANCH}-unsealed"
DIGEST_NAME=$(systemd-escape "$IMAGE")

BASE_IMAGE_NAME="${IMAGE_PREFIX}/silverblue-nvidia"
BASE_IMAGE="${BASE_IMAGE_NAME}:${CURRENT_BRANCH}-unsealed"
