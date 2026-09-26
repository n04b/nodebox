# PM2 WebUI Docker image

One container containing:

- Node.js 22
- PM2
- isuryatk/pm2-webui
- Supervisor
- a persistent `/workspace` for Node.js applications

PM2 and PM2 WebUI run as the same `node` user and use the same `PM2_HOME`,
so the WebUI sees processes created with the PM2 CLI.

## Start

```bash
docker compose up -d --build
```

Open:

http://localhost:4343

## First admin setup

### Option A: automatic (recommended)

Copy `.env.example` to `.env`, set the credentials, and the admin user is
created on first start:

```bash
cp .env.example .env
# edit .env, then:
docker compose up -d --build
```

The values are written once to the persistent WebUI `.env` and then ignored,
so pm2-webui starts without needing a manual setup step.

### Option B: interactive

Leave the credentials unset and run the upstream setup command by hand:

```bash
docker exec -it nodebox bash
cd /opt/pm2-webui
npm run setup-admin-user
docker compose restart nodebox
```

## Start a Node.js application

Put your app in `./workspace`, for example:

```text
workspace/
  my-app/
    package.json
    index.js
```

Then:

```bash
docker exec -it nodebox bash
cd /workspace/my-app
npm install
pm2 start index.js --name my-app
pm2 save
```

The process will appear in PM2 WebUI.

## Persistence

- `/workspace` is bind-mounted and contains your applications.
- `/pm2` stores PM2 state and logs.
- `/data/webui` stores the PM2 WebUI `.env` (admin user and session secret),
  so `setup-admin-user` only has to be run once and survives rebuilds.

## Important

This image intentionally runs all Node.js applications as normal processes
inside the same container. It does NOT create one Docker container per app.

The container therefore needs to be treated as a trusted execution environment:
any application running inside it can potentially access other applications
and the PM2/WebUI filesystem.

Upstream project:
https://github.com/isuryatk/pm2-webui
