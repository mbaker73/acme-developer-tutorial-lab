# Acme Analytics — Developer Getting-Started Guide

Welcome. This guide gets you from zero to a working integration in about 10 minutes.

**What you're working with:**
- A live REST API backed by PostgreSQL — no mocking, no stubs
- Real customer and revenue data preloaded in the database
- Interactive API docs on the **API Docs** tab (powered by Swagger/OpenAPI)

**What you'll do in this chapter:**
- Call the health endpoint to verify connectivity
- List and filter customers using query parameters
- Register a new customer via `POST /api/customers`

**Tools available:** `curl`, `jq`, Python 3, and an `$ACME_API` environment variable pointing to the API base URL.

Open the **API Docs** tab to browse the full endpoint reference while you work.
