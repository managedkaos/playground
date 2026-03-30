# grafana-postgres

Grafana connected to PostgreSQL for visualizing time series data. Comes with seed data (CPU, memory, HTTP metrics) and a pre-built dashboard.

## Prerequisites

- Docker and Docker Compose

## Quick Start

```bash
cp .env.example .env
docker compose up -d
```

Wait ~15 seconds for the seed job to populate data, then open Grafana.

## Access

| Service    | URL                        | Credentials     |
|------------|----------------------------|-----------------|
| Grafana    | http://localhost:3000      | admin / admin   |
| PostgreSQL | localhost:5432             | grafana / grafana (db: metrics) |

A **Time Series Overview** dashboard is automatically provisioned with six panels:

- CPU Usage by Host
- Memory Usage by Host
- HTTP Request Rate (stacked by endpoint)
- Response Time Percentiles (p50/p95/p99)
- Error Rate (4xx + 5xx)
- Request Count by Status Code (donut chart)

## Data

Three tables are seeded with 24 hours of synthetic data at 1-minute (CPU/memory) and 10-second (HTTP) intervals:

| Table           | Description                              |
|-----------------|------------------------------------------|
| `cpu_usage`     | CPU percentage per host                  |
| `memory_usage`  | RAM used/total per host                  |
| `http_requests` | Endpoint, method, status code, latency   |

To re-seed with fresh data:

```bash
docker compose run --rm seed
```

## Writing Your Own Queries

In Grafana, go to **Explore** (compass icon) and use the PostgreSQL datasource. Example:

```sql
SELECT
  $__timeGroup(time, '5m') AS time,
  host,
  avg(usage_pct) AS cpu
FROM cpu_usage
WHERE $__timeFilter(time)
GROUP BY 1, host
ORDER BY 1
```

Key Grafana macros for PostgreSQL:
- `$__timeFilter(time)` — filters to the dashboard time range
- `$__timeGroup(time, '1m')` — buckets timestamps into intervals
- `$__interval` — auto-calculated interval based on the time range and panel width

## Stop / Clean Up

```bash
docker compose down -v
```
