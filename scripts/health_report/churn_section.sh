#!/bin/sh
# Section 2 is the exercise: header row plus one row per at-risk account.
grep -q "CHURN WATCHLIST" /root/acme_report.csv 2>/dev/null || exit 1

# A header with no rows under it means the loop was not written.
ROWS=$(awk '/CHURN WATCHLIST/{found=1; next} found && NF' /root/acme_report.csv 2>/dev/null | wc -l)
[ "$ROWS" -ge 2 ] || exit 1
