#!/usr/bin/bash
set -euxo pipefail
. ./env.sh

DIGEST_NAME=$(systemd-escape "$IMAGE")
podman push --sign-by-sigstore-private-key keys/sealedblue-staged.private \
    --sign-passphrase-file keys/sealedblue-staged.passphrase \
    --digestfile "${DIGEST_NAME}.digest" \
    "${IMAGE}"

git add "${DIGEST_NAME}.digest"
git commit -m "${IMAGE} pushed" || true
git push
