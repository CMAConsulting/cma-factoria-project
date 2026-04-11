CREATE TABLE IF NOT EXISTS dashboard_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pending INT NOT NULL DEFAULT 0 CHECK (pending >= 0),
    processing INT NOT NULL DEFAULT 0 CHECK (processing >= 0),
    completed INT NOT NULL DEFAULT 0 CHECK (completed >= 0),
    failed INT NOT NULL DEFAULT 0 CHECK (failed >= 0),
    last_updated TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_dashboard_metrics_last_updated
    ON dashboard_metrics (last_updated DESC);

INSERT INTO dashboard_metrics (id, pending, processing, completed, failed)
VALUES (gen_random_uuid(), 0, 0, 0, 0)
ON CONFLICT DO NOTHING;