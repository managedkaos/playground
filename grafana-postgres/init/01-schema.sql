-- Time series tables for experimentation

CREATE TABLE cpu_usage (
    time        TIMESTAMPTZ NOT NULL,
    host        TEXT        NOT NULL,
    usage_pct   DOUBLE PRECISION
);

CREATE INDEX idx_cpu_usage_time ON cpu_usage (time DESC);
CREATE INDEX idx_cpu_usage_host ON cpu_usage (host, time DESC);

CREATE TABLE memory_usage (
    time        TIMESTAMPTZ NOT NULL,
    host        TEXT        NOT NULL,
    used_gb     DOUBLE PRECISION,
    total_gb    DOUBLE PRECISION
);

CREATE INDEX idx_memory_usage_time ON memory_usage (time DESC);
CREATE INDEX idx_memory_usage_host ON memory_usage (host, time DESC);

CREATE TABLE http_requests (
    time          TIMESTAMPTZ NOT NULL,
    endpoint      TEXT        NOT NULL,
    method        TEXT        NOT NULL,
    status_code   INTEGER,
    response_ms   DOUBLE PRECISION
);

CREATE INDEX idx_http_requests_time ON http_requests (time DESC);
CREATE INDEX idx_http_requests_endpoint ON http_requests (endpoint, time DESC);
