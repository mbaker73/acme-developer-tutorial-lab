# ─────────────────────────────────────────────────────────────────────────────
# Pages
#
# 1.0 had one challenge = one assignment.md with a task check attached at the
# track level. 2.0 separates the two: a page carries instructions, and
# `activities` is where tasks (and quizzes, unused here) attach to it.
# ─────────────────────────────────────────────────────────────────────────────

resource "page" "getting_started" {
  title = "Follow the Getting-Started Guide"
  file  = "instructions/getting_started.md"

  activities = {
    "register_customer" = resource.task.register_customer
  }
}

resource "page" "build_something_real" {
  title = "Build Something Real"
  file  = "instructions/build_something_real.md"

  activities = {
    "health_report" = resource.task.health_report
  }
}
