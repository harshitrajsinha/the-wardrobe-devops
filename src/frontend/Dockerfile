FROM golang:1.26.2-alpine AS builder

ARG TARGETOS=linux
ARG TARGETARCH=amd64

WORKDIR /app

COPY ./src/go.mod ./src/go.sum ./
RUN go mod download

COPY ./src/. .

RUN GOOS=${TARGETOS} GOARCH=${TARGETARCH} CGO_ENABLED=0 go build -o frontend .

FROM alpine:latest

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

COPY --from=builder app/frontend /app/server

COPY ./src/templates ./templates
COPY ./src/static ./static

EXPOSE 8080

USER appuser

ENTRYPOINT ["/app/server"]
