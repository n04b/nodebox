FROM node:22-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/home/node
ENV PM2_HOME=/home/node/.pm2
ENV WORKSPACE=/workspace
ENV HOST=0.0.0.0
ENV PORT=4343

RUN apt-get update && apt-get install -y --no-install-recommends         git         supervisor         ca-certificates         procps         bash         curl         && rm -rf /var/lib/apt/lists/*

# PM2 CLI for managing the Node.js processes in this same container.
RUN npm install -g pm2@latest

# isuryatk/pm2-webui: open-source PM2 Plus alternative.
RUN git clone --depth 1 https://github.com/isuryatk/pm2-webui.git /opt/pm2-webui         && cd /opt/pm2-webui         && npm ci --omit=dev         && chown -R node:node /opt/pm2-webui

RUN mkdir -p /workspace /home/node/.pm2 /home/node/.config         && chown -R node:node /workspace /home/node

COPY supervisord.conf /etc/supervisor/conf.d/nodebox.conf
COPY --chmod=755 docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

WORKDIR /workspace

EXPOSE 4343 8080-8099

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
