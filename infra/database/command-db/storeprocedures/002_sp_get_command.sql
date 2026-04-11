CREATE OR REPLACE FUNCTION sp_get_command(
    p_id UUID
) RETURNS TABLE (
    id           UUID,
    command      VARCHAR,
    payload      JSONB,
    metadata     JSONB,
    status       VARCHAR,
    created_at   TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    result       JSONB,
    error        TEXT
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id,
        c.command,
        c.payload,
        c.metadata,
        c.status,
        c.created_at,
        c.completed_at,
        r.result,
        r.error
    FROM commands c
    LEFT JOIN command_results r ON r.command_id = c.id
    WHERE c.id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Command with id % not found', p_id
            USING ERRCODE = 'P0002';
    END IF;
END;
$$;