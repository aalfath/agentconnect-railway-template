# Public gateway for AgentConnect on Railway: one HTTPS origin for the console,
# the API (/cp) and the relay (/relay), with a login in front of the console.
FROM caddy:2.11.9-alpine@sha256:003a97808e781aa9f7e75cc2f43d34d461099031faf5e20faefb9f61126836f0

COPY Caddyfile /etc/caddy/Caddyfile
COPY start.sh /usr/local/bin/agentconnect-gateway
ENV GOMAXPROCS=2

CMD ["/usr/local/bin/agentconnect-gateway"]
