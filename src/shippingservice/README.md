## Running project via Docker

1. Change directory
```bash
cd microservices-demo/src/shippingservice
```

2. Build shippingservice docker image
```bash
docker build -t test/shippingservice:test .
```

4. Build shippingservice docker image
```bash
docker run --name shippingservice -p 50051:50051 --env-file ./src..env --network boutique-shop` test/shippingservice:test
```

#########################################################################################
#########################################################################################
#########################################################################################

# Shipping Service

The **Shipping Service** is a gRPC-based microservice responsible for generating shipping quotes and tracking identifiers for customer orders within the e-commerce platform. During checkout, it calculates shipping costs based on the destination address and returns shipment information that can be used by the Checkout Service.

The service is **stateless** and performs lightweight business logic without maintaining persistent shipment records or communicating with external shipping carriers.

---

# Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Technology Stack](#technology-stack)
- [Features](#features)
- [Project Structure](#project-structure)
- [Application Startup](#application-startup)
- [Shipping Workflow](#shipping-workflow)
- [gRPC API](#grpc-api)
- [Business Logic](#business-logic)
- [Configuration](#configuration)
- [Dependencies](#dependencies)
- [Integration with Other Services](#integration-with-other-services)
- [Health Checks](#health-checks)
- [Testing](#testing)
- [Design Patterns](#design-patterns)
- [Strengths](#strengths)
- [Limitations](#limitations)

---

# Overview

The Shipping Service is responsible for shipping-related operations during checkout.

Its primary responsibilities include:

- Calculating shipping costs
- Generating shipping quotes
- Creating shipment tracking identifiers
- Returning shipping information via gRPC

Unlike production shipping systems, this service **does not communicate with real shipping providers** (UPS, FedEx, DHL, etc.). Instead, it simulates shipping calculations for demonstration and development purposes.

---

# Architecture

```text
                Checkout Service
                       │
                   gRPC Request
                       │
                       ▼
                Shipping Service
                       │
        ┌──────────────┴──────────────┐
        │                             │
 Calculate Shipping Cost     Generate Tracking ID
        │                             │
        └──────────────┬──────────────┘
                       ▼
              Shipping Quote Response
```

Within the complete e-commerce platform:

```text
Frontend
     │
Checkout Service
     │
Shipping Service
```

The Shipping Service is primarily consumed by the Checkout Service during order processing.

---

# Technology Stack

| Component | Technology |
|-----------|------------|
| Language | Go |
| Runtime | Go 1.25+ |
| Communication | gRPC |
| Serialization | Protocol Buffers |
| Logging | Go Standard Library |
| Health Checks | gRPC Health API |

---

# Project Structure

```text
shippingservice/

├── src/
│   ├── main.go
│   ├── quote.go
│   ├── tracker.go
│   ├── shippingservice_test.go
│   ├── go.mod
│   ├── go.sum
│   ├── .env
│   ├── .env.local
│   ├── genproto.sh
│   └── genproto/
│       ├── demo.pb.go
│       └── demo_grpc.pb.go
│
├── Dockerfile
├── Dockerfile.local
└── README.md
```

---

# Application Startup

Application entry point:

```
main.go
```

Startup sequence:

```text
Application Starts
        │
Load Environment Variables
        │
Initialize gRPC Server
        │
Register Shipping Service
        │
Register Health Service
        │
Start Listening
```

The service starts a gRPC server and waits for shipping requests from the Checkout Service.

---

# Shipping Workflow

A shipping request follows the sequence below:

```text
Checkout Service
        │
GetQuote()
        │
Shipping Service
        │
Calculate Shipping Cost
        │
Generate Tracking Number
        │
Return Shipping Quote
```

---

# gRPC API

The Shipping Service exposes a shipping quotation API.

## GetQuote

Calculates the shipping cost for an order.

### Request

```protobuf
GetQuoteRequest
```

Typical request fields include:

- Shipping address
- Destination country
- Postal code
- State
- City
- Street address

### Response

```protobuf
GetQuoteResponse
```

Returns:

- Shipping cost
- Tracking identifier

The calculated shipping cost is later incorporated into the final order total by the Checkout Service.

---

# Business Logic

The service performs lightweight shipping calculations.

## Step 1 – Receive Shipping Address

The Checkout Service sends the customer's shipping address.

---

## Step 2 – Calculate Shipping Cost

```text
Shipping Address

↓

Determine Destination

↓

Calculate Shipping Cost
```

The implementation in `quote.go` computes the shipping cost based on predefined business rules.

---

## Step 3 – Generate Tracking Number

The service generates a unique shipment tracking identifier.

```text
Shipping Quote

↓

Generate Tracking ID

↓

Return Response
```

Tracking number generation is implemented in:

```
tracker.go
```

---

## Step 4 – Return Shipping Quote

The response contains:

- Shipping cost
- Tracking ID

This information is returned to the Checkout Service to complete the checkout workflow.

---

# Configuration

Configuration is managed using environment variables.

Typical configuration includes:

| Variable | Purpose |
|----------|---------|
| PORT | gRPC server port |
| NODE_ENV / ENV | Runtime environment (if applicable) |

Configuration files:

```
.env
```

```
.env.local
```

---

# Health Checks

The Shipping Service implements the standard gRPC Health Checking API.

Supported operations include:

- Readiness probes
- Liveness probes

Typical status:

```
SERVING
```

This allows Kubernetes and monitoring systems to verify service availability.

---

# Testing

The project includes automated tests:

```
shippingservice_test.go
```

Tests validate shipping-related functionality, including:

- Shipping quote calculation
- Tracking number generation
- Business rule correctness

Run all tests using:

```bash
go test ./...
```

Run with verbose output:

```bash
go test -v ./...
```

---

# Dependencies

Major Go modules include:

| Package | Purpose |
|----------|----------|
| google.golang.org/grpc | gRPC server |
| google.golang.org/protobuf | Protocol Buffers |
| grpc/health | Health checking |
| Go testing package | Unit testing |

---

# Summary

The Shipping Service is a lightweight, stateless Go microservice responsible for calculating shipping costs and generating shipment tracking identifiers within the e-commerce platform. It communicates via gRPC, integrates directly with the Checkout Service, and provides a simple yet extensible foundation for shipping workflows. Its modular structure, automated tests, and Docker support make it well suited for cloud-native microservice deployments while leaving room for future integration with real-world logistics providers.