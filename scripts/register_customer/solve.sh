#!/bin/sh
set -eu
API="${ACME_API:-http://api:8000}"

curl -sf -X POST "${API}/api/customers" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Alex Rivera",
    "email": "alex@mycompany.com",
    "company": "MyCompany",
    "segment": "startup"
  }' > /dev/null

echo "Solve complete: new customer registered via API."
