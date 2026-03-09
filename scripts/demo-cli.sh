#!/usr/bin/env bash
# =============================================================
# CNCF Webinar Demo — Part 1: Renovate CLI
# =============================================================
# Usage: bash demo-cli.sh
# Press ENTER at each pause to advance to the next step.
# =============================================================

# ---- Helpers ------------------------------------------------
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

header() {
  echo ""
  echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo -e "${BOLD}${CYAN}  $1${RESET}"
  echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

explain() {
  echo ""
  echo -e "${YELLOW}  ▶  $1${RESET}"
  echo ""
}

pause() {
  echo ""
  echo -e "${GREEN}  [ press ENTER to continue ]${RESET}"
  read -r
  clear
}

# ---- Intro --------------------------------------------------
clear
header "CNCF Webinar — Part 1: Renovate CLI"
explain "We have a small Node.js service called cncf-demo-app.
     It ships with a Dockerfile, a Helm chart, and the usual
     npm dependencies — all intentionally pinned to old versions.
     Renovate will find every outdated package across all
     ecosystems in a single pass."
pause

# ---- Step 1: Repo layout -----------------------------------
header "Step 1 — What does our demo app look like?"
explain "Here is the directory tree. Notice we have three dependency
     ecosystems side-by-side: npm (package.json), Docker (Dockerfile),
     and Helm (Chart.yaml). Renovate understands all of them."

tree app/

pause

# ---- Step 2: Outdated npm deps ------------------------------
header "Step 2 — Current npm dependencies (intentionally old)"
explain "package.json is pinned to specific older versions.
     For example, express 4.18.1 and lodash 4.17.20 are behind
     their latest releases. Renovate will open one PR per package
     (or group them — depending on your config)."

cat app/package.json

pause

# ---- Step 3: Dockerfile -------------------------------------
header "Step 3 — Dockerfile base image"
explain "The Dockerfile uses node:18.12.0-alpine — a specific image tag.
     Renovate can pin this to a digest for reproducibility, AND
     open a PR when Node.js 18.x receives a patch update.
     You get both stability and freshness."

cat app/Dockerfile

pause

# ---- Step 4: Helm chart ------------------------------------
header "Step 4 — Helm chart dependencies"
explain "Chart.yaml declares postgresql 12.1.2 and redis 17.3.7
     from the Bitnami registry. These are also outdated.
     Renovate groups all Helm updates into a single PR — as
     configured in renovate.json — so you review them together."

cat app/Chart.yaml

pause

# ---- Step 5: Renovate config --------------------------------
header "Step 5 — Our Renovate configuration (renovate.json)"
explain "This is the brain of the setup. Key highlights:
     • Runs every weekend (schedule: every weekend)
     • Auto-merges patch/minor devDependency updates
     • Groups all Helm chart updates into one PR
     • Pins Docker base images to digest
     • Flags major updates with a 'needs-review' label
     • Enables vulnerability alerts out of the box"

cat renovate.json

pause

# ---- Step 6: Dry-run ----------------------------------------
header "Step 6 — Renovate dry-run (nothing is written, no PRs opened)"
explain "We run Renovate with --dry-run=full so you can see exactly
     what it would do — which PRs it would open, for which packages,
     with what version bump — without touching a single repository.
     This is great for testing a new config before going live."

LOG_LEVEL=info renovate \
  --dry-run=full \
  --token="$GH_TOKEN" \
  mogenius/cncf-renovate

pause

# ---- Step 7: What would the PRs look like? ------------------
header "Step 7 — Summary of what Renovate would open"
explain "Based on the dry-run output above, Renovate would create:
     • npm:  PRs for express, axios, lodash, winston, jest, eslint, typescript
     • Docker: PR to pin node:18.12.0-alpine to a sha256 digest
     • Helm: one grouped PR for postgresql + redis chart updates
     • Automerge enabled for devDependency patch/minor bumps
     → Switch to the GitHub UI now to show real PRs from a prior run."

pause

# ---- Done ---------------------------------------------------
header "Part 1 complete — next up: the Renovate Operator"
explain "The CLI is powerful, but running it by hand doesn't scale
     when you have dozens of repositories. In Part 2 we'll see how
     the Renovate Kubernetes Operator automates all of this,
     natively in your cluster."
echo ""
