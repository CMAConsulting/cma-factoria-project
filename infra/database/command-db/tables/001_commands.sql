CREATE TABLE IF NOT EXISTS commands (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    command VARCHAR(100) NOT NULL,
    payload JSONB NOT NULL,
    metadata JSONB,
    status VARCHAR(20) NOT NULL CHECK (status IN ('pending','processing','completed','failed')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_commands_status ON commands (status);
CREATE INDEX IF NOT EXISTS idx_commands_created_at ON commands (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_commands_metadata ON commands USING GIN (metadata);