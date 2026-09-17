#!/bin/bash
set -euxo pipefail

# The 1.0 version of this script opened by waiting on
# /opt/instruqt/bootstrap/host-bootstrap-completed. That file is a 1.0 host
# bootstrap artifact and does not exist in a 2.0 container sandbox — exec
# resources already run after the container is up, so the wait is gone.

# ─────────────────────────────────────────────
# Install developer tools
# ─────────────────────────────────────────────
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq curl jq python3 python3-pip

pip3 install requests --quiet

# ─────────────────────────────────────────────
# Set up a convenient alias and env var
# ─────────────────────────────────────────────

# Write to profile.d so it's available in all shell types (login + interactive)
cat > /etc/profile.d/acme.sh << 'ENVEOF'
export ACME_API="${ACME_API:-http://api:8000}"
alias acme-api='curl -s -H "Content-Type: application/json"'
ENVEOF
chmod +x /etc/profile.d/acme.sh

# Also add to .bashrc for non-login interactive shells
cat >> /root/.bashrc << 'ENVEOF'

# Acme Analytics API base URL
export ACME_API="${ACME_API:-http://api:8000}"
alias acme-api='curl -s -H "Content-Type: application/json"'

# Custom prompt — masks root user, keeps path context
export PS1='acme:\w$ '
ENVEOF

# ─────────────────────────────────────────────
# Wait for the API to be reachable from workstation
#
# This is the gate that makes the API's readiness a hard dependency: the
# sandbox is not finished provisioning until the learner's workstation can
# actually reach it over the shared network by name.
# ─────────────────────────────────────────────
API="${ACME_API:-http://api:8000}"
for i in $(seq 1 60); do
  if curl -sf "${API}/api/health" > /dev/null 2>&1; then
    echo "API is reachable from workstation."
    break
  fi
  echo "Waiting for API... ($i/60)"
  sleep 3
done

curl -sf "${API}/api/health" > /dev/null 2>&1 || {
  echo "ERROR: API never became reachable at ${API}" >&2
  exit 1
}

# 1.0's set-workdir helper does not exist in 2.0. The terminal tab sets its
# own working_directory instead — see resource.terminal.workstation.

echo "Workstation setup complete."
