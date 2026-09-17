You've explored the API. Now build something with it.

In this chapter you'll create a Python script that calls the Acme Analytics API, processes live data, and generates a customer health report as a CSV file.

---

## Step 1: Review the API Response Shapes

Start by confirming what each analytics endpoint returns. You'll need these field names in your report:

```bash,run
curl -s $ACME_API/api/analytics/revenue | jq '{total_revenue: .total_revenue, sample_segment: .by_segment[0]}'
```

```bash,run
curl -s $ACME_API/api/analytics/churn-risk | jq '{count: .count, sample_account: .accounts[0]}'
```

Note the field names in each response — your script will map these directly into CSV columns. Refer to the API Docs tab for the full schema.

---

## Step 2: Review the Starter Script

Open the **Editor** tab. The starter script is pre-loaded at `/root/acme_report.py`. Review it now — the revenue section is complete, but the churn section is a `TODO` you'll implement in Step 3.

Run the starter as-is to confirm the revenue section works:

```bash,run
python3 /root/acme_report.py
```

```bash,run
cat /root/acme_report.csv
```

You'll see the **REVENUE BY SEGMENT** section with data. Note the enterprise customer count — you'll verify it changes after Step 4. The churn section is missing — that's your job in Step 3.

---

## Step 3: Add the Churn Watchlist

Open the editor and complete the churn section. The `churn` variable is already fetched at the top of `main()` — you need to write it to the CSV below the existing revenue section.

Your churn section should:

1. Write a section header row: `CHURN WATCHLIST`
2. Write a column header row: `Name`, `Company`, `Segment`, `Status`, `Days Inactive`, `Risk Level`
3. Loop through `churn["accounts"]` and write one row per account

> [!TIP]
> Follow the same pattern as the revenue section directly above the TODO comment. The key differences: data source is `churn["accounts"]` instead of `revenue["by_segment"]`, and the field names are `name`, `company`, `segment`, `status`, `days_inactive`, `risk_level`. Start with `writer.writerow(["CHURN WATCHLIST"])`.

Wait for the editor to save, then run and verify from the terminal:

```bash,run
python3 /root/acme_report.py
```

```bash,run
cat /root/acme_report.csv
```

You should see both **REVENUE BY SEGMENT** and **CHURN WATCHLIST** sections with data.

If you need help, open `/root/acme_report_complete.py` in the Editor tab — it contains the completed implementation.

<instruqt-task id="health_report">
  Complete the churn section of `/root/acme_report.py` and regenerate `/root/acme_report.csv` so it contains both the REVENUE BY SEGMENT and CHURN WATCHLIST sections.
</instruqt-task>

---

## Step 4: Extend the Integration

The `POST /api/customers` endpoint you used in the previous chapter feeds the same database. Register a new enterprise customer and verify the report updates to reflect it:

```bash,run
curl -s -X POST $ACME_API/api/customers \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Morgan Lee",
    "email": "morgan@newaccount.io",
    "company": "NewAccount",
    "segment": "enterprise"
  }' | jq '{id, name, segment, status}'
```

Re-run the report:

```bash,run
python3 /root/acme_report.py
```

```bash,run
cat /root/acme_report.csv
```

Check the REVENUE BY SEGMENT section — the enterprise customer count should now be one higher than when you ran it in Step 2. Every run pulls the current state from the database. The integration is live.

✅ You've built a working API integration that pulls live data and generates a customer health report. The script, the API calls, the CSV — all connected to a live PostgreSQL backend.
