# CNCF Webinar: Renovate Demo Repository

This repository accompanies a CNCF webinar demonstrating [Renovate](https://docs.renovatebot.com/) — an automated dependency update tool — in two deployment modes: **CLI** and **Kubernetes Operator**.

## What This Demo Shows

Renovate scans repositories for outdated dependencies and automatically creates pull requests to update them. This demo covers:

- **Part 1 — CLI mode**: Run Renovate as a one-shot command against a single repository
- **Part 2 — Operator mode**: Run Renovate as a Kubernetes operator for scheduled, cluster-native multi-repo scanning

Both parts use the same `renovate.json` configuration, illustrating how Renovate scales from a single repo to an entire organization.

## Repository Structure

```
cncf-renovate/
├── app/                      # Sample Node.js app with intentionally outdated dependencies
│   ├── Dockerfile            # node:18.12.0-alpine base image
│   ├── Chart.yaml            # Helm chart with postgresql & redis subcharts
│   └── package.json          # npm dependencies (express, axios, lodash, etc.)
│
├── operator/                 # Kubernetes operator manifests
│   ├── renovatejob.yaml      # On-demand scan (RenovateJob CRD)
│   ├── renovateschedule.yaml # Scheduled scan every Sunday at 02:00 UTC
│   └── renovate-secrets.yaml # GitHub token / App credentials
│
├── scripts/
│   ├── demo-cli.sh           # Interactive Part 1 demo script
│   ├── demo-operator.sh      # Interactive Part 2 demo script
│   └── DEMO-RUNBOOK.md       # Pre-flight checklist and talking points
│
└── renovate.json             # Shared Renovate configuration
```

## The Sample App

The `app/` directory contains a Node.js application with dependencies pinned to older versions across three ecosystems — intentionally, so Renovate has something to update:

| Ecosystem | File | Example |
|-----------|------|---------|
| npm | `package.json` | express 4.18.1, axios 1.3.0 |
| Docker | `Dockerfile` | node:18.12.0-alpine |
| Helm | `Chart.yaml` | postgresql 12.1.2, redis 17.3.7 |

## Renovate Configuration Highlights

[renovate.json](renovate.json) demonstrates several common configuration patterns:

- **Schedule**: Runs every weekend, Europe/Berlin timezone
- **PR limits**: Max 5 concurrent open PRs
- **Auto-merge**: Patch/minor devDependency updates merge automatically
- **Grouping**: All Helm chart updates bundled into a single PR
- **Docker digest pinning**: Base images pinned to `sha256` digests
- **Major version review**: Major bumps get a `needs-review` label
- **Vulnerability alerts**: Security PRs automatically labeled

## Running the Demo

### Prerequisites

**Part 1 (CLI)**
- Docker
- A `GITHUB_TOKEN` with repo read access

**Part 2 (Operator)**
- A Kubernetes cluster with the [Renovate Operator](https://github.com/renovatebot/renovate-operator) installed
- `kubectl` configured against the cluster

### Part 1 — CLI

```bash
export GITHUB_TOKEN=ghp_your_token_here
bash scripts/demo-cli.sh
```

The script walks through the app structure and then runs Renovate with `--dry-run=full`, showing exactly which PRs would be created without making any changes.

### Part 2 — Operator

```bash
bash scripts/demo-operator.sh
```

The script inspects the running operator, shows the weekly `RenovateSchedule`, applies a `RenovateJob` for an on-demand scan, and streams live logs from the resulting pod.

See [scripts/DEMO-RUNBOOK.md](scripts/DEMO-RUNBOOK.md) for the full pre-flight checklist and per-step talking points.

## Key Takeaway

The same `renovate.json` drives both the CLI invocation and the Kubernetes operator — configuration is portable across deployment models, making it straightforward to start local and graduate to a cluster-native, scheduled setup as your organization grows.
