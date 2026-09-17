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

  # NOTE: 1.0's `tags:` (postgresql, devrel, rest-api, developer) were a
  # track.yml attribute. 2.0 moves tagging out of HCL entirely — it's set on
  # the lab's Details page in the web UI instead. Set there to match:
  # postgresql, devrel, rest-api, developer.

  # NOTE: 1.0 also had `skipping_enabled` (skipping allowed) at the track
  # level. The 2.0 `controls` block only exposes show_stop — there is no HCL
  # equivalent for skip. Per the focus-areas doc this is likely a Details-page
  # toggle too; set "allow skipping" there if the UI offers it.
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
      show_stop = true
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
