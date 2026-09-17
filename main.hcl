# ─────────────────────────────────────────────────────────────────────────────
# Acme Analytics API: Developer Getting-Started Guide (2.0 port)
#
# Ported from jparton-challenge/acme-developer-tutorial. Same two challenges
# (now chapters/pages), same three-container sandbox, same tasks. See the
# NOTE comments throughout for what 2.0 forced to change.
# ─────────────────────────────────────────────────────────────────────────────

resource "lab" "acme_developer_tutorial" {
  title       = "Acme Analytics API: Developer Getting-Started Guide"
  description = <<-EOF
  This is Acme Corp's developer getting-started experience. You'll work against a live PostgreSQL-backed REST API — making real calls, exploring real data, and building a working integration from scratch.

  No setup, no prerequisites, no environment configuration. Open a terminal and start building. This is what developer content should feel like.
  EOF

  icon = "assets/acme-corp.png"

  # NOTE: 1.0's `tags:` (postgresql, devrel, rest-api, developer) carry over
  # unchanged — tagging is still a flat list in 2.0.
  tags = ["postgresql", "devrel", "rest-api", "developer"]

  settings {
    timelimit {
      duration   = "30m"
      show_timer = true
    }

    idle {
      enabled = true
      timeout = "5m"
    }

    controls {
      show_stop_button = true
      allow_skip       = true
    }

    theme = "modern-dark"
  }

  layout = resource.layout.getting_started

  content {
    chapter "getting_started" {
      title = "Follow the Getting-Started Guide"

      page "getting_started" {
        title     = "Follow the Getting-Started Guide"
        reference = resource.page.getting_started
      }
    }

    chapter "build_something_real" {
      title  = "Build Something Real"
      layout = resource.layout.build_something_real

      page "build_something_real" {
        title     = "Build Something Real"
        reference = resource.page.build_something_real
      }
    }
  }
}
