CREATE OR REPLACE FUNCTION sp_count_commands(
    p_status VARCHAR DEFAULT NULL
) RETURNS TABLE (count BIGINT) LANGUAGE plpgsql AS $$
BEGIN
    IF p_status IS NULL OR p_status = '' THEN
        RETURN QUERY SELECT COUNT(*)::BIGINT FROM commands;
    ELSE
        RETURN QUERY SELECT COUNT(*)::BIGINT FROM commands WHERE status = p_status;
    END IF;
END;
$$;