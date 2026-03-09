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
header "CNCF Webinar — Part 2: Renovate Operator"
explain "Running Renovate as a CLI is fine for a single repo.
     But in a platform team managing 20, 50, 100+ repositories
     you need something that runs on a schedule, is auditable,
     and fits into your existing Kubernetes-native workflows.
     That's what the Renovate Operator gives you."
pause

# ---- Step 1: Operator is running ----------------------------
header "Step 1 — The Renovate Operator is already installed"
explain "The Operator runs as a standard Kubernetes Deployment in
     the 'renovate-system' namespace. It watches for two custom
     resources: RenovateJob (one-shot) and RenovateSchedule (cron).
     Nothing else needed — no external scheduler, no CI pipeline."

kubectl get pods -n renovate-system

pause

# ---- Step 2: Show the CRDs ----------------------------------
header "Step 2 — Custom Resource Definitions"
explain "The Operator ships two CRDs:
     • RenovateJob — trigger an immediate scan of specific repos
     • RenovateSchedule — run scans on a cron schedule
     These are first-class Kubernetes objects: you can RBAC them,
     audit them via Events, and GitOps-manage them like any other manifest."

kubectl get crds | grep renovate

pause

# ---- Step 3: Scheduled scans --------------------------------
header "Step 3 — What scheduled scans do we have?"
explain "Let's list all RenovateSchedule objects in the cluster.
     'weekly-org-scan' covers all four of our platform repositories
     and runs every Sunday at 02:00. It posts a summary to Slack
     when it's done — zero manual overhead for the on-call team."

kubectl get renovateschedule -n renovate-system

pause

# ---- Step 4: Describe the schedule -------------------------
header "Step 4 — Inspect the weekly-org-scan schedule"
explain "The full spec shows the cron expression, the list of repos,
     which ConfigMap holds the shared renovate.json, which Secret
     holds the GitHub App credentials, and the Slack notification config.
     Everything declarative, everything in Git."

kubectl describe renovateschedule weekly-org-scan -n renovate-system

pause

# ---- Step 5: Show the schedule YAML ------------------------
header "Step 5 — RenovateSchedule manifest (operator/renovateschedule.yaml)"
explain "This is the exact YAML we applied to the cluster.
     Notice: 'schedule: 0 2 * * 0' — every Sunday at 02:00 UTC.
     The four repos listed are the same ones we scanned with the CLI.
     The Operator spins up a fresh Renovate Job pod for each run,
     collects logs, then cleans up — no long-running containers."

cat operator/renovateschedule.yaml

pause

# ---- Step 6: Show the secrets setup -------------------------
header "Step 6 — Credentials: renovate-secrets"
explain "Renovate needs a GitHub token (or a GitHub App key for orgs).
     We store these in a standard Kubernetes Secret and reference
     them by name from both RenovateJob and RenovateSchedule.
     The Operator mounts the secret into the Job pod as env vars —
     credentials never appear in logs or CRD specs."

cat operator/renovate-secrets.yaml

pause

# ---- Step 7: Trigger a manual run --------------------------
header "Step 7 — Triggering an on-demand scan with RenovateJob"
explain "Sometimes you want to kick off a scan right now — maybe you
     just merged a new renovate.json rule and want to see the effect.
     We apply a RenovateJob manifest that targets three repos.
     The Operator picks it up immediately and creates a Kubernetes Job."

cat operator/renovatejob.yaml
echo ""
explain "Applying the manifest now..."

kubectl apply -f operator/renovatejob.yaml

pause

# ---- Step 8: Watch the pod come up -------------------------
header "Step 8 — Waiting for the Renovate Job pod to be ready"
explain "The Operator creates a Job named 'scan-cncf-demo'.
     We wait for its pod to reach Ready state — this usually takes
     10-20 seconds while Kubernetes pulls the Renovate image."

kubectl wait --for=condition=ready pod \
  -l job-name=scan-cncf-demo \
  -n renovate-system \
  --timeout=90s

pause

# ---- Step 9: Stream the logs --------------------------------
header "Step 9 — Live Renovate logs (Ctrl+C to stop following)"
explain "These are the same logs you'd see from the CLI — repository
     lookups, version comparisons, PR creation events.
     The difference: this all happened automatically, inside your
     cluster, with your RBAC, your secrets, your audit trail.
     Press Ctrl+C when you've seen enough, then ENTER to continue."

kubectl logs -f \
  -n renovate-system \
  -l job-name=scan-cncf-demo

pause

# ---- Step 10: Kubernetes event audit trail -----------------
header "Step 10 — Kubernetes Events: the built-in audit trail"
explain "Every Job creation, pod scheduling, and completion is
     recorded as a Kubernetes Event. This gives you a free audit
     log of when scans ran and whether they succeeded — queryable
     with kubectl, exportable to your observability stack."

kubectl get events -n renovate-system \
  --sort-by='.lastTimestamp' \
  | tail -20

pause

# ---- Done ---------------------------------------------------
header "Part 2 complete"
explain "Recap:
     • RenovateSchedule  → cron-driven, fire-and-forget org-wide scans
     • RenovateJob       → on-demand scans, triggerable from CI or GitOps
     • Credentials via Kubernetes Secrets  → no plain-text tokens in YAML
     • Kubernetes Events → free audit log of every scan
     • Same renovate.json config as the CLI — one config, two deployment modes

     Questions?"
echo ""
