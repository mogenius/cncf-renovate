#!/usr/bin/env bash
# =============================================================
# CNCF Webinar Demo — Part 1: Renovate CLI
# =============================================================
# Usage: bash demo-cli.sh
# Press ENTER at each pause to advance to the next step.
# =============================================================

export RENOVATE_GIT_AUTHOR="Renovate Bot <renovate@mogenius.com>"

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
explain "• Node.js app with npm, Docker, and Helm dependencies
     • All pinned to old versions — intentionally
     • Renovate scans all ecosystems in one pass
     • You only have to install the CLI"

echo ""
echo ""
echo "renovate --version"
renovate --version

pause

# ---- Step 1: Repo layout -----------------------------------
header "Step 1 — What does our demo app look like?"
explain "• package.json — npm deps
     • Dockerfile — base image
     • Chart.yaml — Helm subcharts"

tree app/

pause

# ---- Step 2: Outdated npm deps ------------------------------
header "Step 2 — Current npm dependencies (intentionally old)"
explain "• Pinned to older versions
     • Renovate opens one PR per package (grouping possible)"

cat app/package.json

pause

# ---- Step 3: Dockerfile -------------------------------------
header "Step 3 — Dockerfile base image"
explain "• node:18.0.0-alpine — outdated tag
     • Renovate pins to digest + opens PR on patch updates"

cat app/Dockerfile

pause

# ---- Step 4: Helm chart ------------------------------------
header "Step 4 — Helm chart dependencies"
explain "• mariadb 0.5.0 + memcached 0.7.0 — outdated
     • Renovate groups Helm updates into one PR"

cat app/Chart.yaml

pause

# ---- Step 5: Renovate config --------------------------------
header "Step 5 — Our Renovate configuration (renovate.json)"
explain "• Auto-merge patch/minor devDeps (disabled for demo)
     • Group Helm updates into one PR
     • Label major updates 'needs-review'"

cat renovate.json

pause

# ---- Step 6: Dry-run ----------------------------------------
header "Step 6 — Renovate dry-run (nothing is written, no PRs opened)"
explain "• --dry-run=full: shows planned PRs without opening them
     • Safe way to preview config before going live"

echo "renovate --dry-run=full mogenius/cncf-renovate"
LOG_LEVEL=info renovate \
  --dry-run=full \
  --token="$GH_TOKEN" \
  mogenius/cncf-renovate

pause

# ---- Step 7: What would the PRs look like? ------------------
header "Step 7 — Summary of what Renovate would open"
explain "• npm: PRs for express, axios, lodash, winston, jest, eslint, typescript
     • Docker: pin node:18.12.0-alpine to sha256 digest
     • Helm: one grouped PR for mariadb + memcached
     • devDep patch/minor: automerge
     → Switch to GitHub UI to show real PRs from a prior run"

pause

# ---- Done ---------------------------------------------------
header "Part 1 complete — next up: the Renovate Operator"
explain "• CLI works great for one repo
     • Part 2: Renovate Operator — automated, scheduled, cluster-native, at scale"
echo ""

pause
