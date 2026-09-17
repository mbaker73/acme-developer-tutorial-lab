#!/bin/sh
set -eux

# ─────────────────────────────────────────────
# Wait for postgres to accept connections
# ─────────────────────────────────────────────
until PGPASSWORD=acmepassword psql -h 127.0.0.1 -U acme -d acmedb -c "SELECT 1" > /dev/null 2>&1; do
  echo "Waiting for postgres..."
  sleep 2
done

echo "Postgres ready — loading Acme Corp schema and data..."

PGPASSWORD=acmepassword psql -h 127.0.0.1 -U acme -d acmedb << 'SQL'

-- ─────────────────────────────────────────────
-- Acme Corp Analytics Database — Schema
-- ─────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS customers (
  id          SERIAL PRIMARY KEY,
  name        VARCHAR(100) NOT NULL,
  email       VARCHAR(150) UNIQUE NOT NULL,
  company     VARCHAR(100),
  segment     VARCHAR(20) CHECK (segment IN ('enterprise', 'mid-market', 'startup')),
  status      VARCHAR(20) CHECK (status IN ('active', 'at-risk', 'churned')),
  created_at  TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS products (
  id            SERIAL PRIMARY KEY,
  name          VARCHAR(100) NOT NULL,
  category      VARCHAR(50),
  monthly_price NUMERIC(10,2)
);

CREATE TABLE IF NOT EXISTS orders (
  id          SERIAL PRIMARY KEY,
  customer_id INT REFERENCES customers(id),
  product_id  INT REFERENCES products(id),
  amount      NUMERIC(10,2),
  created_at  TIMESTAMP NOT NULL,
  status      VARCHAR(20) CHECK (status IN ('completed', 'pending', 'cancelled'))
);

-- Products
INSERT INTO products (name, category, monthly_price) VALUES
  ('Analytics Pro',          'Analytics',   299.00),
  ('Analytics Enterprise',   'Analytics',   999.00),
  ('Data Pipeline',          'Integration', 199.00),
  ('Reporting Suite',        'Reporting',   149.00),
  ('API Access',             'Developer',    99.00);

-- Customers
INSERT INTO customers (name, email, company, segment, status, created_at) VALUES
  ('Sarah Chen',       'sarah@techcorp.com',       'TechCorp',      'enterprise',  'active',   NOW() - INTERVAL '18 months'),
  ('Marcus Johnson',   'marcus@buildit.io',         'BuildIt',       'mid-market',  'active',   NOW() - INTERVAL '12 months'),
  ('Priya Patel',      'priya@cloudfast.com',       'CloudFast',     'enterprise',  'active',   NOW() - INTERVAL '24 months'),
  ('Tom Richards',     'tom@startflow.co',          'StartFlow',     'startup',     'at-risk',  NOW() - INTERVAL '8 months'),
  ('Anna Kowalski',    'anna@datapeak.io',          'DataPeak',      'mid-market',  'active',   NOW() - INTERVAL '15 months'),
  ('James Wu',         'james@nexustech.com',       'NexusTech',     'enterprise',  'active',   NOW() - INTERVAL '6 months'),
  ('Lisa Morales',     'lisa@rapidbuild.com',       'RapidBuild',    'startup',     'churned',  NOW() - INTERVAL '20 months'),
  ('David Kim',        'david@infraops.io',         'InfraOps',      'mid-market',  'at-risk',  NOW() - INTERVAL '10 months'),
  ('Rachel Thompson',  'rachel@enterprise-co.com',  'EnterpriseCo',  'enterprise',  'active',   NOW() - INTERVAL '30 months'),
  ('Carlos Reyes',     'carlos@devstudio.co',       'DevStudio',     'startup',     'active',   NOW() - INTERVAL '4 months'),
  ('Emily Park',       'emily@scaleworks.io',       'ScaleWorks',    'mid-market',  'active',   NOW() - INTERVAL '22 months'),
  ('Nathan Brown',     'nathan@techwave.com',       'TechWave',      'enterprise',  'at-risk',  NOW() - INTERVAL '14 months');

-- Orders
INSERT INTO orders (customer_id, product_id, amount, created_at, status) VALUES
  (1, 2, 999.00, NOW() - INTERVAL '18 months', 'completed'),
  (1, 3, 199.00, NOW() - INTERVAL '16 months', 'completed'),
  (1, 2, 999.00, NOW() -  INTERVAL '6 months', 'completed'),
  (1, 2, 999.00, NOW() -  INTERVAL '1 month',  'completed'),
  (2, 1, 299.00, NOW() - INTERVAL '12 months', 'completed'),
  (2, 4, 149.00, NOW() - INTERVAL '10 months', 'completed'),
  (2, 1, 299.00, NOW() -  INTERVAL '2 months', 'completed'),
  (3, 2, 999.00, NOW() - INTERVAL '24 months', 'completed'),
  (3, 2, 999.00, NOW() - INTERVAL '12 months', 'completed'),
  (3, 3, 199.00, NOW() -  INTERVAL '8 months', 'completed'),
  (3, 2, 999.00, NOW() -  INTERVAL '1 month',  'completed'),
  (4, 5,  99.00, NOW() -  INTERVAL '8 months', 'completed'),
  (4, 5,  99.00, NOW() -  INTERVAL '5 months', 'completed'),
  (5, 1, 299.00, NOW() - INTERVAL '15 months', 'completed'),
  (5, 4, 149.00, NOW() - INTERVAL '12 months', 'completed'),
  (5, 1, 299.00, NOW() -  INTERVAL '3 months', 'completed'),
  (6, 2, 999.00, NOW() -  INTERVAL '6 months', 'completed'),
  (6, 3, 199.00, NOW() -  INTERVAL '4 months', 'completed'),
  (6, 2, 999.00, NOW() -  INTERVAL '1 month',  'completed'),
  (7, 5,  99.00, NOW() - INTERVAL '20 months', 'completed'),
  (7, 5,  99.00, NOW() - INTERVAL '18 months', 'completed'),
  (8, 1, 299.00, NOW() - INTERVAL '10 months', 'completed'),
  (8, 4, 149.00, NOW() -  INTERVAL '8 months', 'completed'),
  (9, 2, 999.00, NOW() - INTERVAL '30 months', 'completed'),
  (9, 2, 999.00, NOW() - INTERVAL '18 months', 'completed'),
  (9, 3, 199.00, NOW() - INTERVAL '10 months', 'completed'),
  (9, 2, 999.00, NOW() -  INTERVAL '2 months', 'completed'),
  (10, 5,  99.00, NOW() -  INTERVAL '4 months', 'completed'),
  (10, 1, 299.00, NOW() -  INTERVAL '2 months', 'completed'),
  (11, 1, 299.00, NOW() - INTERVAL '22 months', 'completed'),
  (11, 4, 149.00, NOW() - INTERVAL '18 months', 'completed'),
  (11, 1, 299.00, NOW() -  INTERVAL '4 months', 'completed'),
  (12, 2, 999.00, NOW() - INTERVAL '14 months', 'completed'),
  (12, 2, 999.00, NOW() - INTERVAL '10 months', 'completed');

SQL

echo "Acme Corp data loaded successfully."
