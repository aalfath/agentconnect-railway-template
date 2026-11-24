# AgentConnect Relay (integration ingress: webhooks, chat platforms, daemon and
# webchat sockets) for Railway. Upstream image pinned by tag and index digest.
FROM ghcr.io/agentconnect-md/relay:v2.18.0@sha256:7f5256507ecbe571c007a9a9894314a8bc3f9d0f00af2539ab06b2a9f3a8f08b

# Railway's private network is IPv6: listen on every address family.
ENV HOST=:: \
  PORT=8080 \
  NODE_OPTIONS=--max-old-space-size=256
