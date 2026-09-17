# ─────────────────────────────────────────────────────────────────────────────
# Tabs
#
# 1.0 declared tabs per challenge, in frontmatter, and referenced them
# positionally (tab-0, tab-1, ...). In 2.0 a tab is a named resource declared
# once and placed into layouts, so the same Terminal and API Docs tabs are
# shared by both chapters instead of being duplicated.
# ─────────────────────────────────────────────────────────────────────────────

resource "terminal" "workstation" {
  target = resource.container.workstation

  shell             = "/bin/bash"
  user              = "root"
  group             = "root"
  working_directory = "/root"
}

# The Acme Analytics API's own Swagger UI, served by the api container.
resource "service" "api_docs" {
  target = resource.container.api
  scheme = "http"
  port   = 8000
  path   = "/docs"
}

# ─────────────────────────────────────────────────────────────────────────────
# ADDED FOR COVERAGE — not a port of anything in the 1.0 track.
#
# 1.0 had two single-file `type: code` tabs: "Report Editor" pinned to
# /root/acme_report.py and "Reference" pinned to /root/acme_report_complete.py.
# 2.0's editor is workspace-scoped (a directory, not a file), so those two
# tabs collapse into one editor rooted at /root, where both files are visible
# in the file tree.
# ─────────────────────────────────────────────────────────────────────────────
resource "editor" "report" {
  extensions = [
    "ms-python.python"
  ]

  theme    = "Default Dark Modern"
  settings = file("files/editor-settings.json")

  workspace "report" {
    target    = resource.container.workstation
    directory = "/root"
  }
}

resource "external_website" "customer_info" {
  url = "https://share.hsforms.com/1OPKK5DW_T02Y0WE5TUuBZQ2relw"
}

# 1.0's `notes:` frontmatter block, which rendered the chapter intro panel.
resource "note" "getting_started" {
  file = "notes/getting_started.md"
}

resource "note" "build_something_real" {
  file = "notes/build_something_real.md"
}
