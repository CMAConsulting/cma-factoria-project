package org.cma.factoria.settings.repository;

import io.smallrye.mutiny.Uni;
import org.cma.factoria.settings.model.GeneralSettings;
import org.cma.factoria.settings.model.ApiSettings;
import org.cma.factoria.settings.model.NotificationSettings;

import jakarta.enterprise.context.ApplicationScoped;
import java.sql.*;
import java.util.concurrent.CompletableFuture;

@ApplicationScoped
public class SettingsRepository {

    public Uni<GeneralSettings> getGeneralSettings() {
        return Uni.createFrom().completionStage(() -> {
            return CompletableFuture.supplyAsync(() -> {
                GeneralSettings result = new GeneralSettings();
                try (Connection conn = getConnection();
                     Statement stmt = conn.createStatement()) {
                    
                    ResultSet rs = stmt.executeQuery(
                        "SELECT application_name, environment, timezone FROM settings_general LIMIT 1");
                    if (rs.next()) {
                        result.setApplicationName(rs.getString("application_name"));
                        result.setEnvironment(
                            GeneralSettings.EnvironmentEnum.valueOf(
                                rs.getString("environment").toUpperCase()));
                        result.setTimezone(rs.getString("timezone"));
                    }
                } catch (Exception e) {
                    throw new RuntimeException("Error getting general settings: " + e.getMessage(), e);
                }
                return result;
            });
        });
    }

    public Uni<ApiSettings> getApiSettings() {
        return Uni.createFrom().completionStage(() -> {
            return CompletableFuture.supplyAsync(() -> {
                ApiSettings result = new ApiSettings();
                try (Connection conn = getConnection();
                     Statement stmt = conn.createStatement()) {
                    
                    ResultSet rs = stmt.executeQuery(
                        "SELECT api_base_url, api_timeout_ms, enable_api_caching FROM settings_api_config LIMIT 1");
                    if (rs.next()) {
                        result.setApiBaseUrl(java.net.URI.create(rs.getString("api_base_url")));
                        result.setApiTimeoutMs(rs.getInt("api_timeout_ms"));
                        result.setEnableApiCaching(rs.getBoolean("enable_api_caching"));
                    }
                } catch (Exception e) {
                    throw new RuntimeException("Error getting api settings: " + e.getMessage(), e);
                }
                return result;
            });
        });
    }

    public Uni<NotificationSettings> getNotificationSettings() {
        return Uni.createFrom().completionStage(() -> {
            return CompletableFuture.supplyAsync(() -> {
                NotificationSettings result = new NotificationSettings();
                try (Connection conn = getConnection();
                     CallableStatement stmt = conn.prepareCall("{ ? = CALL sp_get_settings_notifications()}")) {
                    
                    stmt.registerOutParameter(1, Types.OTHER);
                    stmt.execute();
                    
                    ResultSet rs = (ResultSet) stmt.getObject(1);
                    if (rs.next()) {
                        result.setEmailOnCommandCompletion(rs.getBoolean("email_on_command_completion"));
                        result.setPushOnError(rs.getBoolean("push_on_error"));
                        result.setWeeklySummaryEnabled(rs.getBoolean("weekly_summary_enabled"));
                        return result;
                    }
                } catch (Exception e) {
                    throw new RuntimeException("Error getting notification settings: " + e.getMessage(), e);
                }
                return result;
            });
        });
    }

    public Uni<Boolean> updateNotificationSettings(NotificationSettings settings) {
        return Uni.createFrom().completionStage(() -> {
            return CompletableFuture.supplyAsync(() -> {
                try (Connection conn = getConnection();
                     CallableStatement stmt = conn.prepareCall(
                         "{ ? = CALL sp_update_settings_notifications(?, ?, ?) }")) {
                    
                    stmt.registerOutParameter(1, Types.OTHER);
                    stmt.setBoolean(2, Boolean.TRUE.equals(settings.getEmailOnCommandCompletion()));
                    stmt.setBoolean(3, Boolean.TRUE.equals(settings.getPushOnError()));
                    stmt.setBoolean(4, Boolean.TRUE.equals(settings.getWeeklySummaryEnabled()));
                    
                    stmt.execute();
                    return true;
                } catch (Exception e) {
                    throw new RuntimeException("Error updating notification settings: " + e.getMessage(), e);
                }
            });
        });
    }

    private Connection getConnection() throws SQLException {
        try {
            String url = System.getenv("DB_JDBC_URL");
            if (url == null || url.isEmpty()) {
                url = "jdbc:postgresql://localhost:5432/settings_db";
            }
            String user = System.getenv("DB_USER");
            if (user == null || user.isEmpty()) {
                user = "postgres";
            }
            String password = System.getenv("DB_PASSWORD");
            if (password == null || password.isEmpty()) {
                password = "postgres";
            }
            return DriverManager.getConnection(url, user, password);
        } catch (SQLException e) {
            throw new RuntimeException("Failed to get database connection: " + e.getMessage(), e);
        }
    }
}