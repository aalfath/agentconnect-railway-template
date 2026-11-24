# AgentConnect Control Plane (API, daemon WebSocket gateway) for Railway.
# Upstream image pinned by release tag and multi-arch index digest.
FROM ghcr.io/agentconnect-md/prisma-cli:7.8.0-node24-r2@sha256:742ea24259c8bf135a01a76fd737dbc272c0f01824d8afa946318deefc001677 AS prisma

FROM ghcr.io/agentconnect-md/control-plane:v2.18.0@sha256:92d88b774aaf0e60e7834d230f9730613a7aa4b73dda80252a35daad2eab2a0a

# Prisma CLI (upstream's own pinned migration runner) plus the schema and
# migrations shipped in this exact control-plane image, so migrations run in the
# start script instead of a separate one-shot container.
RUN apt-get update \
  && apt-get install -y --no-install-recommends openssl \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p /migration \
  && cp -R /app/packages/control-plane/prisma /migration/prisma
COPY --from=prisma /opt/prisma-cli /opt/prisma-cli
COPY start.sh /usr/local/bin/agentconnect-control-plane

# Railway's private network is IPv6: listen on every address family.
# Small-plan defaults: a bounded heap and connection pool.
ENV HOST=:: \
  PORT=8080 \
  DATABASE_POOL_MAX=10 \
  DAEMON_DIST_TAG=2.18.0 \
  NODE_OPTIONS=--max-old-space-size=320

WORKDIR /app/packages/control-plane
CMD ["/usr/local/bin/agentconnect-control-plane"]
