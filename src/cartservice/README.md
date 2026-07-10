# Run project using docker

1. Start redis
```bash
docker run --name redis -p 6379:6379 --network boutique-shop -d redis:alpine3.23
```

2. Change directory
```bash
cd microservices-demo/src/cartservice
```

2. Build cartservice docker image
```bash
docker build -t test/cartservice:test .
```

4. Build cartservice docker image
```bash
docker run --name cartservice -p 7070:7070 test/cartservice:test
```


##########################################################################################################
##########################################################################################################
##########################################################################################################
##########################################################################################################


# Cart Microservice

A gRPC-based shopping cart microservice built with **ASP.NET Core (.NET 10)**. This service is responsible for managing users' shopping carts in an e-commerce platform and supports multiple storage backends including **Redis**, **Google Cloud Spanner**, **Google AlloyDB**, and an **in-memory cache** for development.

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Technology Stack](#technology-stack)
- [Features](#features)
- [Project Structure](#project-structure)
- [Storage Backends](#storage-backends)
- [gRPC API](#grpc-api)
- [Data Models](#data-models)
- [Request Flow](#request-flow)
- [Configuration](#configuration)
- [Dependencies](#dependencies)
- [Integration with Other Services](#integration-with-other-services)
- [Design Patterns](#design-patterns)
- [Strengths](#strengths)
- [Limitations](#limitations)

---

# Overview

The Cart Service is an independent microservice responsible for managing shopping carts in an e-commerce application.

Its primary responsibilities include:

- Creating shopping carts
- Adding items to carts
- Retrieving a user's cart
- Emptying carts after checkout
- Persisting cart data

The service is **stateless**, meaning all business data is stored in an external datastore instead of application memory, allowing multiple service instances to run simultaneously.

---

# Architecture

```text
                  Client / Frontend
                         │
                         │ gRPC
                         ▼
                 Cart Microservice
                         │
        ┌────────────────┼────────────────┐
        │                │                │
     Redis Store     Cloud Spanner     AlloyDB
```

Within a complete e-commerce platform, the service typically fits into the following architecture:

```text
Client
   │
API Gateway
   │
Cart Service
   │
   ├── Redis
   ├── Product Catalog Service
   ├── Checkout Service
   ├── Order Service
   ├── Inventory Service
   └── Recommendation Service
```

---

# Technology Stack

| Component | Technology |
|-----------|------------|
| Language | C# |
| Framework | ASP.NET Core |
| Runtime | .NET 10 |
| Communication | gRPC |
| Protocol | HTTP/2 |
| Serialization | Protocol Buffers |
| Cache | Redis |
| Database | Google Cloud Spanner |
| Database | Google AlloyDB (PostgreSQL) |
| Dependency Injection | Microsoft.Extensions.DependencyInjection |

---

# Project Structure

```
CartService
│
├── Program.cs
├── Startup.cs
├── Protos/
│     └── Cart.proto
│
├── Services/
│     ├── CartService.cs
│     └── HealthCheckService.cs
│
├── Stores/
│     ├── ICartStore.cs
│     ├── RedisCartStore.cs
│     ├── SpannerCartStore.cs
│     └── AlloyDbCartStore.cs
│
└── appsettings.json
```

---

# Storage Backends

The service abstracts persistence using the `ICartStore` interface.

```text
               CartService
                    │
              ICartStore
                    │
       ┌────────────┼────────────┐
       │            │            │
   RedisStore   SpannerStore  AlloyDBStore
```

## Supported Backends

### Redis (Default)

Used when:

```
REDIS_ADDR
```

is configured.

Suitable for:

- Fast access
- Session storage
- High throughput

---

### Google Cloud Spanner

Activated when either of the following is configured:

```
SPANNER_PROJECT
```

or

```
SPANNER_CONNECTION_STRING
```

Suitable for:

- Global deployments
- High availability
- Strong consistency

---

### Google AlloyDB

Activated when:

```
ALLOYDB_PRIMARY_IP
```

is configured.

Suitable for:

- PostgreSQL compatibility
- High-performance relational storage

---

### In-Memory Cache

If no storage backend is configured, the service falls back to:

```
DistributedMemoryCache
```

This mode is intended **only for local development**.

---

# gRPC API

The service exposes three RPC endpoints.

## AddItem

Adds a product to a user's shopping cart.

### Request

```protobuf
AddItemRequest
```

Fields:

- user_id
- product_id
- quantity

Behavior:

- Creates a new cart if one doesn't exist.
- Adds a new product if it's not already present.
- Increases quantity if the product already exists.

---

## GetCart

Retrieves the current shopping cart.

### Request

```protobuf
GetCartRequest
```

### Response

```protobuf
Cart
```

Behavior:

- Returns all items in the user's cart.
- Returns an empty cart if none exists.

---

## EmptyCart

Clears all items from a user's cart.

### Request

```protobuf
EmptyCartRequest
```

Behavior:

- Replaces the existing cart with an empty cart.

---

# Data Models

## Cart

```protobuf
message Cart {
    string user_id = 1;
    repeated CartItem items = 2;
}
```

---

## CartItem

```protobuf
message CartItem {
    string product_id = 1;
    int32 quantity = 2;
}
```

Example:

```text
User: user123

Items

Laptop
Quantity: 1

Mouse
Quantity: 2
```

---

# Request Flow

## Add Item

```text
Client
   │
AddItem()
   │
CartService
   │
ICartStore
   │
Redis / Spanner / AlloyDB
   │
Updated Cart
```

---

## Get Cart

```text
Client
   │
GetCart()
   │
CartService
   │
ICartStore
   │
Deserialize Cart
   │
Return Cart
```

---

## Empty Cart

```text
Client
   │
EmptyCart()
   │
CartService
   │
ICartStore
   │
Overwrite Cart
```

---

# Business Logic

## Adding a Product

If the cart doesn't exist:

- Create a new cart
- Insert the first item

If the cart already exists:

- Append the new item

If the product already exists:

```
existing.Quantity += quantity
```

No duplicate cart items are created.

---

# Data Storage

Each user's cart is stored using:

```
Key   = User ID
Value = Serialized Protocol Buffer
```

Example:

```
john123
    ↓
Binary Protobuf
```

Serialization:

```csharp
cart.ToByteArray();
```

Deserialization:

```csharp
Cart.Parser.ParseFrom(...)
```

---

# Error Handling

All storage operations are wrapped in exception handling.

Internal exceptions are converted into:

```
RpcException
```

using

```
StatusCode.FailedPrecondition
```

This allows clients to receive meaningful gRPC errors instead of generic server failures.

---

# Health Checks

The service includes a Health Check endpoint for:

- Kubernetes readiness probes
- Kubernetes liveness probes
- Storage connectivity verification

---

# Configuration

The storage backend is selected automatically based on environment variables.

| Environment Variable | Description |
|----------------------|-------------|
| REDIS_ADDR | Redis server |
| SPANNER_PROJECT | Cloud Spanner project |
| SPANNER_CONNECTION_STRING | Spanner connection string |
| ALLOYDB_PRIMARY_IP | AlloyDB instance |

---

# Dependencies

| Package | Purpose |
|----------|----------|
| Grpc.AspNetCore | gRPC Server |
| Grpc.HealthCheck | Health endpoint |
| StackExchange.Redis | Redis client |
| Microsoft.Extensions.Caching.StackExchangeRedis | Redis cache |
| Google.Cloud.Spanner.Data | Google Cloud Spanner |
| Npgsql | PostgreSQL / AlloyDB |
| Google.Cloud.SecretManager | Secret management |

---

## Stateless Microservice

The application maintains no internal state.

All cart data is stored externally, allowing horizontal scaling.

---

# Summary

The Cart Microservice is a lightweight, stateless, and scalable service designed for modern cloud-native e-commerce systems. By leveraging gRPC, Protocol Buffers, and a pluggable storage abstraction, it offers high performance, flexibility, and seamless integration with the rest of the platform while remaining easy to extend and deploy.