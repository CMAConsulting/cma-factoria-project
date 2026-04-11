-- SPDX-FileCopyrightText: 2026 CM&A Consulting
-- SPDX-License-Identifier: MIT

-- ---------------------------------------------------------
-- Stored Procedure: sp_get_dashboard_activity
-- ---------------------------------------------------------
-- Descripción:
--   Obtiene la actividad del dashboard con filtros opcionales.
--
-- Parámetros:
--   p_limit     INT     (default 100)
--   p_offset    INT     (default 0)
--   p_user_id   UUID    (nullable)
-- ---------------------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_dashboard_activity(
    p_limit INT DEFAULT 100,
    p_offset INT DEFAULT 0,
    p_user_id UUID DEFAULT NULL
) RETURNS TABLE (
    activity_id UUID,
    user_id UUID,
    activity_type VARCHAR(20),
    activity_timestamp TIMESTAMPTZ,
    payload JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id AS activity_id,
           a.user_id,
           a.type AS activity_type,
           a.timestamp AS activity_timestamp,
           a.payload
    FROM dashboard_activity AS a
    WHERE (p_user_id IS NULL OR a.user_id = p_user_id)
    ORDER BY a.timestamp DESC
    LIMIT p_limit OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;