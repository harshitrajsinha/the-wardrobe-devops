# frontend

Run the following command to restore dependencies to `vendor/` directory:

    dep ensure --vendor-only

<!-- #e3dcc1 #d7d7d7 -->

## Running project via Docker

1. Change directory
```bash
cd microservices-demo/src/frontend
```
2. Build frontend docker image
```bash
docker build -t test/frontend:test .
```

4. Build frontend docker image
```bash
docker run --name frontend -p 8080:8080 --env-file ./src/.env --network boutique-shop` test/frontend:test
```

##################################################################################
##################################################################################
##################################################################################

# Frontend Service

The **Frontend Service** is the web-facing component of the e-commerce platform. It provides the user interface through which customers browse products, manage shopping carts, and complete purchases. Rather than containing business logic itself, the frontend acts as a **presentation layer** that communicates with backend microservices using gRPC.

Built with **Go**, the service renders HTML templates, serves static assets, validates user input, and aggregates data from multiple backend services into a seamless shopping experience.

---

# Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Technology Stack](#technology-stack)
- [Features](#features)
- [Project Structure](#project-structure)
- [Application Startup](#application-startup)
- [Frontend Workflow](#frontend-workflow)
- [Pages and Routes](#pages-and-routes)
- [Service Integrations](#service-integrations)
- [Business Logic](#business-logic)
- [Validation](#validation)
- [Templates and Static Assets](#templates-and-static-assets)
- [Configuration](#configuration)
- [Observability](#observability)
- [Dependencies](#dependencies)
- [Testing](#testing)
- [Design Patterns](#design-patterns)
- [Strengths](#strengths)
- [Limitations](#limitations)

---

# Overview

The Frontend Service serves as the presentation layer of the application.

Its primary responsibilities include:

- Displaying the product catalog
- Displaying product details
- Managing shopping carts
- Collecting shipping and payment information
- Initiating checkout
- Rendering HTML pages
- Serving CSS, JavaScript, and images
- Communicating with backend microservices

Unlike backend services, the frontend contains very little business logic. Instead, it aggregates responses from backend services and renders them for the user.

---

# Architecture

```text
                 Web Browser
                      │
                 HTTP Requests
                      │
                      ▼
               Frontend Service
                      │
      ┌───────────────┼────────────────┐
      │               │                │
      ▼               ▼                ▼
Product Catalog   Cart Service   Checkout Service
      │
      ▼
Currency Service
```

The Frontend acts as the entry point into the microservices ecosystem.

---

# Technology Stack

| Component | Technology |
|-----------|------------|
| Language | Go |
| Runtime | Go 1.25+ |
| Web Framework | Go net/http |
| Templates | Go HTML Templates |
| Communication | gRPC |
| Serialization | Protocol Buffers |
| Static Assets | HTML, CSS, Images |
| Validation | Custom Validator Package |

---

# Features

- Server-side rendered HTML
- Product browsing
- Shopping cart management
- Checkout forms
- Currency selection
- Product search and display
- Static asset serving
- Input validation
- gRPC communication with backend services
- Docker deployment

---

# Project Structure

```text
frontend/

├── src/
│   ├── main.go
│   ├── rpc.go
│   ├── deployment_details.go
│   ├── validator/
│   │   ├── validator.go
│   │   └── validator_test.go
│   ├── money/
│   │   ├── money.go
│   │   └── money_test.go
│   ├── templates/
│   ├── static/
│   │   ├── styles/
│   │   ├── images/
│   │   ├── icons/
│   │   └── img/
│   ├── .env
│   ├── .env.local
│   └── genproto.sh
│
├── Dockerfile
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
Initialize HTTP Server
        │
Create gRPC Clients
        │
Load HTML Templates
        │
Register HTTP Routes
        │
Serve Static Assets
        │
Start Listening
```

The service listens for HTTP requests from web browsers.

---

# Frontend Workflow

A typical customer journey follows this sequence:

```text
User Opens Website
        │
Homepage
        │
Browse Products
        │
View Product
        │
Add to Cart
        │
View Cart
        │
Checkout Form
        │
Checkout Service
        │
Order Confirmation
```

The frontend coordinates communication with multiple backend services during this workflow.

---

# Pages and Routes

Typical routes include:

| Route | Purpose |
|--------|---------|
| `/` | Homepage |
| `/product/{id}` | Product details |
| `/cart` | Shopping cart |
| `/cart/add` | Add item to cart |
| `/checkout` | Checkout page |
| `/order` | Order confirmation |
| `/static/*` | CSS, images, icons |

Routes are implemented using Go's `net/http` package.

---

# Business Logic

Although most business logic resides in backend services, the frontend performs several orchestration tasks.

## Product Listing

```text
Browser

↓

Frontend

↓

Product Catalog Service

↓

Render HTML
```

---

## Shopping Cart

```text
Browser

↓

Frontend

↓

Cart Service

↓

Render Updated Cart
```

---

## Checkout

```text
Browser

↓

Frontend

↓

Validate Input

↓

Checkout Service

↓

Render Confirmation
```

---

# Validation

The project includes a dedicated validation package.

```
validator/
```

Responsibilities include:

- Form validation
- Required field validation
- Email validation
- Address validation
- Payment field validation

Automated tests verify validator behavior.

---

# Templates and Static Assets

The frontend renders pages using Go HTML templates.

Static assets include:

```
static/

├── styles/
├── images/
├── icons/
└── img/
```

Assets include:

- CSS stylesheets
- Product images
- Company branding
- Icons
- Promotional banners
- Favicons

These resources are served directly by the HTTP server.

---

# Configuration

Configuration is provided using environment variables.

Typical variables include:

| Variable | Purpose |
|----------|---------|
| PORT | HTTP server port |
| PRODUCT_CATALOG_SERVICE_ADDR | Product Catalog endpoint |
| CART_SERVICE_ADDR | Cart Service endpoint |
| CHECKOUT_SERVICE_ADDR | Checkout endpoint |
| CURRENCY_SERVICE_ADDR | Currency Service endpoint |

Configuration files:

```
.env
```

```
.env.local
```

---

# Dependencies

Major packages include:

| Package | Purpose |
|----------|----------|
| net/http | HTTP server |
| html/template | Server-side rendering |
| google.golang.org/grpc | Backend communication |
| protobuf | Protocol Buffers |
| validator | Form validation |
| Go testing | Unit testing |

---

# Testing

The project includes unit tests for reusable packages.

## Money Package

```
money/money_test.go
```

Tests monetary calculations and formatting.

---

## Validator Package

```
validator/validator_test.go
```

Tests validation rules for customer input.

Run all tests:

```bash
go test ./...
```

Run with verbose output:

```bash
go test -v ./...
```

---

# Summary

The Frontend Service is the primary user-facing component of the e-commerce platform. Built with **Go**, **net/http**, **gRPC**, and **Go HTML Templates**, it renders web pages, serves static assets, validates customer input, and coordinates communication with backend microservices. By separating presentation from business logic, it provides a lightweight, maintainable, and scalable interface that integrates seamlessly with the platform's distributed architecture.