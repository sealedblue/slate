ARG BASE_IMAGE
FROM $BASE_IMAGE
RUN \
    --mount=type=tmpfs,target=/run \
    --mount=type=tmpfs,target=/tmp \
    --mount=type=bind,source=scripts,target=/scripts \
/scripts/prepare
COPY files /
