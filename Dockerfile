FROM node:22-bookworm-slim

ARG USERNAME=node
ENV NODE_ENV=production
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --omit=dev

COPY cli.js index.js ./

RUN npx -y playwright-core install-deps chromium && \
    npx -y playwright-core install --no-shell chromium

RUN chown -R ${USERNAME}:${USERNAME} /app /ms-playwright

USER ${USERNAME}

EXPOSE 8931

ENTRYPOINT ["node", "/app/cli.js", "--headless", "--browser", "chromium", "--no-sandbox"]
