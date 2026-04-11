CREATE TABLE IF NOT EXISTS dashboard_activity (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    activity_id VARCHAR(50) NOT NULL,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    type VARCHAR(50) NOT NULL CHECK (type IN ('command-start', 'command-complete', 'command-error', 'notification')),
    description TEXT NOT NULL,
    user_id VARCHAR(50),
    metadata JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_activity_user_id
    ON dashboard_activity (user_id);

CREATE INDEX IF NOT EXISTS idx_activity_timestamp
    ON dashboard_activity (timestamp DESC);

CREATE INDEX IF NOT EXISTS idx_activity_type
    ON dashboard_activity (type);