## Running project via Docker

1. Change directory
```bash
cd microservices-demo/src/checkoutservice
```
2. Build checkoutservice docker image
```bash
docker build -t test/checkoutservice:test .
```

4. Build checkoutservice docker image
```bash
docker run --name checkoutservice -p 5050:5050 --env-file ./src/.env --network boutique-shop test/checkoutservice:test
```

#################################################################################################
#################################################################################################
#################################################################################################

# Checkout Service

The **Checkout Service** is the orchestration layer of the e-commerce platform. It coordinates the checkout workflow by communicating with multiple microservices to transform a customer's shopping cart into a completed order.

Rather than storing business data itself, the Checkout Service acts as a **workflow coordinator**, retrieving information from downstream services, validating the checkout request, calculating totals, processing payments, arranging shipping, and sending order confirmations.

---

# Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Technology Stack](#technology-stack)
- [Features](#features)
- [Project Structure](#project-structure)
- [Application Startup](#application-startup)
- [Checkout Workflow](#checkout-workflow)
- [gRPC API](#grpc-api)
- [Business Logic](#business-logic)
- [Service Integrations](#service-integrations)
- [Configuration](#configuration)
- [Observability](#observability)
- [Health Checks](#health-checks)
- [Dependencies](#dependencies)
- [Design Patterns](#design-patterns)
- [Strengths](#strengths)
- [Limitations](#limitations)

---

# Overview

The Checkout Service is responsible for executing the end-to-end checkout process for an online purchase.

Its responsibilities include:

- Retrieving the customer's shopping cart
- Looking up product details
- Calculating order totals
- Processing payment
- Creating shipment information
- Sending order confirmation emails
- Clearing the shopping cart after a successful checkout
- Returning the completed order information

Unlike the Cart or Product Catalog services, the Checkout Service contains very little persistent business data. Instead, it orchestrates calls to other services.

---

# Architecture

```text
                     Client / Frontend
                            │
                            ▼
                    Checkout Service
                            │
      ┌─────────────────────┼─────────────────────┐
      │                     │                     │
      ▼                     ▼                     ▼
 Cart Service       Product Catalog        Payment Service
      │
      ▼
 Shipping Service
      │
      ▼
 Email Service
```

The Checkout Service acts as the central coordinator for the checkout workflow.

---

# Technology Stack

| Component | Technology |
|-----------|------------|
| Language | Go |
| Runtime | Go 1.25+ |
| Communication | gRPC |
| Serialization | Protocol Buffers |
| Logging | Logrus |
| Tracing | OpenTelemetry |
| Profiling | Google Cloud Profiler |
| Health Checks | gRPC Health API |

---

# Project Structure

```text
checkoutservice/

├── main.go
├── money/
│   ├── money.go
│   └── money_test.go
├── genproto/
├── go.mod
├── Dockerfile
├── Dockerfile.local
└── README.md
```

---

# Application Startup

The application starts in:

```
main.go
```

Startup sequence:

```text
Application Starts
        │
Read Environment Variables
        │
Initialize Logger
        │
Initialize Tracing (Optional)
        │
Initialize Cloud Profiler (Optional)
        │
Connect to Downstream Services
        │
Register gRPC Server
        │
Register Health Service
        │
Start Listening
```

Default listening port:

```
5050
```

---

# Checkout Workflow

A typical checkout request follows this sequence:

```text
Client
   │
PlaceOrder
   │
Checkout Service
   │
Retrieve Shopping Cart
   │
Retrieve Product Details
   │
Calculate Total
   │
Charge Payment
   │
Create Shipment
   │
Send Confirmation Email
   │
Clear Shopping Cart
   │
Return Order Confirmation
```

The Checkout Service is responsible for coordinating these operations while ensuring that each downstream service is called in the correct order.

---

# gRPC API

The service exposes the Checkout gRPC API.

## PlaceOrder

Processes an entire customer order.

Typical request includes:

- User information
- Shipping address
- Billing address
- Credit card information
- User ID

Typical response includes:

- Order ID
- Shipping tracking ID
- Total cost
- Shipping cost

If any downstream service fails, the checkout process returns an appropriate gRPC error.

---

# Business Logic

The checkout process consists of several stages.

## 1. Retrieve Cart

```text
Cart Service

↓

GetCart(user_id)
```

The user's shopping cart is retrieved.

---

## 2. Retrieve Products

For each product in the cart:

```text
Product Catalog Service

↓

GetProduct(product_id)
```

Product information is used to calculate pricing.

---

## 3. Calculate Totals

The service computes:

- Item subtotal
- Shipping cost
- Total order value

The included `money` package provides helpers for monetary calculations to avoid floating-point precision issues.

---

## 4. Process Payment

The calculated total is submitted to the Payment Service.

If payment fails:

- Checkout stops
- Cart remains unchanged

---

## 5. Create Shipment

Shipping details are sent to the Shipping Service.

A shipment or tracking identifier is returned.

---

## 6. Send Confirmation

The Email Service sends an order confirmation to the customer.

---

## 7. Empty Cart

After successful completion:

```text
Cart Service

↓

EmptyCart(user_id)
```

The customer's cart is cleared.

---

# Configuration

The service uses environment variables for configuration.

## Server

| Variable | Purpose |
|----------|---------|
| PORT | Server port |

---

## Service Endpoints

| Variable | Purpose |
|----------|---------|
| PRODUCT_CATALOG_SERVICE_ADDR | Product Catalog Service |
| CART_SERVICE_ADDR | Cart Service |
| PAYMENT_SERVICE_ADDR | Payment Service |
| SHIPPING_SERVICE_ADDR | Shipping Service |
| EMAIL_SERVICE_ADDR | Email Service |
| CURRENCY_SERVICE_ADDR | Currency Service |

---

## Tracing

| Variable | Purpose |
|----------|---------|
| ENABLE_TRACING | Enable OpenTelemetry |

---

## Profiling

| Variable | Purpose |
|----------|---------|
| ENABLE_PROFILER | Enable Google Cloud Profiler |

---

# Observability

## Logging

The service uses **Logrus** with structured JSON logging.

Each log entry contains:

- Timestamp
- Severity
- Message

---

## Distributed Tracing

Supports OpenTelemetry instrumentation for both gRPC server and client calls.

When enabled, traces propagate across downstream service calls, allowing complete visibility into the checkout workflow.

---

## Profiling

Google Cloud Profiler can be enabled for production performance analysis.

---

# Health Checks

The Checkout Service registers the standard gRPC Health Service.

This allows:

- Kubernetes liveness probes
- Kubernetes readiness probes
- Service monitoring

---

# Dependencies

Major libraries include:

| Package | Purpose |
|----------|----------|
| google.golang.org/grpc | gRPC server/client |
| protobuf | Protocol Buffers |
| Logrus | Structured logging |
| OpenTelemetry | Distributed tracing |
| Google Cloud Profiler | Performance profiling |
| google/uuid | Order identifier generation |
| pkg/errors | Error wrapping |

---

# Summary

The Checkout Service serves as the central workflow coordinator within the e-commerce platform. It orchestrates interactions between the Cart, Product Catalog, Payment, Shipping, Email, and Currency services to complete a customer's purchase. Built with Go, gRPC, OpenTelemetry, and Logrus, it is designed to be lightweight, stateless, cloud-native, and highly scalable, making it well suited for deployment in a modern microservices architecture.