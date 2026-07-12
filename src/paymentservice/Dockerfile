FROM node:24.18.0-alpine AS builder


RUN apk add --update --no-cache \
    python3 \
    make \
    g++

WORKDIR /app

COPY ./src/package*.json ./

RUN npm install --only=production

FROM alpine:3.23.4

RUN apk add --no-cache nodejs

WORKDIR /app

COPY --from=builder /app/node_modules ./node_modules

COPY ./src/. .

EXPOSE 50052

ENTRYPOINT [ "node", "index.js" ]
