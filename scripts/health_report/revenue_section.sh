#!/bin/sh
# Section 1 ships complete in the starter, so this catches a broken run
# rather than unfinished work.
grep -q "REVENUE BY SEGMENT" /root/acme_report.csv 2>/dev/null
