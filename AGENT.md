---
id: repo:razor-sdk/agent
scope: razor-sdk
level: repo
kind: agent
requires_org_docs: true
org_docs_fallback: notify
skill: docs
excluded_paths: [.git/, node_modules/, dist/, bin/, obj/, TestResults/]
included_paths: []
---

# Razor SDK — Repository Agent Manifest

This repository contains the official developer SDK for building plugins, broker adapters, execution hooks, slots, and strategies for the **Razor** algorithmic trading platform.

---

## 1. Architectural Profiles
- **`src/Sdk`**: Profile D (Shared Contracts & Core Libraries)

---

## 2. Local Execution Commands
- Build SDK: `bash scripts/build.sh` or `dotnet build Sdk.slnx`
- Test SDK: `bash scripts/test.sh` or `dotnet test Sdk.slnx`
- Pack NuGet: `dotnet pack src/Sdk/Sdk.csproj -c Release`

---

## 3. Tier 1 Governance Invariants
- Strict SemVer backward compatibility on all public contracts (`IHook`, `ISlot`, `IStrategy`, `IBrokerAdapter`).
- Immutable value objects (`Tick`, `OrderRequest`, `Position`).
- Zero unmanaged I/O inside hot-path trading calculations.
- Multi-tier branch promotion (`main`, `test`, `stage`, `prod`). Human-only production merge.
