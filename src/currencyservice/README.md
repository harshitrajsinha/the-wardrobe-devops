## Running project via Docker

1. Change directory
```bash
cd microservices-demo/src/currencyservice
```

2. Build currencyservice docker image
```bash
docker build -t test/currencyservice:test .
```

4. Build currencyservice docker image
```bash
docker run --name currencyservice -p 7000:7000 --env-file ./src/.env --network boutique-shop test/currencyservice:test
```


#####################################################################################
#####################################################################################
#####################################################################################


# Currency Service

The **Currency Service** is a gRPC-based microservice responsible for providing currency conversion functionality within the e-commerce platform. It enables other services to convert monetary values between supported currencies using predefined exchange rates.

Unlike services that manage persistent business data, the Currency Service is a **stateless computation service**. It loads exchange rates during startup and performs fast in-memory currency conversions on request.

---

# Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Technology Stack](#technology-stack)
- [Features](#features)
- [Project Structure](#project-structure)
- [Application Startup](#application-startup)
- [Currency Data](#currency-data)
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

The Currency Service provides exchange rate conversion between supported currencies.

Its primary responsibilities include:

- Converting one currency into another
- Providing exchange rates to other microservices
- Loading conversion rates from a configuration file
- Serving currency conversion requests over gRPC

The service maintains all exchange rates in memory, making conversions extremely fast.

---

# Architecture

```text
               Client / Other Services
                        │
                     gRPC Request
                        │
                        ▼
                Currency Service
                        │
                        ▼
        currency_conversion.json
```

Within the e-commerce platform, the Currency Service is typically consumed by:

```text
Frontend
     │
Checkout Service
     │
Payment Service
     │
Currency Service
```

---

# Technology Stack

| Component | Technology |
|-----------|------------|
| Language | Node.js (JavaScript) |
| Runtime | Node.js |
| Communication | gRPC |
| Serialization | Protocol Buffers |
| Data Source | JSON |
| Environment Configuration | dotenv |

---

# Project Structure

```text
currencyservice/

├── src/
│   ├── server.js
│   ├── client.js
│   ├── package.json
│   ├── package-lock.json
│   ├── .env
│   ├── .env.local
│   ├── genproto.sh
│   └── data/
│       ├── currency_conversion.json
│       └── proto/
│           ├── demo.proto
│           └── grpc/
│               └── health/
│
├── Dockerfile
├── README.md
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
Load Exchange Rates
        │
Initialize gRPC Server
        │
Register Currency Service
        │
Register Health Service
        │
Start Listening
```

Exchange rates are loaded from:

```
data/currency_conversion.json
```

---

# Currency Data

The service stores exchange rates in a JSON file.

Example structure:

```json
{
    "USD": {
        "EUR": 0.92,
        "JPY": 157.4
    }
}
```

At startup:

```
Read JSON

↓

Parse

↓

Store in Memory

↓

Serve Requests
```

Since the data resides entirely in memory after startup, conversions are very fast.

---

# gRPC API

The Currency Service exposes a single primary RPC.

## Convert

Converts an amount from one currency to another.

### Request

```protobuf
CurrencyConversionRequest
```

Fields:

- from_currency
- to_currency
- units
- nanos

### Response

```protobuf
Money
```

Returns:

- Converted currency code
- Converted units
- Converted nanos

The service preserves monetary precision by representing values using the `Money` protobuf type instead of floating-point numbers.

---

# Business Logic

The conversion workflow is straightforward.

```text
Receive Request
        │
Validate Currency Codes
        │
Lookup Exchange Rate
        │
Perform Conversion
        │
Normalize Units/Nanos
        │
Return Converted Money
```

### Conversion Steps

1. Read the source currency.
2. Read the destination currency.
3. Find the corresponding exchange rate.
4. Multiply the amount by the exchange rate.
5. Convert the result into `units` and `nanos`.
6. Return the converted value.

---

# Error Handling

The service validates:

- Source currency exists
- Destination currency exists
- Exchange rate is available

If validation fails, an appropriate gRPC error is returned rather than performing an invalid conversion.

---

# Configuration

The service uses environment variables for runtime configuration.

Typical variables include:

| Variable | Purpose |
|----------|---------|
| PORT | gRPC server port |
| NODE_ENV | Runtime environment |

Configuration is loaded using:

```
dotenv
```

Environment values are stored in:

```
.env
```

or

```
.env.local
```

---

# Health Checks

The service implements the standard gRPC Health Checking API.

This allows:

- Kubernetes readiness probes
- Kubernetes liveness probes
- Service monitoring

Typical response:

```
SERVING
```

---

# Dependencies

Major packages include:

| Package | Purpose |
|----------|----------|
| @grpc/grpc-js | gRPC server |
| @grpc/proto-loader | Protocol Buffer loading |
| protobufjs | Protocol Buffer support |
| dotenv | Environment configuration |

---

## In-Memory Cache

Exchange rates are loaded once during startup and reused for every request.

```
Startup

↓

Load JSON

↓

Memory Cache

↓

Fast Conversion
```

---

# Summary

The Currency Service is a lightweight, stateless microservice responsible for currency conversion within the e-commerce platform. Built with **Node.js**, **gRPC**, and **Protocol Buffers**, it provides fast in-memory exchange rate calculations using data loaded from a JSON configuration file. Its simple architecture, high performance, and ease of deployment make it an ideal supporting service for checkout, payment, and price localization workflows.