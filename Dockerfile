# Build stage
FROM node:22-bookworm-slim AS build

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --omit=dev

COPY cli.js index.js index.d.ts config.d.ts ./

# Install playwright chromium deps and browser
RUN npx -y playwright-core install-deps chromium && \
    npx -y playwright-core install --no-shell chromium

# Runtime stage
FROM node:22-bookworm-slim AS runtime

ARG USERNAME=node
ENV NODE_ENV=production
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

WORKDIR /home/${USERNAME}

COPY --from=build --chown=${USERNAME}:${USERNAME} /app /app
COPY --from=build --chown=${USERNAME}:${USERNAME} /ms-playwright /ms-playwright

USER ${USERNAME}

EXPOSE 8931

ENTRYPOINT ["node", "/app/cli.js", "--headless", "--browser", "chromium", "--no-sandbox"]
