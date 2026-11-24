# AgentConnect on Railway

One-click Railway template for [AgentConnect](https://github.com/agentconnect-md/agentconnect)
**v2.18.0**, the open-source (Apache-2.0) multi-agent workspace: @-mention
Claude Code, Codex, DeepSeek, Grok Build or any ACP agent in shared threads, in
the web console, Slack, Microsoft Teams, Discord, Telegram, GitHub, GitLab,
Linear and more.

## What it deploys

| Service | Built from | What it does |
| --- | --- | --- |
| **Gateway** | `gateway/` (Caddy 2.11.9) | The only public URL. Asks for the generated login before the console or API, and routes `/cp/*` to the Control Plane and `/relay/*` to the Relay |
| **Control Plane** | `control-plane/` (`ghcr.io/agentconnect-md/control-plane:v2.18.0`) | API, daemon WebSocket gateway, scheduler. Runs the database migrations on start |
| **Relay** | `relay/` (`ghcr.io/agentconnect-md/relay:v2.18.0`) | Ingress for webhooks, chat platforms, webchat and daemon relay sockets |
| **Web** | `web/` (`ghcr.io/agentconnect-md/web:v2.18.0`) | The Next.js web console |
| **Postgres** | Railway Postgres 18 | All AgentConnect data, on a volume |

Every upstream image is pinned by release tag **and** digest in the service's
`Dockerfile`. Services talk over Railway's private network.

## Variables

You don't have to fill in anything: every secret is generated.

| Service | Variable | Default | Notes |
| --- | --- | --- | --- |
| Gateway | `AGENTCONNECT_USERNAME` | `admin` | Console login user name |
| Gateway | `AGENTCONNECT_PASSWORD` | generated, 24 chars | Console login password. Read it in the Gateway service's **Variables** tab |
| Control Plane | `API_KEY_PEPPER` | generated, 48 chars | Hashes API keys. **Never change it** after the first deploy: every daemon and API key would stop working |
| Control Plane | `RELAY_TOKEN` | generated, 48 chars | Shared secret between Control Plane and Relay |
| all | `PORT`, `*_URL`, `*_UPSTREAM` | references | Wiring between the services and the public domain |

## After you deploy

1. Open the Gateway's public URL and sign in with `admin` and the generated
   `AGENTCONNECT_PASSWORD`.
2. In the console, go to **Daemons → Add daemon**. It shows a one-time command
   such as `npx -y @agentconnect.md/daemon@2.18.0 run --api-url wss://YOUR-DOMAIN/cp/daemon/ws --api-key …`.
   Run it on the machine where your agents should work (your laptop or a
   server with Node.js 22+ and the repositories). Agents run there with that
   machine's own Claude Code, Codex or other CLI login, so this template never
   needs an LLM API key.
3. Talk to the built-in **AgentConnect** agent in the console, create more
   agents, then connect Slack, Telegram, GitHub and others from the console.
   Their webhooks go to `https://YOUR-DOMAIN/relay/...`.

## How the login works

AgentConnect's multi-user sign-in needs an OIDC provider (Logto). Without one,
its API treats every request as the single owner, and upstream warns never to
expose that mode publicly. This template therefore puts a login in front of
everything. The only routes that pass without it are the ones that carry their
own credential and are checked by AgentConnect itself:

- `/cp/daemon/ws`: daemon connections, authenticated by their API key;
- requests with an `Authorization: Bearer <key>` API key (no dots), which the
  API verifies and rejects with 401 when the key is wrong;
- `/relay/*`: webhooks and chat-platform events (signed or tokenised) and relay sockets;
- the agent and organization icon PNGs that chat apps fetch.

For several users with their own accounts, add Logto (self-hosted or Logto
Cloud) later and set `OIDC_ISSUER` and the `LOGTO_*` variables on Control Plane
and Web, as in the [upstream sign-in guide](https://www.agentconnect.md/docs/self-hosting/sign-in.md).

## Left out on purpose

- **Logto** (multi-user sign-in): needs an OAuth app and a manual setup wizard; see above.
- **Open Connector** gateway (the optional "Add connectors" catalogue): it has no
  authentication of its own and needs a second volume, which the Free plan doesn't allow.
- **TURN/STUN** for the Computer viewer: needs UDP ports, which Railway doesn't offer.
- **Setup server**: a loopback-only admin tool for the Logto flow.
- Code execution sandboxes run inside your daemon, not on Railway.

## Resources

All four app services and Postgres fit Railway's Free-plan limit of 0.5 GB RAM /
1 vCPU each. Measured on Railway with a connected daemon: Control Plane about
250 MB, Relay and Web about 85 MB each, Gateway about 15 MB. Only one volume
(Postgres) is used.

## Updates

This template is built from this repository. When a new AgentConnect release
is tested, its pins are bumped here, with an entry in `CHANGELOG.md` (breaking
changes first). Railway then shows **"update available"** on your project, and you
choose when to apply it. Migrations run automatically when the Control Plane starts.
Upstream images are on GHCR (`ghcr.io/agentconnect-md`).

## Licence

AgentConnect is Apache-2.0, by the AgentConnect authors. This wrapper is
provided as is; it isn't affiliated with the AgentConnect project.
