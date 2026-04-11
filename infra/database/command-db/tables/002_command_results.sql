CREATE TABLE IF NOT EXISTS command_results (
    command_id UUID PRIMARY KEY REFERENCES commands(id) ON DELETE CASCADE,
    result     JSONB NOT NULL,
    error      TEXT,
    completed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_command_results_completed_at
    ON command_results (completed_at DESC);