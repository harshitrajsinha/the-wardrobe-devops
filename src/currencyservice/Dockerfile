FROM node:24.18.0-alpine AS builder

RUN apk add --update --no-cache \
    python3 \
    make \
    g++

WORKDIR /app

COPY ./src/package*.json ./

RUN npm ci --omit=dev

FROM node:24.18.0-alpine

WORKDIR /app

COPY --from=builder --chown=node:node /app/node_modules ./node_modules

COPY --chown=node:node ./src .

USER node

EXPOSE 7000

ENTRYPOINT [ "node", "server.js" ]
