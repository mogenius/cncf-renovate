# CNCF Webinar — Renovate Demo Runbook

```
kubectl taint nodes home-flux-test-controlplane-1 node-role.kubernetes.io/control-plane:NoSchedule-
```

## Pre-flight Checklist (30 min before)
- [ ] `export GITHUB_TOKEN=ghp_...` is set
- [ ] `kubectl get pods -n renovate-system` → all pods Running
- [ ] Demo repo has outdated deps (verify package.json versions!)
- [ ] GitHub UI open — showing NO Renovate PRs yet
- [ ] Terminal: Font ≥ 20pt, dark theme, zoom 125%
- [ ] Fallback screenshots ready (in case something hangs live)

## Part 1 — CLI (4 min)
1. `cat renovate.json` → walk through the config (30 sec)
2. `cat app/package.json` → *"Look — these are all outdated"* (15 sec)
3. `npx renovate --dry-run ...` → explain live output (60 sec)
4. Switch to GitHub UI → show created PRs (60 sec)
5. Transition: *"Now imagine doing this for 100 repos..."*

## Part 2 — Operator (5 min)
1. `kubectl get pods -n renovate-system` → *"It's just a pod"* (20 sec)
2. `kubectl get crds | grep renovate` → show CRDs (20 sec)
3. `cat operator/renovateschedule.yaml` → declarative config (45 sec)
4. `kubectl apply -f operator/renovatejob.yaml` → trigger run (15 sec)
5. `kubectl logs -f ...` → live output (60 sec)
6. `kubectl get events ...` → *"Full audit trail, GitOps-native"* (30 sec)

## Key Talking Points
- "Same renovate.json — CLI and Operator use identical config"
- "No SaaS dependency — runs fully in your cluster"
- "CRs are GitOps-friendly — commit them to your platform repo"
- "Scales from 1 to 500+ repos without changing the config"

## Fallback if Something Hangs
- Dry-run output: screenshot ready as backup
- PRs: pre-created on branch `demo/renovate-prs`
- Logs: `cat scripts/sample-output.log` as pre-recorded fallback
