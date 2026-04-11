CREATE TABLE IF NOT EXISTS settings_general (
    id SERIAL PRIMARY KEY,
    application_name VARCHAR(100) NOT NULL CHECK (application_name <> ''),
    environment VARCHAR(20) NOT NULL CHECK (environment IN ('development','staging','production')),
    timezone VARCHAR(50) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_settings_general_environment ON settings_general (environment);

INSERT INTO settings_general (id, application_name, environment, timezone)
VALUES (1, 'CMA Factoria', 'development', 'Europe/Madrid')
ON CONFLICT DO NOTHING;