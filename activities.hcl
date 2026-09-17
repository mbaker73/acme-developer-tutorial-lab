# ─────────────────────────────────────────────────────────────────────────────
# Activities
#
# The 1.0 track had one check-workstation script per challenge, each one
# emitting its own fail-message depending on which test failed. 2.0 makes the
# failure message a property of the condition, so each of those branches
# becomes its own condition with its own message.
# ─────────────────────────────────────────────────────────────────────────────

resource "task" "register_customer" {
  description = "Register a new customer through the Acme Analytics API."

  config {
    target = resource.container.workstation
  }

  condition "api_reachable" {
    description = "The Acme Analytics API is reachable and reports healthy"

    check {
      script          = "scripts/register_customer/api_reachable.sh"
      failure_message = "Could not reach the Acme API. Check `curl -s $ACME_API/api/health` in the terminal, then try again."
    }
  }

  condition "customer_registered" {
    description = "A new customer has been registered via `POST /api/customers`"

    check {
      script          = "scripts/register_customer/customer_registered.sh"
      failure_message = "No new customer has been registered yet. Complete Step 4 — POST a customer to `$ACME_API/api/customers`, then check again."
    }

    solve {
      script = "scripts/register_customer/solve.sh"
    }
  }
}

resource "task" "health_report" {
  description = "Complete the report script so it writes both sections to CSV."

  config {
    target = resource.container.workstation
  }

  condition "report_generated" {
    description = "`/root/acme_report.csv` has been generated"

    check {
      script          = "scripts/health_report/report_generated.sh"
      failure_message = "No report yet. Run `python3 /root/acme_report.py` in the terminal to generate `/root/acme_report.csv`."
    }
  }

  condition "revenue_section" {
    description = "The report contains the REVENUE BY SEGMENT section"

    check {
      script          = "scripts/health_report/revenue_section.sh"
      failure_message = "The report is missing the REVENUE BY SEGMENT section. That section ships complete in the starter — re-run the script to regenerate it."
    }
  }

  condition "churn_section" {
    description = "The report contains the CHURN WATCHLIST section, with one row per account"

    check {
      script          = "scripts/health_report/churn_section.sh"
      failure_message = "The CHURN WATCHLIST section is missing or has no rows under its header. Write the section header, the column headers, then loop over `churn[\"accounts\"]` — and re-run the script."
    }

    solve {
      script = "scripts/health_report/solve.sh"
    }
  }
}
