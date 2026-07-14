# 跟随 Node LTS，长期自动获得安全更新，无需手动升主版本号
FROM node:lts-alpine

LABEL org.opencontainers.image.title="docsify-server" \
      org.opencontainers.image.description="A Dockerized docsify-cli server for serving Markdown docs." \
      org.opencontainers.image.source="https://github.com/rockbenben/docsify-docker" \
      org.opencontainers.image.licenses="MIT"

WORKDIR /docs

# 安装最新 docsify-cli 并清理缓存以减小镜像体积
RUN npm install -g docsify-cli@latest --no-fund --no-audit \
    && npm cache clean --force

# 内置离线起始模板（含 vendored 资产），供 entrypoint 在空目录时自举
COPY template/ /opt/docsify-template/
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 3000/tcp

# 简单健康检查：确认 serve 端口在响应
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget -q --spider http://127.0.0.1:3000 || exit 1

# entrypoint 内部用 exec 交棒给 docsify，使其成为 PID 1 优雅停止
ENTRYPOINT ["docker-entrypoint.sh"]
