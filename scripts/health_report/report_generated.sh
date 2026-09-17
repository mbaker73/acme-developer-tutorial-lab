#!/bin/sh
# The learner has to actually run the script, not just edit it.
[ -f /root/acme_report.py ]  || exit 1
[ -f /root/acme_report.csv ] || exit 1

LINE_COUNT=$(wc -l < /root/acme_report.csv 2>/dev/null || echo 0)
[ "$LINE_COUNT" -ge 5 ] || exit 1
