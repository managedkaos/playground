#!/usr/bin/env bash
set -euo pipefail

export PGPASSWORD="$POSTGRES_PASSWORD"
HOST="postgres"
DB="$POSTGRES_DB"
USER="$POSTGRES_USER"

echo "Seeding time series data (last 24 hours)..."

psql -h "$HOST" -U "$USER" -d "$DB" <<'SQL'

-- Generate CPU usage: 1-minute intervals, 3 hosts, last 24 hours
INSERT INTO cpu_usage (time, host, usage_pct)
SELECT
    ts,
    host,
    GREATEST(0, LEAST(100,
        40 + 20 * sin(extract(epoch FROM ts) / 3600)
        + 10 * sin(extract(epoch FROM ts) / 600)
        + (random() - 0.5) * 15
        + CASE host WHEN 'web-1' THEN 0 WHEN 'web-2' THEN 5 ELSE 10 END
    ))
FROM
    generate_series(
        now() - interval '24 hours',
        now(),
        interval '1 minute'
    ) AS ts
CROSS JOIN (VALUES ('web-1'), ('web-2'), ('db-1')) AS hosts(host);

-- Generate memory usage: 1-minute intervals, 3 hosts
INSERT INTO memory_usage (time, host, used_gb, total_gb)
SELECT
    ts,
    host,
    GREATEST(0.5, LEAST(total_gb,
        total_gb * (0.4 + 0.2 * sin(extract(epoch FROM ts) / 7200))
        + (random() - 0.5) * 0.5
    )),
    total_gb
FROM
    generate_series(
        now() - interval '24 hours',
        now(),
        interval '1 minute'
    ) AS ts
CROSS JOIN (VALUES ('web-1', 8.0), ('web-2', 8.0), ('db-1', 16.0)) AS hosts(host, total_gb);

-- Generate HTTP requests: random intervals, multiple endpoints
INSERT INTO http_requests (time, endpoint, method, status_code, response_ms)
SELECT
    ts + (random() * interval '1 minute'),
    endpoint,
    method,
    CASE
        WHEN random() < 0.90 THEN 200
        WHEN random() < 0.60 THEN 404
        WHEN random() < 0.70 THEN 500
        ELSE 503
    END,
    GREATEST(5, base_ms + (random() - 0.3) * base_ms + 50 * sin(extract(epoch FROM ts) / 1800))
FROM
    generate_series(
        now() - interval '24 hours',
        now(),
        interval '10 seconds'
    ) AS ts
CROSS JOIN (VALUES
    ('/api/users',    'GET',  45),
    ('/api/orders',   'GET',  80),
    ('/api/orders',   'POST', 120),
    ('/api/health',   'GET',  5),
    ('/api/search',   'GET',  200)
) AS endpoints(endpoint, method, base_ms);

SQL

echo "Done. Rows inserted:"
psql -h "$HOST" -U "$USER" -d "$DB" -c "
  SELECT 'cpu_usage' AS table_name, count(*) FROM cpu_usage
  UNION ALL
  SELECT 'memory_usage', count(*) FROM memory_usage
  UNION ALL
  SELECT 'http_requests', count(*) FROM http_requests;
"
