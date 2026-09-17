#!/bin/bash
set -euxo pipefail

# ─────────────────────────────────────────────
# Install API dependencies
# ─────────────────────────────────────────────
pip install fastapi "uvicorn[standard]" psycopg2-binary --quiet

# ─────────────────────────────────────────────
# Wait for postgres (Python-based wait — no pg_isready in this image)
#
# The container's health_check already gates on postgres being ready, so this
# is belt-and-braces rather than the only guard it used to be in 1.0.
# ─────────────────────────────────────────────
python3 - << 'WAITEOF'
import os, psycopg2, time, sys
cfg = dict(
    host=os.environ.get("PGHOST", "postgres"),
    database=os.environ.get("PGDATABASE", "acmedb"),
    user=os.environ.get("PGUSER", "acme"),
    password=os.environ.get("PGPASSWORD", "acmepassword"),
)
for i in range(60):
    try:
        conn = psycopg2.connect(**cfg)
        conn.close()
        print("Postgres is ready.")
        sys.exit(0)
    except psycopg2.OperationalError:
        print(f"Waiting for postgres... ({i+1}/60)")
        time.sleep(2)
print("ERROR: Postgres not ready after 120s", file=sys.stderr)
sys.exit(1)
WAITEOF

# ─────────────────────────────────────────────
# Create FastAPI application
# ─────────────────────────────────────────────
mkdir -p /opt/acme-api

cat > /opt/acme-api/main.py << 'PYEOF'
"""
Acme Analytics REST API
Version 1.0.0

Customer data and analytics endpoints backed by PostgreSQL.
"""

from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional
import os
import psycopg2
import psycopg2.extras

