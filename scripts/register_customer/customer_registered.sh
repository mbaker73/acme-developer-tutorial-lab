#!/bin/sh
# The seed data loads exactly 12 customers, so anything above that is the
# learner's own POST /api/customers landing in Postgres.
API="${ACME_API:-http://api:8000}"
COUNT=$(curl -sf "${API}/api/customers" 2>/dev/null \
  | python3 -c 'import sys,json; print(json.load(sys.stdin)["count"])' 2>/dev/null || echo "")

[ -n "$COUNT" ] || exit 1
[ "$COUNT" -gt 12 ] || exit 1
