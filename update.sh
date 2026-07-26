#!/usr/bin/bash
set -euxo pipefail
. ./env.sh
CURRENT_BRANCH="$TAG"
git switch "$MAIN_BRANCH"
. ./env.sh

SKIP=true
./check.sh || SKIP=false

$SKIP || ./build.sh

BRANCHES=$(git ls-remote -qb | sed 's|.*\srefs/heads/||')

for BRANCH in $BRANCHES; do
    [ "$BRANCH" != "$MAIN_BRANCH" ] || continue
    git fetch --depth=1 origin "refs/heads/$BRANCH:remotes/origin/$BRANCH"
    git switch "$BRANCH" || git switch -c "$BRANCH" "origin/$BRANCH"
    . ./env.sh
    if [ -e "diverge-$BRANCH" ]; then
        ./check.sh || ./build.sh
    else
        if ! $SKIP; then
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
git switch "$CURRENT_BRANCH"
