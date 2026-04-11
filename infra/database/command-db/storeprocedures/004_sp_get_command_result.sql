CREATE OR REPLACE FUNCTION sp_get_command_result(
    p_id UUID
) RETURNS TABLE (
    id UUID,
    status VARCHAR,
    result JSONB,
    error TEXT,
    completed_at TIMESTAMPTZ
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id,
        c.status,
        r.result,
        r.error,
        r.completed_at
    FROM commands c
    JOIN command_results r ON r.command_id = c.id
    WHERE c.id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Result for command % not found', p_id
            USING ERRCODE = 'P0002';
    END IF;
END;
$$;