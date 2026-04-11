CREATE OR REPLACE FUNCTION sp_update_settings_notifications(
    p_email_on_command_completion BOOLEAN,
    p_push_on_error BOOLEAN,
    p_weekly_summary_enabled BOOLEAN
) RETURNS TABLE (
    id UUID,
    email_on_command_completion BOOLEAN,
    push_on_error BOOLEAN,
    weekly_summary_enabled BOOLEAN,
    created_at TIMESTAMPTZ
) LANGUAGE plpgsql AS $$
BEGIN
    UPDATE settings_notifications
    SET
        email_on_command_completion = p_email_on_command_completion,
        push_on_error = p_push_on_error,
        weekly_summary_enabled = p_weekly_summary_enabled
    WHERE id = 1;

    RETURN QUERY SELECT * FROM settings_notifications;
END; $$;