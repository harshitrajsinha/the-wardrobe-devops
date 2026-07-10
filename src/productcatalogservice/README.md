# productcatalogservice

Run the following command to restore dependencies to `vendor/` directory:

    go mod vendor

## Dynamic catalog reloading / artificial delay

This service has a "dynamic catalog reloading" feature that is purposefully
not well implemented. The goal of this feature is to allow you to modify the
`products.json` file and have the changes be picked up without having to
restart the service.

However, this feature is bugged: the catalog is actually reloaded on each
request, introducing a noticeable delay in the frontend. This delay will also
show up in profiling tools: the `parseCatalog` function will take more than 80%
of the CPU time.

You can trigger this feature (and the delay) by sending a `USR1` signal and
remove it (if needed) by sending a `USR2` signal:

```
# Trigger bug
kubectl exec \
    $(kubectl get pods -l app=productcatalogservice -o jsonpath='{.items[0].metadata.name}') \
    -c server -- kill -USR1 1
# Remove bug
kubectl exec \
    $(kubectl get pods -l app=productcatalogservice -o jsonpath='{.items[0].metadata.name}') \
    -c server -- kill -USR2 1
```

## Latency injection

This service has an `EXTRA_LATENCY` environment variable. This will inject a sleep for the specified [time.Duration](https://golang.org/pkg/time/#ParseDuration) on every call to
to the server.

For example, use `EXTRA_LATENCY="5.5s"` to sleep for 5.5 seconds on every request.


## Running project via Docker

1. Change directory
```bash
cd microservices-demo/src/productcatalogservice
```

2. Build productcatalogservice docker image
```bash
docker build -t test/productcatalogservice:test .
```

4. Build productcatalogservice docker image
```bash
docker run --name productcatalogservice -p 3550:3550 --env-file ./src/.env --network boutique-shop test/productcatalogservice:test
```


#####################################################################################################
#####################################################################################################
#####################################################################################################

# Product Catalog Service

The **Product Catalog Service** is a gRPC-based microservice responsible for serving product information for an e-commerce platform. It provides APIs for listing products, retrieving product details, and searching the product catalog.

The service supports loading product data either from a local JSON file or from **Google Cloud AlloyDB**, making it suitable for both local development and cloud deployments.

---

# Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Technology Stack](#technology-stack)
- [Features](#features)
- [Project Structure](#project-structure)
- [Application Startup](#application-startup)
- [Data Sources](#data-sources)
- [gRPC API](#grpc-api)
- [Catalog Loading](#catalog-loading)
- [Business Logic](#business-logic)
- [Health Checks](#health-checks)
- [Configuration](#configuration)
- [Dependencies](#dependencies)
- [Integration with Other Services](#integration-with-other-services)
- [Observability](#observability)
- [Design Patterns](#design-patterns)
- [Strengths](#strengths)
- [Limitations](#limitations)

---

# Overview

The Product Catalog Service manages product information for an online store.

Its primary responsibilities include:

- Listing all available products
- Returning detailed information for a product
- Searching products by keyword
- Loading catalog data from configurable sources
- Serving product information over gRPC

Unlike services that modify business data, this service is primarily **read-only**.

---

# Architecture

```text
                Client / Frontend
                       │
                    gRPC Calls
                       │
                       ▼
            Product Catalog Service
                       │
          ┌────────────┴────────────┐
          │                         │
     products.json             Google AlloyDB
```

---

# Technology Stack

| Component | Technology |
|-----------|------------|
| Language | Go |
| Framework | gRPC |
| Runtime | Go 1.25+ |
| Communication | gRPC |
| Serialization | Protocol Buffers |
| Database | Google AlloyDB |
| Local Storage | JSON |
| Logging | Logrus |
| Tracing | OpenTelemetry |
| Profiling | Google Cloud Profiler |
| Secret Management | Google Secret Manager |

---

# Project Structure

```text
productcatalogservice/

├── src/
│   ├── server.go
│   ├── product_catalog.go
│   ├── catalog_loader.go
│   ├── products.json
│   ├── product_catalog_test.go
│   ├── go.mod
│   └── genproto/
│
├── Dockerfile
├── Dockerfile.compose
└── README.md
```

---

# Application Startup

Entry point:

```text
server.go
```

Startup sequence:

```text
Application Starts
        │
Load Environment Variables
        │
Initialize Logging
        │
Enable Tracing (Optional)
        │
Enable Profiling (Optional)
        │
Load Product Catalog
        │
Register gRPC Services
        │
Start Server
```

The server listens on:

```
PORT
```

Default:

```
3550
```

---

# Data Sources

The catalog can be loaded from two different sources.

## Local JSON

Default source:

```
products.json
```

The JSON file is parsed into Protocol Buffer objects.

Suitable for:

- Local development
- Testing
- Demo environments

---

## Google AlloyDB

Activated when:

```
ALLOYDB_CLUSTER_NAME
```

is configured.

Additional configuration:

- PROJECT_ID
- REGION
- ALLOYDB_INSTANCE_NAME
- ALLOYDB_DATABASE_NAME
- ALLOYDB_TABLE_NAME
- ALLOYDB_SECRET_NAME

Database password is retrieved securely using:

```
Google Secret Manager
```

---

# gRPC API

The service exposes three primary RPC methods.

---

## ListProducts

Returns every product available in the catalog.

### Request

```protobuf
Empty
```

### Response

```protobuf
ListProductsResponse
```

Returns:

- Product ID
- Name
- Description
- Categories
- Price
- Images

---

## GetProduct

Retrieves information for a single product.

### Request

```protobuf
GetProductRequest
```

Field:

```
id
```

Behavior:

- Searches catalog
- Returns matching product
- Returns NOT_FOUND if absent

---

## SearchProducts

Searches products by keyword.

### Request

```protobuf
SearchProductsRequest
```

Field:

```
query
```

Searches:

- Product name
- Product description

Search is:

- Case insensitive
- Partial match

---

# Catalog Loading

Catalog loading is handled by:

```
catalog_loader.go
```

Loading strategy:

```text
Load Catalog
      │
      ▼
Is AlloyDB Configured?
      │
 ┌────┴────┐
 │         │
Yes       No
 │         │
 ▼         ▼
AlloyDB   products.json
```

To ensure thread safety, loading is protected using a mutex.

---

# Business Logic

## List Products

```
Request

↓

Load Catalog

↓

Return Products
```

---

## Get Product

```
Request

↓

Search Product ID

↓

Found?
   │
 ┌─┴─────┐
 │       │
Yes      No
 │       │
 ▼       ▼
Return   NOT_FOUND
Product
```

---

## Search Products

Every product is checked against:

- Name
- Description

Matching products are returned.

---

# Health Checks

The service implements the standard gRPC Health API.

Supported:

```
Check()
```

Returns:

```
SERVING
```

Not implemented:

```
Watch()
```

Returns:

```
UNIMPLEMENTED
```

---

# Configuration

## Server

| Variable | Purpose |
|----------|---------|
| PORT | Server port |

---

## Tracing

| Variable | Purpose |
|----------|---------|
| ENABLE_TRACING | Enable OpenTelemetry |
| COLLECTOR_SERVICE_ADDR | OTLP Collector |

---

## Profiling

| Variable | Purpose |
|----------|---------|
| DISABLE_PROFILER | Disable Cloud Profiler |

---

## Performance Testing

| Variable | Purpose |
|----------|---------|
| EXTRA_LATENCY | Inject artificial request latency |

Example:

```
EXTRA_LATENCY=5s
```

---

## AlloyDB

| Variable | Purpose |
|----------|---------|
| PROJECT_ID | Google Cloud project |
| REGION | AlloyDB region |
| ALLOYDB_CLUSTER_NAME | Cluster |
| ALLOYDB_INSTANCE_NAME | Instance |
| ALLOYDB_DATABASE_NAME | Database |
| ALLOYDB_TABLE_NAME | Products table |
| ALLOYDB_SECRET_NAME | Password secret |

---

# Dependencies

Major packages include:

| Package | Purpose |
|----------|----------|
| google.golang.org/grpc | gRPC server |
| protobuf | Protocol Buffers |
| Logrus | Structured logging |
| OpenTelemetry | Distributed tracing |
| Google Cloud Profiler | Performance profiling |
| AlloyDB Connector | Database connectivity |
| pgx | PostgreSQL driver |
| Google Secret Manager | Credential retrieval |

---

# Observability

## Structured Logging

Uses:

```
Logrus
```

Output:

- JSON logs
- RFC3339 timestamps
- Severity levels

---

## Distributed Tracing

Supports:

- OpenTelemetry
- OTLP Exporter

Enabled by:

```
ENABLE_TRACING=1
```

---

## Profiling

Uses:

```
Google Cloud Profiler
```

Enabled by default.

Can be disabled:

```
DISABLE_PROFILER=1
```

---

# Special Debug Features

## Dynamic Catalog Reload

Sending:

```
SIGUSR1
```

enables catalog reload on every request.

Sending:

```
SIGUSR2
```

disables it.

This feature is intended for debugging and demonstration purposes.

---

## Artificial Latency

Every request can be delayed by:

```
EXTRA_LATENCY
```

Useful for:

- Chaos engineering
- Performance testing
- Demonstrating distributed tracing

---

## Dependency Isolation

Business logic is separated from persistence:

- server.go → server startup
- product_catalog.go → gRPC handlers
- catalog_loader.go → data loading

---

# Summary

The Product Catalog Service is a lightweight, read-only microservice that provides high-performance access to product information via gRPC. It supports local JSON and Google AlloyDB as catalog sources, integrates with OpenTelemetry and Google Cloud Profiler for observability, and fits naturally into a cloud-native e-commerce architecture. Its modular design separates server startup, business logic, and data loading, making it easy to maintain, extend, and deploy.