---
name: pinot-perf-cluster
description: "Explore and manage Pinot perf clusters — topology, tenants, tables, and workflows for creating or modifying perf tables. Use when working with perf/test environments on the perf controller."
---

# Skill: Pinot Perf Cluster

## Purpose

Provides perf-specific knowledge for working with Pinot performance testing clusters. Covers perf controller access, known perf topology, and workflows for creating perf tables from prod templates.

## When to Use

- Investigating perf cluster topology (tenants, tables, hosts)
- Creating or modifying a perf table
- Finding which perf tenant to use for testing
- Understanding how perf tables relate to prod tables

## When NOT to Use

- General `pinot-tool` usage — use **pinot-tool-reference** instead
- Checking production deployment status — use `pinot-deployment-status`
- Investigating stuck hosts — use `pinot-stuck-host`

## Prerequisites

1. Load **pinot-tool-reference** — for `pinot-tool` command syntax, SSH access, and error handling
2. Know which fabric to query (e.g., `prod-lor1`)

## Perf Controller Access

Perf tables and tenants live on a **separate controller** (`pinot-controller.perf`) that is invisible from the main prod controller. Use the `:<cluster>` suffix:

| Controller | `pinot-tool` flag | What it manages |
|---|---|---|
| Prod | `-f prod-lor1` | Production tables and tenants |
| **Perf** | **`-f prod-lor1:perf`** | Perf/test tables and tenants |

**Critical**: Always use `-f <fabric>:perf` when working with perf resources. Using `-f <fabric>` alone targets the prod controller and will return "table not found" for perf tables.

## Perf Cluster Topology (prod-lor1, as of 2026-03)

### Perf Controller

`pinot-controller.perf` — 3 hosts in prod-lor1 (shared across all perf tenants)

### Tenants

| Tenant | Server Hosts | Broker Hosts | Known Tables |
|---|---|---|---|
| **QRIControllerPerfTest** | 3 (OFFLINE) | 1 | fakeCompanyPageView_OFFLINE, fakeCompanyPageViewHourly_OFFLINE |
| **CGATest** | 4 (REALTIME) | 1 | mirrorInfiniteTest_REALTIME |
| StackingPerfTest | ? | 1 | — |
| KePerfE2EQuery2Test | ? | 1 | — |
| ShuaiPerfSdsTest | — | 2 | — |
| perfStorageTenant | — | 4 | — |
| TriggerWorkload | ? | — | — |

### Tables on Perf Controller

ContentGestureAnalyticsTest, DecisionActionStoreV2Test, RecommendationEngineTestTest, fakeCompanyPageView, fakeCompanyPageViewHourly, memberProfileTest, mirrorInfiniteTest

**All existing tables have replication=1.**

### Perf Tags in go-status

Perf tags are visible in regular `go-status` (no `:perf` suffix needed):

```bash
go-status --index v:pt -f prod-lor1 pinot-server | grep -iE "test|perf"
go-status --index v:pt -f prod-lor1 pinot-broker | grep -iE "test|perf"
go-status --index v:pt -f prod-lor1 pinot-controller | grep -i "perf"
```

Tags containing **"Test"**, **"Perf"**, or **"DarkCluster"** (case-insensitive) are perf/non-pipeline tags.

## Steps

### Step 1: Explore Perf Topology

```bash
# List all perf tables
pinot-tool table list -f prod-lor1:perf

# List all perf tenants
pinot-tool tenant list -f prod-lor1:perf

# Inspect a specific tenant (hosts + assigned tables)
pinot-tool tenant info -t <TenantName> -f prod-lor1:perf
```

### Step 2: Check a Perf Table Config

```bash
pinot-tool table config -t <TableName> -f prod-lor1:perf
```

Key fields for perf tables:
- `tenants.server` / `tenants.broker` — which perf tenant it's on
- `segmentsConfig.replication` — typically 1 for perf
- `segmentsConfig.replicasPerPartition` — typically 1 for perf (REALTIME)

### Step 3: Create a Perf Table from Prod Template

When you need a perf version of a production table:

**3a. Pull the prod config and schema:**
```bash
pinot-tool table config -t <ProdTableName>_OFFLINE -f prod-lor1
pinot-tool table schema -t <ProdTableName> -f prod-lor1
```

**3b. Modify the config for perf:**
- `tenants.server` → perf tenant name (e.g., `QRIControllerPerfTest` or `CGATest`)
- `tenants.broker` → same perf tenant name
- `segmentsConfig.replication` → match your desired replica count (e.g., 3)
- `instanceAssignmentConfigMap` → adjust or remove:
  - `numReplicaGroups` → match replication (e.g., 3)
  - `numInstancesPerReplicaGroup` → typically 1 for perf
- `quota.maxQueriesPerSecond` → can lower for perf
- `segmentsConfig.retentionTimeValue` → can shorten for perf
- Remove production-specific settings not needed for testing

**3c. Verify host capacity:**

Ensure the target tenant has enough hosts. Total hosts needed = `numReplicaGroups` × `numInstancesPerReplicaGroup`.

```bash
pinot-tool tenant info -t <TenantName> -f prod-lor1:perf
```

Check that the `servers` count >= your total hosts needed.

**3d. Apply the config** (generate command for user):

The exact method depends on team workflow — typically via controller API POST or `pinot-tool`. Confirm the creation process with your team before applying.

### Step 4: Reuse an Existing Perf Table

If you just need to deploy code and test segment uploads, check if an existing perf table already meets your needs:

```bash
# List what's available
pinot-tool table list -f prod-lor1:perf

# Check a table's config
pinot-tool table config -t <TableName> -f prod-lor1:perf
```

All existing perf tables have replication=1. If you need higher replication, you'll need to modify an existing table or create a new one.

## Composition

This skill depends on:
- **pinot-tool-reference** — for `pinot-tool` command syntax, SSH access patterns, multi-cluster targeting, and error handling

This skill composes well with:
- **pinot-deployment-config** — for prod reference data (tag patterns, fabric ordering)
- **listing-deployment-versions-by-tags** — for checking perf tag deployment versions via go-status
