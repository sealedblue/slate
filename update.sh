#!/usr/bin/bash
set -euxo pipefail
. ./env.sh
OLD_BRANCH="$CURRENT_BRANCH"
git switch "$MAIN_BRANCH"
. ./env.sh

./check.sh || ./build.sh

BRANCHES=$(git ls-remote -qb | sed 's|.*\srefs/heads/||')

for BRANCH in $BRANCHES; do
    [ "$BRANCH" != "$MAIN_BRANCH" ] || continue
    git fetch --depth=1 origin "refs/heads/$BRANCH:remotes/origin/$BRANCH"
    git switch "$BRANCH" || git switch -c "$BRANCH" "origin/$BRANCH"
    . ./env.sh
    if [ -e "diverge-$BRANCH" ]; then
        ./check.sh || ./build.sh
    else
        MAIN_DIGEST=$(skopeo inspect --format='{{.Digest}}' "docker://${MAIN_IMAGE}")
        IMAGE_DIGEST=$(skopeo inspect --format='{{.Digest}}' "docker://${IMAGE}")
        if [ "$MAIN_DIGEST" != "$IMAGE_DIGEST" ]; then
            skopeo copy --sign-by-sigstore-private-key "${SIGSTORE_PREFIX}.private" \
                --sign-passphrase-file "${SIGSTORE_PREFIX}.passphrase" \
                --digestfile "${DIGEST_NAME}.digest" \
                "docker://${MAIN_IMAGE}" "docker://${IMAGE}"
            git add "${DIGEST_NAME}.digest"
            git commit -m "${IMAGE} pushed" || true
            git push
        fi
    fi
done
git switch "$OLD_BRANCH"
