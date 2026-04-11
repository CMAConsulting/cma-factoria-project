CREATE OR REPLACE FUNCTION sp_list_commands(
    p_status VARCHAR DEFAULT NULL,
    p_source VARCHAR DEFAULT NULL,
    p_limit  INT      DEFAULT 20,
    p_offset INT      DEFAULT 0
) RETURNS TABLE (
    id           UUID,
    command      VARCHAR,
    payload      JSONB,
    metadata     JSONB,
    status       VARCHAR,
    created_at   TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    total        BIGINT
) LANGUAGE plpgsql AS $$
DECLARE
    v_total BIGINT;
BEGIN
    SELECT COUNT(*) INTO v_total
    FROM commands c
    WHERE (p_status IS NULL OR c.status = p_status)
      AND (p_source IS NULL OR c.metadata->'source' = p_source);

    RETURN QUERY
    SELECT
        c.id,
        c.command,
        c.payload,
        c.metadata,
        c.status,
        c.created_at,
        c.completed_at,
        v_total AS total
    FROM commands c
    WHERE (p_status IS NULL OR c.status = p_status)
      AND (p_source IS NULL OR c.metadata->'source' = p_source)
    ORDER BY c.created_at DESC
    LIMIT p_limit OFFSET p_offset;
END;
$$;