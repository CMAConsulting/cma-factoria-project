CREATE OR REPLACE FUNCTION sp_get_settings_notifications()
RETURNS TABLE (
    id UUID,
    email_on_command_completion BOOLEAN,
    push_on_error BOOLEAN,
    weekly_summary_enabled BOOLEAN,
    created_at TIMESTAMPTZ
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY SELECT * FROM settings_notifications;
END; $$;