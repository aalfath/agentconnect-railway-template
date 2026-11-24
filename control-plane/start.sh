#!/bin/sh
# Run database migrations (retrying while Postgres starts or another deploy
# holds Prisma's migration lock), then start the Control Plane.
set -eu

: "${DATABASE_URL:?DATABASE_URL must be set (reference the Postgres service)}"
: "${API_KEY_PEPPER:?API_KEY_PEPPER must be set}"

# A public URL built from a domain that did not exist yet resolves to
# "https:///cp"; drop it instead of failing config validation.
for name in PUBLIC_CP_URL PUBLIC_WEB_URL PUBLIC_RELAY_URL CORS_ORIGIN; do
  eval "value=\${$name:-}"
  case "$value" in
    https://?*.?*|http://?*) ;;
    '') unset "$name" ;;
    *) echo "start: ignoring invalid $name=$value" >&2; unset "$name" ;;
  esac
done

cd /opt/prisma-cli
attempt=1
until /opt/prisma-cli/node_modules/.bin/prisma migrate deploy >/tmp/migrate.log 2>&1; do
  if [ "$attempt" -ge 40 ]; then
    echo "start: database migration failed after $attempt attempts" >&2
    cat /tmp/migrate.log >&2
    exit 1
  fi
  echo "start: migration attempt $attempt failed, retrying in 5s: $(tail -n 1 /tmp/migrate.log)" >&2
  attempt=$((attempt + 1))
  sleep 5
done
tail -n 1 /tmp/migrate.log
rm /tmp/migrate.log

cd /app/packages/control-plane
exec node dist/index.js
