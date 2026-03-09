#!/usr/bin/env bash
# =============================================================
# CNCF Webinar Demo — Renovate CLI & Operator
# =============================================================
# Usage: bash demo.sh
# Press ENTER at each pause to advance to the next step.
# =============================================================

export RENOVATE_GIT_AUTHOR="Renovate Bot <renovate@mogenius.com>"

# ---- Helpers ------------------------------------------------
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GRAY='\033[0;90m'
BOLD='\033[1m'
RESET='\033[0m'

header() {
  echo ""
  echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo -e "${BOLD}${CYAN}  $1${RESET}"
  echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

explain() {
  local lines=()
  while IFS= read -r line; do
    line="${line#"${line%%[![:space:]]*}"}"
    [ -n "$line" ] && lines+=("$line")
  done <<< "$1"
  printf "\n"
  local total=${#lines[@]}
  for ((i=0; i<total; i++)); do
    printf "${YELLOW}  ▶  ${lines[$i]}${RESET}\n"
    if [[ $i -lt $((total-1)) ]]; then
      stty -echo < /dev/tty
      read -r < /dev/tty
      stty echo < /dev/tty
      printf "\033[1A\033[2K\r     ${lines[$i]}\n"
    fi
  done
  printf "\n"
}

# Print a command label, then run it
run() {
  echo -e "${GRAY}  \$${RESET} ${BOLD}$*${RESET}"
  echo ""
  "$@"
}

pause() {
  echo ""
  echo -e "${GREEN}  [ press ENTER to continue ]${RESET}"
  read -r
  clear
}

section() {
  echo ""
  echo -e "${BOLD}${GREEN}════════════════════════════════════════════════════════════${RESET}"
  echo -e "${BOLD}${GREEN}  $1${RESET}"
  echo -e "${BOLD}${GREEN}════════════════════════════════════════════════════════════${RESET}"
  echo ""
}

# ============================================================
# PART 1 — RENOVATE CLI
# ============================================================

clear
section "Part 1 — Renovate CLI"

header "Introduction"
explain "• Keeping dependencies up to date is unglamorous — but critical
     • Outdated packages mean security holes, compatibility debt, and surprise breakages
     • Renovate automates this: it scans your repo and opens PRs for every outdated dep
     • Today: we show it running as a CLI against a real app — npm, Docker, and Helm"

run renovate --version

pause

# ---- Step 1: The demo app -----------------------------------
header "Step 1 — Our demo app"
explain "• A simple Node.js service with three dependency ecosystems
     • package.json — npm runtime and dev dependencies
     • Dockerfile — base image
     • Chart.yaml — Helm subcharts for database and cache
     • All intentionally pinned to older versions"

run tree app/

pause

# ---- Step 2: npm deps ---------------------------------------
header "Step 2 — npm dependencies"
explain "• Express, axios, lodash — all behind current releases
     • Renovate opens one PR per package by default
     • Or group them — fully configurable"

run bat app/package.json

pause

# ---- Step 3: Dockerfile -------------------------------------
header "Step 3 — Docker base image"
explain "• node:18.12.0-alpine — a specific but outdated tag
     • Renovate can pin it to a sha256 digest for reproducibility
     • And open a PR whenever a newer patch is released"

run bat app/Dockerfile

pause

# ---- Step 4: Helm chart ------------------------------------
header "Step 4 — Helm chart dependencies"
explain "• mariadb 0.5.0 + memcached 0.7.0 from the CloudPirates OCI registry
     • Both behind the latest release
     • Renovate groups all Helm updates into a single PR — configurable"

run bat app/Chart.yaml

pause

# ---- Step 5: Renovate config --------------------------------
header "Step 5 — renovate.json — the single source of truth"
explain "• One config file drives everything — all ecosystems, all rules
     • Group Helm updates, label major bumps, set automerge rules
     • This same file will work in the CLI and in the Operator"

run bat renovate.json

pause

# ---- Step 6: Dry-run ----------------------------------------
header "Step 6 — Dry run: what would Renovate do?"
explain "• --dry-run=full shows every planned PR without opening any
     • Perfect for testing a new config before going live
     • Let's run it now against this repo"

echo -e "${GRAY}  \$${RESET} ${BOLD}renovate --dry-run=full --token=**** mogenius/cncf-renovate${RESET}"
echo ""
renovate --dry-run=full --token="$GH_TOKEN" mogenius/cncf-renovate

pause

# ---- Step 7: The problem ------------------------------------
header "Step 7 — The CLI is great — until it isn't"
explain "• For one repo: perfect
     • For 10, 50, 100 repos: you need a cron job, a CI pipeline, a server
     • No visibility into what ran, what failed, what was skipped
     • No UI — just logs, if you remembered to capture them
     • Sequential execution — repo 100 waits for repo 1 to finish
     • This is exactly where we hit a wall at mogenius"

pause

header "That's the CLI — powerful, but not built for scale"
explain "• Great starting point for any team
     • The config you just saw travels with you
     • Next: we solve the scaling problem with the Renovate Operator"

pause

# ============================================================
# PART 2 — RENOVATE OPERATOR
# ============================================================

clear
section "Part 2 — Renovate Operator"

header "Introduction"
explain "• We built the Renovate Operator to solve exactly the problems we just saw
     • Kubernetes-native: a single Helm install, a CRD, and you're done
     • Parallel execution, built-in UI, full observability
     • Same renovate.json — zero migration cost"

pause

# ---- Step 1: Installation -----------------------------------
header "Step 1 — One Helm install, that's it"
explain "• helm install renovate-operator mogenius/renovate-operator
     • Runs as a standard Deployment — no sidecars, no agents
     • Registers the RenovateJob CRD and starts watching the cluster"

run kubectl get pods -n renovate-operator

pause

# ---- Step 2: The UI -----------------------------------------
header "Step 2 — Built-in UI: the visibility we were missing"
explain "• The CLI had no dashboard — you had to grep through logs
     • The Operator ships a web UI out of the box
     • See all jobs, per-repo execution status, logs, scan history
     • Dark mode included — opening it now"

run kubectl port-forward -n renovate-operator \
  svc/renovate-operator-renovate-operator 8081:8081 &
PF_PID=$!
sleep 2
open "http://localhost:8081" 2>/dev/null || xdg-open "http://localhost:8081" 2>/dev/null || true

pause
kill $PF_PID 2>/dev/null

# ---- Step 3: The CRD ----------------------------------------
header "Step 3 — RenovateJob: declarative scans as Kubernetes objects"
explain "• Instead of a cron + shell script, you write a YAML manifest
     • Apply it with kubectl or let your GitOps pipeline do it
     • RBAC-controlled, auditable, versioned in Git like everything else
     • The operator detects it and spawns isolated job pods — in parallel"

run kubectl get crds | grep renovate
echo ""
run bat operator/renovatejob.yaml

pause

# ---- Step 4: Run a scan -------------------------------------
header "Step 4 — Trigger a scan: apply a RenovateJob"
explain "• One kubectl apply — operator picks it up within seconds
     • Spawns a discovery pod, then parallel executor pods per repo
     • Streams real-time logs — same output as the CLI, but fully automated"

run kubectl delete renovatejob scan-cncf-demo -n renovate-operator --ignore-not-found
run kubectl apply -f operator/renovatejob.yaml

echo ""
echo -e "${GRAY}  Waiting for executor pod...${RESET}"
kubectl wait --for=condition=ready pod \
  -l renovate-operator.mogenius.com/job-type=executor \
  -n renovate-operator \
  --timeout=120s

echo ""
run kubectl logs -f -n renovate-operator \
  -l renovate-operator.mogenius.com/job-type=executor \
  --tail=100

pause

# ---- Step 5: Audit trail ------------------------------------
header "Step 5 — Kubernetes Events: a free audit log"
explain "• Every job creation, execution, and completion is recorded
     • No extra logging infrastructure needed
     • Query with kubectl, ship to Loki, Datadog, whatever you use"

run kubectl get events -n renovate-operator \
  --sort-by='.lastTimestamp' | tail -20

pause

# ---- Done ---------------------------------------------------
header "Wrap-up"
explain "• Renovate CLI: perfect for getting started, one repo at a time
     • Renovate Operator: the same tool, built for platform teams at scale
     • One renovate.json — works in both modes, no migration needed
     • Open source, Kubernetes-native, built by mogenius
     • github.com/mogenius/renovate-operator"
echo ""
