#!/bin/bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# Report starter + reference files
#
# In 1.0 this was 02-build-something-real/setup-workstation, run when the
# learner entered challenge 2. 2.0 has no per-chapter setup lifecycle, so the
# files are staged during sandbox provisioning instead. The learner sees them
# only when they reach the chapter, so the experience is unchanged.
#
# The 1.0 script also POSTed a customer here as a defensive backstop in case
# the learner skipped challenge 1. That is dropped: it pre-completed part of
# chapter 1's task and made the "count goes up" check in chapter 2 Step 4
# harder to reason about. Skipping is still allowed — the report simply runs
# against whatever is in the database.
# ─────────────────────────────────────────────────────────────────────────────

cat > /root/acme_report.py << 'PYEOF'
#!/usr/bin/env python3
"""
Acme Analytics — Customer Health Report Generator
Pulls live data from the Acme API and writes a CSV summary.
"""

import os
import requests
import csv
from datetime import datetime

BASE_URL = os.environ.get("ACME_API", "http://api:8000")


def fetch(endpoint):
    response = requests.get(f"{BASE_URL}{endpoint}")
    response.raise_for_status()
    return response.json()


def main():
    print("Connecting to Acme Analytics API...")

    revenue = fetch("/api/analytics/revenue")
    churn   = fetch("/api/analytics/churn-risk")

    report_path = "/root/acme_report.csv"

    with open(report_path, "w", newline="") as f:
        writer = csv.writer(f)

        # Section 1: Revenue by segment (complete)
        writer.writerow(["REVENUE BY SEGMENT"])
        writer.writerow(["Segment", "Customers", "Total Revenue ($)", "Avg Order Value ($)"])
        for row in revenue["by_segment"]:
            writer.writerow([
                row["segment"],
                row["customer_count"],
                float(row["total_revenue"]),
                float(row["avg_order_value"]) if row["avg_order_value"] else 0,
            ])
        writer.writerow([])

        # Section 2: Churn Watchlist — YOUR CODE HERE
        # Add the churn watchlist section following the same pattern as above.
        # Data source: churn["accounts"]
        # Fields: name, company, segment, status, days_inactive, risk_level

    print(f"Report saved: {report_path}")
    print(f"Generated at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")


if __name__ == "__main__":
    main()
PYEOF

cat > /root/acme_report_complete.py << 'PYEOF'
#!/usr/bin/env python3
"""
Acme Analytics — Customer Health Report Generator (Complete)
Reference implementation — see acme_report.py to complete the exercise.
"""

import os
import requests
import csv
from datetime import datetime

BASE_URL = os.environ.get("ACME_API", "http://api:8000")


def fetch(endpoint):
    response = requests.get(f"{BASE_URL}{endpoint}")
    response.raise_for_status()
    return response.json()


def main():
    print("Connecting to Acme Analytics API...")

    revenue = fetch("/api/analytics/revenue")
    churn   = fetch("/api/analytics/churn-risk")

    report_path = "/root/acme_report.csv"

    with open(report_path, "w", newline="") as f:
        writer = csv.writer(f)

        # Section 1: Revenue by segment
        writer.writerow(["REVENUE BY SEGMENT"])
        writer.writerow(["Segment", "Customers", "Total Revenue ($)", "Avg Order Value ($)"])
        for row in revenue["by_segment"]:
            writer.writerow([
                row["segment"],
                row["customer_count"],
                float(row["total_revenue"]),
                float(row["avg_order_value"]) if row["avg_order_value"] else 0,
            ])
        writer.writerow([])

        # Section 2: Churn Watchlist
        writer.writerow(["CHURN WATCHLIST"])
        writer.writerow(["Name", "Company", "Segment", "Status", "Days Inactive", "Risk Level"])
        for acct in churn["accounts"]:
            writer.writerow([
                acct["name"],
                acct["company"],
                acct["segment"],
                acct["status"],
                acct["days_inactive"],
                acct["risk_level"],
            ])

    print(f"Report saved: {report_path}")
    print(f"Generated at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")


if __name__ == "__main__":
    main()
PYEOF

echo "Report starter and reference staged in /root."
