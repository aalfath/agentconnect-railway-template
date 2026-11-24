# AgentConnect web console (Next.js) for Railway.
# Upstream image pinned by release tag and index digest.
FROM ghcr.io/agentconnect-md/web:v2.18.0@sha256:df79d1490a8006ef301a4e7784e43e74a4a82a308ad91f9953975d6432840d37

# Railway's private network is IPv6: listen on every address family.
ENV HOSTNAME=:: \
  PORT=8080 \
  NEXT_TELEMETRY_DISABLED=1 \
  NODE_OPTIONS=--max-old-space-size=256
