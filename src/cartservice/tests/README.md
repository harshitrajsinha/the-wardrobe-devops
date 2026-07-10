# Cart Service Tests

This document explains how to build and execute the automated tests for the Cart Service.

---

# Overview

The Cart Service includes a dedicated test project that validates the core business logic of the shopping cart microservice.

The tests are intended to verify that the service behaves correctly for common cart operations such as:

- Adding items to a cart
- Retrieving cart contents
- Emptying a cart
- Updating quantities for existing products
- Handling invalid operations and exceptions

---

# Prerequisites

Before running the tests, ensure you have:

- .NET SDK installed (compatible with the project's target framework)
- NuGet packages restored

Verify your installation:

```bash
dotnet --version
```

---

# Restore Dependencies

From the project root, restore all required packages:

```bash
dotnet restore
```

Alternatively, restore only the test project:

```bash
dotnet restore tests/cartservice.tests.csproj
```

---

# Running All Tests

From the root directory of the project:

```bash
dotnet test
```

This command will:

1. Restore dependencies (if needed)
2. Build the Cart Service
3. Build the test project
4. Execute all discovered tests
5. Display a test summary

Example output:

```text
Passed!  - Failed: 0
           Passed: 12
           Skipped: 0
           Total: 12
```

---

# Running Only the Test Project

To execute only the Cart Service tests:

```bash
dotnet test tests/cartservice.tests.csproj
```

---

# Listing Available Tests

To view all discovered tests without executing them:

```bash
dotnet test --list-tests
```

---

# Running a Specific Test

Run tests by class name:

```bash
dotnet test --filter "FullyQualifiedName~CartServiceTests"
```

Run tests by method name:

```bash
dotnet test --filter "Name~AddItem"
```

Examples:

```bash
dotnet test --filter "Name~GetCart"
```

```bash
dotnet test --filter "Name~EmptyCart"
```

---

# Running Tests with Detailed Output

To obtain more verbose logs during execution:

```bash
dotnet test --logger "console;verbosity=detailed"
```

or

```bash
dotnet test -v normal
```

---

# Code Coverage

To collect code coverage (if the coverage collector is installed):

```bash
dotnet test --collect:"XPlat Code Coverage"
```

Coverage reports will be generated under:

```text
tests/TestResults/
```

These reports can be imported into tools such as Visual Studio, ReportGenerator, or Azure DevOps.

---

# Expected Test Workflow

```text
dotnet test
      │
      ▼
Restore Packages
      │
      ▼
Build Cart Service
      │
      ▼
Build Test Project
      │
      ▼
Execute Tests
      │
      ▼
Display Results
```

---

# Troubleshooting

## Tests Are Not Discovered

Ensure the test project builds successfully:

```bash
dotnet build tests/cartservice.tests.csproj
```

---

## Missing Dependencies

Restore NuGet packages:

```bash
dotnet restore
```

---

## SDK Version Mismatch

Verify the installed SDK:

```bash
dotnet --version
```

Ensure it supports the project's target framework.

---

## External Services

If any integration tests rely on Redis, Spanner, or AlloyDB, ensure those services are available before running the tests.

If the tests use mocked or in-memory implementations, no external services are required.
