CREATE OR REPLACE FUNCTION sp_insert_command(
    p_command  VARCHAR,
    p_payload  JSONB,
    p_metadata JSONB DEFAULT NULL
) RETURNS TABLE (
    id           UUID,
    command      VARCHAR,
    payload      JSONB,
    metadata     JSONB,
    status       VARCHAR,
    created_at   TIMESTAMPTZ,
    completed_at TIMESTAMPTZ
) LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO commands (command, payload, metadata, status)
    VALUES (p_command, p_payload, p_metadata, 'pending')
    RETURNING
        id,
        command,
        payload,
        metadata,
        status,
        created_at,
        completed_at
    INTO
        id,
        command,
        payload,
        metadata,
        status,
        created_at,
        completed_at;

    RETURN NEXT;
END;
$$;