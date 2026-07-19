#!/usr/bin/bash
set -euxo pipefail
. ./env.sh

podman pull  "$BASE_IMAGE"
podman build \
    --security-opt=label=disable \
    --build-arg "BASE_IMAGE=$BASE_IMAGE" \
    -t "${IMAGE}" .
./push.sh
