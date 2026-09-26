#!/bin/sh
set -e

# Docker creates missing bind-mount sources as root:root, which hides the
# ownership set in the image. PM2 and the WebUI run as node, so fix it here.
mkdir -p "$PM2_HOME" "$WORKSPACE"
chown -R node:node "$PM2_HOME"
chown node:node "$WORKSPACE"

exec "$@"
