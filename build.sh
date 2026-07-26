#!/usr/bin/bash
set -euxo pipefail
. ./env.sh

if [[ "$TAG" != "$MAIN_BRANCH" ]] && ! [[ -e "diverge-$TAG" ]]; then
    skopeo copy --sign-by-sigstore-private-key "${SIGSTORE_PREFIX}.private" \
        --sign-passphrase-file "${SIGSTORE_PREFIX}.passphrase" \
        --digestfile "${DIGEST_NAME}.digest" \
        "docker://${MAIN_IMAGE}" "docker://${IMAGE}"
else
    podman pull  "$BASE_IMAGE"
    podman build \
        --security-opt=label=disable \
        --build-arg "BASE_IMAGE=$BASE_IMAGE" \
        -t "${IMAGE}" .
    podman push --sign-by-sigstore-private-key "${SIGSTORE_PREFIX}.private" \
        --sign-passphrase-file "${SIGSTORE_PREFIX}.passphrase" \
        --digestfile "${DIGEST_NAME}.digest" \
        "${IMAGE}"
fi
git add "${DIGEST_NAME}.digest"
git commit -m "${IMAGE} pushed" || true
git push
