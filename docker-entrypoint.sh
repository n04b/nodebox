#!/bin/sh
set -e

# Docker creates missing bind-mount sources as root:root, which hides the
# ownership set in the image. PM2 and the WebUI run as node, so fix it here.
mkdir -p "$PM2_HOME" "$WORKSPACE"
chown -R node:node "$PM2_HOME"
chown node:node "$WORKSPACE"

# pm2-webui keeps its admin user and session secret in /opt/pm2-webui/.env,
# which lives in the image and would be lost on every rebuild. Persist it on a
# volume and symlink the app's .env at it, so setup-admin-user only runs once.
WEBUI_ENV_DIR=/data/webui
mkdir -p "$WEBUI_ENV_DIR"
if [ ! -e "$WEBUI_ENV_DIR/.env" ]; then
    if [ -f /opt/pm2-webui/.env ] && [ ! -L /opt/pm2-webui/.env ]; then
        cp /opt/pm2-webui/.env "$WEBUI_ENV_DIR/.env"
    else
        : > "$WEBUI_ENV_DIR/.env"
    fi
fi
ln -sfn "$WEBUI_ENV_DIR/.env" /opt/pm2-webui/.env

# Non-interactive admin setup: if PM2_WEBUI_USERNAME/PM2_WEBUI_PASSWORD are set
# and no admin exists yet, seed one using the app's own hashing routine. This
# replaces running `npm run setup-admin-user` by hand and lets pm2-webui start
# without entering FATAL on a fresh volume.
if [ -n "$PM2_WEBUI_USERNAME" ] && [ -n "$PM2_WEBUI_PASSWORD" ] \
    && ! grep -q '^APP_USERNAME=' "$WEBUI_ENV_DIR/.env"; then
    ( cd /opt/pm2-webui \
        && node -e "require('./src/services/admin.service').createAdminUser(process.env.PM2_WEBUI_USERNAME, process.env.PM2_WEBUI_PASSWORD)" )
fi

chown -R node:node "$WEBUI_ENV_DIR"

exec "$@"
