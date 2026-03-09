#!/usr/bin/env bash
# =============================================================
# CNCF Webinar Demo — Part 2: Renovate Operator
# =============================================================
# Usage: bash demo-operator.sh
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

pause() {
  echo ""
  echo -e "${GREEN}  [ press ENTER to continue ]${RESET}"
  read -r
  clear
}

# ---- Intro --------------------------------------------------
clear
header "CNCF Webinar — Part 2: Renovate Operator"
explain "• CLI doesn't scale beyond a handful of repos
     • Operator runs inside Kubernetes — no external scheduler
     • GitOps-friendly: manage scans as YAML manifests in Git
     • Beautiful UI with dark mode
     • Resource limits, automatic retries
     • Jobs run in parallel, no waiting for one repo at a time
     • Same renovate.json config, same PRs, but fully automated"
pause

# ---- Step 1: Operator is running ----------------------------
header "Step 1 — Installation"
explain "• Simply install the helm chart
     • Runs as a Deployment in renovate-operator namespace
     • Watches the RenovateJob CRD"

kubectl get pods -n renovate-operator

pause

# ---- Step 2: Operator UI ------------------------------------
header "Step 2 — Renovate Operator UI"
explain "• Built-in web UI — no extra tooling needed
     • Shows all jobs, logs, and scan history
     • Dark mode included
     → Opening http://localhost:8081 in your browser"

kubectl port-forward -n renovate-operator \
  svc/renovate-operator-renovate-operator 8081:8081 &
PF_PID=$!
sleep 2
open "http://localhost:8081" 2>/dev/null || xdg-open "http://localhost:8081" 2>/dev/null || true

pause
kill $PF_PID 2>/dev/null

# ---- Step 3: Show the CRDs ----------------------------------
header "Step 3 — Custom Resource Definitions"
explain "• RenovateJob — schedules a scan of specific repos
     • First-class K8s object: RBAC, GitOps, audit trail"

kubectl get crds | grep renovate

pause

# ---- Step 4: Stream the logs --------------------------------
header "Step 4 — Trigger a scan and stream the logs"
explain "• Apply a RenovateJob — operator picks it up immediately
     • Stream real-time logs from the executor pod
     • Same log output as the CLI — but running inside your cluster"

kubectl delete renovatejob scan-cncf-demo -n renovate-operator --ignore-not-found
kubectl apply -f operator/renovatejob.yaml

echo ""
pause

# ---- Step 5: Kubernetes event audit trail -----------------
header "Step 5 — Kubernetes Events: built-in audit trail"
explain "• Every scan is recorded as a K8s Event
     • Queryable with kubectl, exportable to your observability stack"

kubectl get events -n renovate-operator \
  --sort-by='.lastTimestamp' \
  | tail -20

pause

# ---- Done ---------------------------------------------------
header "Part 2 complete"
explain "• RenovateJob CRD — define scans as YAML, apply with kubectl or GitOps
     • Credentials via K8s Secrets — no plain-text tokens
     • K8s Events — free built-in audit log
     • Same renovate.json as the CLI — one config, two deployment modes"
echo ""
