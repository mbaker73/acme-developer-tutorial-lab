# ─────────────────────────────────────────────────────────────────────────────
# Acme Analytics sandbox
#
# Three containers on one network:
#   postgres    — the database of record (postgres:15)
#   api         — FastAPI app talking to postgres by name (python:3.11)
#   workstation — where the learner works (ubuntu:22.04)
#
# Ported from the 1.0 track's config.yml. In 1.0 the shared network and name
# resolution were implicit; in 2.0 the network is an explicit resource and
# every container joins it with an alias it can be reached by.
# ─────────────────────────────────────────────────────────────────────────────

resource "network" "acme" {
  subnet = "10.0.5.0/24"
}

# ─────────────────────────────────────────────
# Database
# ─────────────────────────────────────────────
resource "container" "postgres" {
  image {
    name = "postgres:15"
  }

  environment = {
    POSTGRES_DB       = "acmedb"
    POSTGRES_USER     = "acme"
    POSTGRES_PASSWORD = "acmepassword"
  }

  resources {
    cpu    = 500
    memory = 512
  }

  network {
    id      = resource.network.acme.meta.id
    aliases = ["postgres", "db"]
  }

  # 2.0 handles readiness at the platform level, so the api container is not
  # started until postgres actually accepts connections.
  health_check {
    timeout = "180s"

    exec {
      script = <<-EOF
      pg_isready -h 127.0.0.1 -U acme -d acmedb
      EOF
    }
  }
}

# ─────────────────────────────────────────────
# REST API
# ─────────────────────────────────────────────
resource "container" "api" {
  depends_on = [resource.container.postgres]

  image {
    name = "python:3.11"
  }

  # python:3.11 defaults to an interactive REPL, which exits immediately
  # without a TTY and takes the container with it. Hold it open instead.
  command = ["tail", "-f", "/dev/null"]

  # This is how the API finds Postgres — the connection details are injected
  # rather than hardcoded in the application, so the sandbox stays the
  # single source of truth.
  environment = {
    PGHOST     = "postgres"
    PGDATABASE = "acmedb"
    PGUSER     = "acme"
    PGPASSWORD = "acmepassword"
    API_PORT   = "8000"
  }

  labels = {
    "acme.component" = "api"
    "acme.tier"      = "backend"
  }

  resources {
    cpu    = 500
    memory = 512
  }

  network {
    id      = resource.network.acme.meta.id
    aliases = ["api"]
  }

  port {
    local = 8000
    host  = 8000
  }

  # NOTE: deliberately no health_check here.
  #
  # uvicorn is started by resource.exec.api_setup, and an exec only runs once
  # its target container is already healthy. A health check on /api/health
  # would therefore wait for a server that nothing has started yet, and the
  # sandbox would never come up. API readiness is gated downstream instead,
  # by the curl wait in scripts/exec/workstation_setup.sh.
}

# ─────────────────────────────────────────────
# Learner workstation
# ─────────────────────────────────────────────
resource "container" "workstation" {
  depends_on = [resource.container.api]

  image {
    name = "ubuntu:22.04"
  }

  command = ["tail", "-f", "/dev/null"]

  environment = {
    ACME_API = "http://api:8000"
  }

  resources {
    cpu    = 500
    memory = 512
  }

  network {
    id      = resource.network.acme.meta.id
    aliases = ["workstation"]
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Provisioning
#
# The 1.0 track used one setup-<container> script per container, run by the
# platform. 2.0 makes each one an explicit exec resource with its own target
# and ordering.
# ─────────────────────────────────────────────────────────────────────────────

resource "exec" "postgres_seed" {
  target  = resource.container.postgres
  script  = "scripts/exec/postgres_seed.sh"
  timeout = "300s"
}

resource "exec" "api_setup" {
  depends_on = [resource.exec.postgres_seed]

  target  = resource.container.api
  script  = "scripts/exec/api_setup.sh"
  timeout = "600s"
}

resource "exec" "workstation_setup" {
  depends_on = [resource.exec.api_setup]

  target  = resource.container.workstation
  script  = "scripts/exec/workstation_setup.sh"
  timeout = "600s"
}

# In 1.0 the report starter files were written by challenge 2's own
# setup-workstation script. 2.0 has no per-chapter setup lifecycle, so this
# runs up front as part of sandbox provisioning.
resource "exec" "report_starter" {
  depends_on = [resource.exec.workstation_setup]

  target  = resource.container.workstation
  script  = "scripts/exec/report_starter.sh"
  timeout = "120s"
}
