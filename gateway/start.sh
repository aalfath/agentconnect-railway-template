#!/bin/sh
# Hash the deployment password, then run Caddy in the foreground. Any failure
# exits non-zero so Railway restarts the service.
set -eu

fail() { echo "gateway: $*" >&2; exit 1; }

[ -n "${AGENTCONNECT_PASSWORD:-}" ] || fail "AGENTCONNECT_PASSWORD must be set"
[ "${#AGENTCONNECT_PASSWORD}" -ge 12 ] || fail "AGENTCONNECT_PASSWORD must be at least 12 characters"
export AGENTCONNECT_USERNAME="${AGENTCONNECT_USERNAME:-admin}"
export PORT="${PORT:-8080}"

for name in CP_UPSTREAM WEB_UPSTREAM RELAY_UPSTREAM; do
  eval "value=\${$name:-}"
  case "$value" in
    ''|:*|*.railway.internal) fail "$name must be host:port (got '$value')" ;;
  esac
done

AGENTCONNECT_PASSWORD_HASH="$(caddy hash-password --plaintext "$AGENTCONNECT_PASSWORD")" \
  || fail "could not hash the password"
export AGENTCONNECT_PASSWORD_HASH
unset AGENTCONNECT_PASSWORD

exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
