# Razor SDK (`BleedingOnTheEdge.Razor.Sdk`)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![.NET](https://img.shields.io/badge/.NET-10.0-purple.svg)](https://dotnet.microsoft.com/)
[![GitHub Org](https://img.shields.io/badge/Org-BleedingOnTheEdge-blue)](https://github.com/BleedingOnTheEdge)

The official developer SDK for building plugins, adapters, execution hooks, slots, and strategies for the **Razor** algorithmic trading platform.

---

## 🏛 Organization Context & Cross-Repo Topology

This repository is part of the **BleedingOnTheEdge** open and proprietary trading infrastructure:

- **Orchestrator**: [`BleedingOnTheEdge/razor`](https://github.com/BleedingOnTheEdge/razor) (Central scripts, organization bootstrap, and cross-repo coordination)
- **Engine Runtime**: [`BleedingOnTheEdge/razor-engine`](https://github.com/BleedingOnTheEdge/razor-engine) (Headless execution engine running SDK-compliant strategies and adapters)
- **Control Panel**: [`BleedingOnTheEdge/razor-panel`](https://github.com/BleedingOnTheEdge/razor-panel) (SaaS control plane & marketplace where SDK extensions are distributed)
- **Reference Samples**: [`BleedingOnTheEdge/razor-samples`](https://github.com/BleedingOnTheEdge/razor-samples) (Working broker adapters, multi-asset strategies, and polyglot bridge templates)
- **Documentation**: [`BleedingOnTheEdge/razor-docs`](https://github.com/BleedingOnTheEdge/razor-docs) (Technical architecture documents, contract specs, and developer guides)

---

## 📦 Overview & Architectural Role

The **Razor SDK** provides pure public contracts, domain types, hook interfaces (`IHook`, `ISlot`), and decorator attributes. It is completely decoupled from engine execution internals, providing a stable public API surface for extension developers and broker integrations.

### Key Capabilities

- **Extension Interfaces**: Build custom broker adapters (`IBrokerAdapter`), strategy models (`StrategyBase`), indicators (`IIndicator`), and neural network signal filters (`INeuralNetworkModel`).
- **Hook Framework**: Intercept orders, ticks, bar closes, and lifecycle events (`IOrderValidationHook`, `IOrderExecutionHook`, `ITickFilterHook`).
- **Slot System**: Inject custom behavior dynamically into predefined execution slots.
- **Zero Overhead**: Engineered for ultra-low latency, cache-friendly memory layouts, and zero GC allocation in hot trading loops.

---

## 🚀 Installation

Add the package via the .NET CLI:

```bash
dotnet add package BleedingOnTheEdge.Razor.Sdk
```

Or reference it in your `.csproj`:

```xml
<PackageReference Include="BleedingOnTheEdge.Razor.Sdk" Version="1.0.0" />
```

---

## 💡 Quick Start: Developing an Adapter or Strategy

### Creating a Custom Strategy
```csharp
using Sdk;

public class MyCustomStrategy : StrategyBase
{
    public override void OnTick(in Tick tick)
    {
        // High-frequency market tick processing
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

For full reference implementations including MetaTrader 5 and Nobitex adapters, see [BleedingOnTheEdge/razor-samples](https://github.com/BleedingOnTheEdge/razor-samples).

---

## 💻 Building and Testing Locally

### Prerequisites
- [.NET 10.0 SDK](https://dotnet.microsoft.com/download/dotnet/10.0)

```bash
# Build SDK solution and test projects
dotnet build Sdk.slnx

# Run all 583 unit and integration tests
dotnet test Sdk.slnx
```

---

## 🤝 Contributing & License

Contributions, issues, and feature requests are welcome!
Distributed under the **MIT License**. See `LICENSE` for details.
