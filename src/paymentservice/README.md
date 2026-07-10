## Running project via Docker

1. Change directory
```bash
cd microservices-demo/src/paymentservice
```
2. Build paymentservice docker image
```bash
docker build -t test/paymentservice:test .
```

4. Build paymentservice docker image
```bash
docker run --name paymentservice -p 50052:50052 --env-file ./src/.env --network boutique-shop test/paymentservice:test
```

#################################################################################################
#################################################################################################
#################################################################################################

# Payment Service

The **Payment Service** is a gRPC-based microservice responsible for simulating payment processing within the e-commerce platform. It receives payment requests from the Checkout Service, validates the supplied payment information, generates a transaction identifier, and returns the payment result.

Unlike a real-world payment gateway, this service **does not communicate with banks or external payment providers**. Instead, it provides a lightweight payment simulation that demonstrates how a payment microservice integrates into a distributed e-commerce system.

---

# Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Technology Stack](#technology-stack)
- [Features](#features)
- [Project Structure](#project-structure)
- [Application Startup](#application-startup)
- [Payment Workflow](#payment-workflow)
- [gRPC API](#grpc-api)
- [Business Logic](#business-logic)
- [Configuration](#configuration)
- [Dependencies](#dependencies)
- [Integration with Other Services](#integration-with-other-services)
- [Health Checks](#health-checks)
- [Observability](#observability)
- [Design Patterns](#design-patterns)
- [Strengths](#strengths)
- [Limitations](#limitations)

---

# Overview

The Payment Service is responsible for processing customer payment requests during checkout.

Its primary responsibilities include:

- Receiving payment requests
- Validating payment information
- Simulating payment authorization
- Generating transaction identifiers
- Returning payment confirmation
- Exposing a gRPC API for payment processing

The service is completely **stateless**, meaning no payment information or transaction history is permanently stored.

---

# Architecture

```text
                   Checkout Service
                          │
                     gRPC Request
                          │
                          ▼
                  Payment Service
                          │
          Validate Payment Request
                          │
                          ▼
             Generate Transaction ID
                          │
                          ▼
                Return Payment Result
```

Within the overall microservices architecture:

```text
Frontend
     │
Checkout Service
     │
Payment Service
```

The Payment Service is typically called only by the Checkout Service.

---

# Technology Stack

| Component | Technology |
|-----------|------------|
| Language | Node.js (JavaScript) |
| Runtime | Node.js |
| Communication | gRPC |
| Serialization | Protocol Buffers |
| Environment Configuration | dotenv |
| Logging | Custom Logger / Console Logging |

---

# Project Structure

```text
paymentservice/

├── src/
│   ├── server.js
│   ├── index.js
│   ├── charge.js
│   ├── logger.js
│   ├── package.json
│   ├── package-lock.json
│   ├── .env
│   ├── .env.local
│   ├── genproto.sh
│   └── proto/
│       ├── demo.proto
│       └── grpc/
│           └── health/
│
├── Dockerfile
├── Dockerfile.compose
└── .dockerignore
```

---

# Application Startup

Entry point:

```
server.js
```

Startup sequence:

```text
Application Starts
        │
Load Environment Variables
        │
Initialize Logger
        │
Register Payment Service
        │
Register Health Service
        │
Start gRPC Server
```

The service listens on the configured port (typically **50051** unless overridden).

---

# Payment Workflow

A payment request follows this sequence:

```text
Checkout Service
        │
Charge()
        │
Payment Service
        │
Validate Request
        │
Generate Transaction ID
        │
Return Payment Result
```

Unlike production payment gateways, the request is processed entirely within the service.

---

# gRPC API

The service exposes a single primary RPC.

## Charge

Processes a payment request.

### Request

```protobuf
ChargeRequest
```

Typical fields include:

- Credit card number
- CVV
- Expiration month
- Expiration year
- Cardholder name
- Amount

### Response

```protobuf
ChargeResponse
```

Returns:

- Transaction ID

If the request is invalid, the service returns a gRPC error.

---

# Business Logic

The payment processing workflow consists of several steps.

## 1. Receive Payment Request

```text
ChargeRequest
```

contains payment information and the amount to charge.

---

## 2. Validate Input

The service verifies:

- Card number exists
- Expiration date is present
- Amount is valid
- Required fields are supplied

---

## 3. Simulate Payment

Instead of contacting an external payment processor:

```
Validate

↓

Generate Transaction ID

↓

Return Success
```

No real financial transaction occurs.

---

## 4. Return Response

A successful response contains:

```
Transaction ID
```

This identifier is later included in the completed order.

---

# Error Handling

The service returns gRPC errors when:

- Payment information is incomplete
- Invalid request data is supplied
- Required fields are missing

The Checkout Service can then terminate the checkout process without creating an order.

---

# Configuration

Configuration is provided using environment variables.

Typical variables include:

| Variable | Purpose |
|----------|---------|
| PORT | gRPC server port |
| NODE_ENV | Runtime environment |

Environment values are loaded from:

```
.env
```

or

```
.env.local
```

---

# Health Checks

The Payment Service implements the standard gRPC Health Checking API.

Supported operations include:

- Readiness checks
- Liveness checks

Typical status:

```
SERVING
```

This allows Kubernetes and monitoring systems to verify service availability.

---

# Dependencies

Major packages include:

| Package | Purpose |
|----------|----------|
| @grpc/grpc-js | gRPC server |
| @grpc/proto-loader | Protocol Buffer loading |
| uuid (or equivalent) | Transaction ID generation |
| dotenv | Environment configuration |

---

# Summary

The Payment Service is a lightweight, stateless microservice responsible for simulating payment authorization within the e-commerce platform. Built with **Node.js**, **gRPC**, and **Protocol Buffers**, it validates payment requests, generates transaction identifiers, and returns payment confirmations to the Checkout Service. Its simple design makes it ideal for development, demonstrations, and learning about microservice interactions while providing a clear extension point for integration with real payment gateways in production.