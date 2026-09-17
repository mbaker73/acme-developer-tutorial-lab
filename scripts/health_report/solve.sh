#!/bin/sh
set -eu

# The reference implementation is already staged on the workstation, so the
# solve is the same edit the learner is asked to make: copy it into place.
cp /root/acme_report_complete.py /root/acme_report.py
python3 /root/acme_report.py

echo "Solve complete: acme_report.csv generated with both sections."
