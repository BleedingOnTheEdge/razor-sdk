# Razor SDK (`BleedingOnTheEdge.Sdk`)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![.NET](https://img.shields.io/badge/.NET-10.0-purple.svg)](https://dotnet.microsoft.com/)

The official developer SDK for building plugins, adapters, strategies, and hooks for the **Razor** algorithmic trading platform.

---

## Overview

The **Razor SDK** provides pure public contracts, domain types, hook interfaces (`IHook`, `ISlot`), and decorator attributes. It is intentionally decoupled from engine execution internals, providing a stable public API surface for extension developers.

### Key Capabilities

- **Contracts & Interfaces**: Build custom broker adapters, execution hooks, strategy models, and indicators.
- **Hook Framework**: Intercept orders, ticks, bar closes, and lifecycle events.
- **Zero Runtime Overhead**: Designed for ultra-low latency memory structures, cache-line friendly layouts, and zero GC pressure in trading loops.

---

## Installation

Add the package via the .NET CLI:

```bash
dotnet add package BleedingOnTheEdge.Sdk
```

Or add the dependency directly in your `.csproj`:

```xml
<PackageReference Include="BleedingOnTheEdge.Sdk" Version="1.0.0" />
```

---

## Quick Start: Developing an Adapter or Strategy

### Creating a Custom Strategy
```csharp
using Sdk;

public class MyCustomStrategy : StrategyBase
{
    public override void OnTick(in Tick tick)
    {
        // Process market tick
    }
}
```

### Implementing an Execution Hook
```csharp
using Sdk;
using Sdk.Hooks;

[SdkVersion("1.0.0")]
public class RiskAuditHook : IOrderValidationHook
{
    public FilterResult ValidateOrder(in OrderRequest order, in HookContext context)
    {
        if (order.Quantity <= 0)
        {
            return FilterResult.Reject("Quantity must be positive");
        }
        return FilterResult.Accept();
    }
}
```

---

## Building and Testing Locally

Requirements:
- [.NET 10.0 SDK](https://dotnet.microsoft.com/download/dotnet/10.0)

```bash
# Build SDK and tests
dotnet build Sdk.sln

# Run all unit and integration tests
dotnet test Sdk.sln
```

---

## Contributing & License

Contributions, issues, and feature requests are welcome!
Distributed under the **MIT License**. See `LICENSE` for details.
