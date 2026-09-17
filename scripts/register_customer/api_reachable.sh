#!/bin/sh
# The API must answer before anything else in this chapter can be true.
API="${ACME_API:-http://api:8000}"
curl -sf "${API}/api/health" 2>/dev/null \
  | python3 -c 'import sys,json; sys.exit(0 if json.load(sys.stdin).get("status")=="ok" else 1)' 2>/dev/null
