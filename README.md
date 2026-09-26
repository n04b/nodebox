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

The upstream project provides an interactive setup command.

```bash
docker exec -it nodebox bash
cd /opt/pm2-webui
npm run setup-admin-user
```

Then restart the WebUI if needed:

```bash
docker compose restart
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

## Important

This image intentionally runs all Node.js applications as normal processes
inside the same container. It does NOT create one Docker container per app.

The container therefore needs to be treated as a trusted execution environment:
any application running inside it can potentially access other applications
and the PM2/WebUI filesystem.

Upstream project:
https://github.com/isuryatk/pm2-webui
