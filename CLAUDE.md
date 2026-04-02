# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a playground repository for experimenting with different technologies. Each mini-project lives in its own subdirectory and is self-contained. The primary framework for running projects is **Docker Compose**, though some projects may use other tools.

Projects are named after the technologies they demonstrate, e.g.:

- `grafana-postgres` — Grafana connected to a PostgreSQL database
- `django` — A basic Django web app
- `kafka-spark` — Kafka ingestion with Spark processing

## Repository Structure

```text
/
├── CLAUDE.md
├── README.md
├── <project-name>/
│   ├── docker-compose.yml       # Required for Docker-based projects
│   ├── README.md                # What the project does and how to run it
│   ├── .env.example             # Example env vars (never commit real secrets)
│   └── ...                      # Project-specific files (Dockerfiles, configs, etc.)
└── <another-project>/
    └── ...
```

## Conventions

### Every project should have

- A `README.md` explaining: what it demonstrates, prerequisites, and how to start/stop it
- A `.env.example` if the project uses environment variables
- A way to fully start with a single command (ideally `docker compose up`)
- A way to fully stop and clean up (ideally `docker compose down -v`)
- A `Makefile` that allows the user to easily manage operations nfor the project.

Use the following as a guide for creating the Makefile.  Note that the following text may not be properly formatted for a Makefile, specifically hard-coded tabs may be absent.  Please use tabs appropriately in any Makefiels you create.

```makefile
all: build up logs

init:
 cp .env.example .env

build:
 docker compose build

up:
 docker compose up --detach

down:
 -docker compose down

logs:
 -docker compose logs -f

status:
 -docker compose ps

seed:
 docker compose run --rm seed

clean:
 -docker compose down -v --remove-orphans

.PHONY: all init build up down logs status seed clean
```

### Docker Compose projects

- Use named volumes rather than bind mounts for data persistence where possible
- Prefer official images from Docker Hub; pin image tags (e.g., `postgres:16`) rather than using `latest`
- Expose ports only as needed; document them in the project README
- Use `.env` files (via `env_file:` or variable substitution) to manage configuration

### Naming

- Directory names use lowercase kebab-case
- Multi-technology projects are named `primary-secondary` (e.g., `fastapi-redis`)

## Creating a New Project

When asked to create a new project, follow these steps:

1. **Create the project directory** using the appropriate kebab-case name
2. **Write `docker-compose.yml`** as the primary entrypoint
3. **Add a `README.md`** that includes:
   - One-line description of what the project demonstrates
   - Prerequisites (Docker, Docker Compose, etc.)
   - How to start: `docker compose up -d`
   - How to access the service(s) (URLs, ports, default credentials)
   - How to stop/clean up: `docker compose down -v`
4. **Add `.env.example`** if environment variables are needed
5. **Add any supporting files** (Makefiles, Dockerfiles, config files, seed data, scripts)

## Environment

- Make, Docker, and Docker Compose are assumed to be available
- Bash and Python may be used for helper scripts or application code
- No global build, lint, or test commands — check each subdirectory for its own setup
