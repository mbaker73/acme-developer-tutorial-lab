# ─────────────────────────────────────────────────────────────────────────────
# Layouts
#
# 1.0 set this globally: default_layout AssignmentLeft with a 30% sidebar.
# 2.0 makes layout a resource, and lets a chapter override the lab default —
# which is what chapter 2 does to bring in the editor.
# ─────────────────────────────────────────────────────────────────────────────

# Chapter 1: read on the left, work on the right.
resource "layout" "getting_started" {
  column {
    width = 30
    instructions {}
  }

  column {
    width = 70

    tab "terminal" {
      active = true
      target = resource.terminal.workstation
    }

    tab "api_docs" {
      target = resource.service.api_docs
    }

    tab "guide" {
      target = resource.note.getting_started
    }

    tab "customer_info" {
      target = resource.external_website.customer_info
    }
  }
}

# Chapter 2: same shape, plus the editor the integration is written in.
resource "layout" "build_something_real" {
  column {
    width = 30
    instructions {}
  }

  column {
    width = 70

    tab "editor" {
      active = true
      target = resource.editor.report
    }

    tab "terminal" {
      target = resource.terminal.workstation
    }

    tab "api_docs" {
      target = resource.service.api_docs
    }

    tab "guide" {
      target = resource.note.build_something_real
    }

    tab "customer_info" {
      target = resource.external_website.customer_info
    }
  }
}
