#!/usr/bin/bash
set -euxo pipefail
CURRENT_BRANCH=$(git branch --show-current)
git remote set-head origin -a
MAIN_BRANCH="$(git symbolic-ref refs/remotes/origin/HEAD | cut -d/ -f4)"
git switch "$MAIN_BRANCH"
. ./env.sh
MAIN_IMAGE="$IMAGE"

SKIP=true
./check.sh || SKIP=false

$SKIP || ./build.sh

BRANCHES=$(git ls-remote -qb | sed 's|.*\srefs/heads/||')

for BRANCH in $BRANCHES; do
    [ "$BRANCH" != "$MAIN_BRANCH" ] || continue
    git fetch --depth=1 origin "refs/heads/$BRANCH:remotes/origin/$BRANCH"
    git switch -c "$BRANCH" "origin/$BRANCH"
    . ./env.sh
    if [ -e "diverge-$BRANCH" ]; then
        ./check.sh || ./build.sh
    else
        if ! $SKIP; then
            podman tag "$MAIN_IMAGE" "$IMAGE"
            ./push.sh
        fi
    fi
done
git switch "$CURRENT_BRANCH"
