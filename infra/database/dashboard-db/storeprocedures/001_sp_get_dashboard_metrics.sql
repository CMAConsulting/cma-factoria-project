CREATE OR REPLACE FUNCTION sp_get_dashboard_metrics()
RETURNS TABLE (
    id UUID,
    pending INT,
    processing INT,
    completed INT,
    failed INT,
    last_updated TIMESTAMPTZ
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY SELECT * FROM dashboard_metrics;
END; $$;