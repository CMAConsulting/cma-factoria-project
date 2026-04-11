CREATE TABLE IF NOT EXISTS settings_api_config (
    id SERIAL PRIMARY KEY,
    api_base_url VARCHAR(255) NOT NULL CHECK (api_base_url <> ''),
    api_timeout_millis INT NOT NULL CHECK (api_timeout_millis BETWEEN 1000 AND 120000),
    enable_api_caching BOOLEAN NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_settings_api_config_base_url
    ON settings_api_config (api_base_url);

INSERT INTO settings_api_config (id, api_base_url, api_timeout_millis, enable_api_caching)
VALUES (1, 'http://localhost:8080', 30000, TRUE)
ON CONFLICT DO NOTHING;