app = FastAPI(
    title="Acme Analytics API",
    description=(
        "The Acme Corp analytics platform API. "
        "Query customer data, revenue analytics, and churn intelligence — "
        "all backed by PostgreSQL.\n\n"
        "**Base URL:** `http://api:8000`\n\n"
        "No authentication required in this sandbox."
    ),
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Connection details come from the sandbox definition, not from this file.
DB_CONFIG = dict(
    host=os.environ.get("PGHOST", "postgres"),
    database=os.environ.get("PGDATABASE", "acmedb"),
    user=os.environ.get("PGUSER", "acme"),
    password=os.environ.get("PGPASSWORD", "acmepassword"),
)


def get_db():
    return psycopg2.connect(**DB_CONFIG)


# ──────────────────────────────────────────────────────────────────────────────
# Models
# ──────────────────────────────────────────────────────────────────────────────

class NewCustomer(BaseModel):
    name: str
    email: str
    company: str
    segment: str  # enterprise | mid-market | startup

    class Config:
        json_schema_extra = {
            "example": {
                "name": "Alex Rivera",
                "email": "alex@mycompany.com",
                "company": "MyCompany",
                "segment": "startup"
            }
        }


# ──────────────────────────────────────────────────────────────────────────────
# Health
# ──────────────────────────────────────────────────────────────────────────────

@app.get("/api/health", tags=["Status"])
def health_check():
    """Check that the API and database are operational."""
    try:
        conn = get_db()
        cur = conn.cursor()
        cur.execute("SELECT COUNT(*) FROM customers")
        count = cur.fetchone()[0]
        conn.close()
        return {"status": "ok", "service": "Acme Analytics API", "customers_loaded": count}
    except Exception as e:
        raise HTTPException(status_code=503, detail=f"Database error: {str(e)}")


# ──────────────────────────────────────────────────────────────────────────────
# Customers
# ──────────────────────────────────────────────────────────────────────────────

@app.get("/api/customers", tags=["Customers"])
def list_customers(
    segment: Optional[str] = Query(None, description="Filter by segment: enterprise, mid-market, startup"),
    status:  Optional[str] = Query(None, description="Filter by status: active, at-risk, churned"),
):
    """
    List all customers. Optionally filter by segment or status.
    """
    conn = get_db()
    cur  = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

    query  = "SELECT id, name, email, company, segment, status, created_at::date AS member_since FROM customers"
    params = []
    where  = []

    if segment:
        where.append("segment = %s"); params.append(segment)
    if status:
        where.append("status = %s"); params.append(status)
    if where:
        query += " WHERE " + " AND ".join(where)
    query += " ORDER BY created_at"

    cur.execute(query, params)
    customers = [dict(r) for r in cur.fetchall()]
    conn.close()

    return {"count": len(customers), "customers": customers}


@app.get("/api/customers/{customer_id}", tags=["Customers"])
def get_customer(customer_id: int):
    """Retrieve a single customer by ID."""
    conn = get_db()
    cur  = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    cur.execute(
        "SELECT id, name, email, company, segment, status, created_at::date AS member_since "
        "FROM customers WHERE id = %s",
        (customer_id,)
    )
    row = cur.fetchone()
    conn.close()

    if not row:
        raise HTTPException(status_code=404, detail=f"Customer {customer_id} not found")
    return dict(row)


@app.post("/api/customers", status_code=201, tags=["Customers"])
def create_customer(customer: NewCustomer):
    """
    Register a new customer.

    Valid segments: `enterprise`, `mid-market`, `startup`
    """
    valid_segments = {"enterprise", "mid-market", "startup"}
    if customer.segment not in valid_segments:
        raise HTTPException(
            status_code=422,
            detail=f"Invalid segment '{customer.segment}'. Must be one of: {sorted(valid_segments)}"
        )

    conn = get_db()
    cur  = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    try:
        cur.execute(
            """
            INSERT INTO customers (name, email, company, segment, status, created_at)
            VALUES (%s, %s, %s, %s, 'active', NOW())
            RETURNING id, name, email, company, segment, status, created_at::date AS member_since
            """,
            (customer.name, customer.email, customer.company, customer.segment)
        )
        conn.commit()
        result = dict(cur.fetchone())
    except psycopg2.IntegrityError:
        conn.rollback()
        raise HTTPException(status_code=409, detail=f"Email '{customer.email}' is already registered")
    finally:
        conn.close()

    return result


# ──────────────────────────────────────────────────────────────────────────────
# Analytics
# ──────────────────────────────────────────────────────────────────────────────

@app.get("/api/analytics/revenue", tags=["Analytics"])
def revenue_by_segment():
    """
    Revenue breakdown by customer segment.

    Returns total revenue, customer count, and average order value per segment.
    """
    conn = get_db()
    cur  = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    cur.execute("""
        SELECT
            c.segment,
            COUNT(DISTINCT c.id)            AS customer_count,
            COALESCE(SUM(o.amount), 0)      AS total_revenue,
            ROUND(AVG(o.amount), 2)         AS avg_order_value,
            COUNT(o.id)                     AS total_orders
        FROM customers c
        LEFT JOIN orders o ON o.customer_id = c.id AND o.status = 'completed'
        GROUP BY c.segment
        ORDER BY total_revenue DESC
    """)
    data = [dict(r) for r in cur.fetchall()]
    conn.close()

    total = sum(float(r["total_revenue"]) for r in data)
    return {
        "total_revenue": total,
        "by_segment": data
    }


@app.get("/api/analytics/churn-risk", tags=["Analytics"])
def churn_risk():
    """
    Accounts at risk of churning.

    Includes customers flagged as at-risk or churned, plus any active customers
    with no purchase in 90+ days.
    """
    conn = get_db()
    cur  = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    cur.execute("""
        SELECT
            c.id,
            c.name,
            c.company,
            c.segment,
            c.status,
            COALESCE(SUM(o.amount), 0)              AS lifetime_revenue,
            MAX(o.created_at)::date                  AS last_order_date,
            NOW()::date - MAX(o.created_at)::date    AS days_inactive,
            CASE
                WHEN c.status = 'churned'                              THEN 'churned'
                WHEN c.status = 'at-risk'                              THEN 'at-risk'
                WHEN NOW() - MAX(o.created_at) > INTERVAL '90 days'   THEN 'inactive-90d'
                ELSE 'monitor'
            END AS risk_level
        FROM customers c
        JOIN orders o ON o.customer_id = c.id
        GROUP BY c.id, c.name, c.company, c.segment, c.status
        HAVING c.status IN ('at-risk', 'churned')
            OR MAX(o.created_at) < NOW() - INTERVAL '90 days'
        ORDER BY days_inactive DESC
    """)
    accounts = [dict(r) for r in cur.fetchall()]
    conn.close()

    return {"count": len(accounts), "accounts": accounts}
PYEOF

# ─────────────────────────────────────────────
# Start the API server
#
# setsid detaches it from this exec's session, so the server survives the
# provisioning step finishing.
# ─────────────────────────────────────────────
cd /opt/acme-api
setsid nohup python3 -m uvicorn main:app \
  --host 0.0.0.0 \
  --port "${API_PORT:-8000}" \
  --workers 1 \
  --log-level warning \
  > /var/log/acme-api.log 2>&1 < /dev/null &

echo $! > /tmp/acme-api.pid

# Wait for the API to accept connections
for i in $(seq 1 30); do
  if curl -sf "http://localhost:${API_PORT:-8000}/api/health" > /dev/null 2>&1; then
    echo "Acme API is up."
    break
  fi
  sleep 2
done

echo "API setup complete."
