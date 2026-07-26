#!/usr/bin/bash
set -euo pipefail
. ./env.sh

pkg-list() {
    podman run --rm "$1" rpm -q --qf="%{NAME}\n" -a
}

DIFF=$(printf '%s\n%s\n' "$(pkg-list "$BASE_IMAGE")" "$(pkg-list "$IMAGE")" | sort | uniq -u)
set -x
podman run --rm "$IMAGE" dnf check-upgrade $DIFF

DIGEST="$(podman image inspect --format '{{index .Annotations "org.opencontainers.image.base.digest"}}' "${IMAGE}")"
podman pull "${BASE_IMAGE}"
podman inspect "${BASE_IMAGE}" | jq -e --arg digest "${BASE_IMAGE_NAME}@${DIGEST}" '.[].RepoDigests | any(. == $digest)'
