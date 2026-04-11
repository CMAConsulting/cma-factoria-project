package org.cma.factoria.dashboard.repository;

import io.smallrye.mutiny.Uni;
import org.cma.factoria.dashboard.model.ActivityItem;

import jakarta.enterprise.context.ApplicationScoped;
import java.sql.*;
import java.util.*;
import java.util.concurrent.CompletableFuture;

@ApplicationScoped
public class DashboardRepository {

    public Uni<DashboardMetricsResult> getMetrics() {
        return Uni.createFrom().completionStage(() -> {
            return CompletableFuture.supplyAsync(() -> {
                DashboardMetricsResult result = new DashboardMetricsResult();
                try (Connection conn = getConnection();
                     CallableStatement stmt = conn.prepareCall(
                         "{ ? = CALL sp_get_dashboard_metrics() }")) {
                    
                    stmt.registerOutParameter(1, Types.OTHER);
                    stmt.execute();
                    
                    ResultSet rs = (ResultSet) stmt.getObject(1);
                    if (rs.next()) {
                        result.setId(rs.getObject("id", UUID.class));
                        result.setPending(rs.getInt("pending"));
                        result.setProcessing(rs.getInt("processing"));
                        result.setCompleted(rs.getInt("completed"));
                        result.setFailed(rs.getInt("failed"));
                        result.setLastUpdated(rs.getTimestamp("last_updated"));
                    }
                } catch (Exception e) {
                    throw new RuntimeException("Error getting metrics: " + e.getMessage(), e);
                }
                return result;
            });
        });
    }

    public Uni<List<ActivityItem>> getActivity(int limit, int offset, UUID userId) {
        return Uni.createFrom().completionStage(() -> {
            return CompletableFuture.supplyAsync(() -> {
                List<ActivityItem> items = new ArrayList<>();
                try (Connection conn = getConnection();
                     CallableStatement stmt = conn.prepareCall(
                         "{ ? = CALL sp_get_dashboard_activity(?, ?, ?) }")) {
                    
                    stmt.registerOutParameter(1, Types.OTHER);
                    stmt.setInt(2, limit);
                    stmt.setInt(3, offset);
                    stmt.setObject(4, userId);
                    
                    stmt.execute();
                    
                    ResultSet rs = (ResultSet) stmt.getObject(1);
                    while (rs.next()) {
                        ActivityItem item = ActivityItem.builder()
                            .id(rs.getObject("activity_id", UUID.class).toString())
                            .timestamp(rs.getTimestamp("activity_timestamp").toLocalDateTime()
                                .atOffset(java.time.ZoneOffset.UTC))
                            .type(ActivityItem.TypeEnum.valueOf(rs.getString("activity_type").toUpperCase()))
                            .build();
                        if (rs.getObject("user_id") != null) {
                            item.setUserId(rs.getObject("user_id", UUID.class).toString());
                        }
                        items.add(item);
                    }
                } catch (Exception e) {
                    throw new RuntimeException("Error getting activity: " + e.getMessage(), e);
                }
                return items;
            });
        });
    }

    private Connection getConnection() throws SQLException {
        try {
            String url = System.getenv("DB_JDBC_URL");
            if (url == null || url.isEmpty()) {
                url = "jdbc:postgresql://localhost:5432/dashboard_db";
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

    public static class DashboardMetricsResult {
        private UUID id;
        private int pending;
        private int processing;
        private int completed;
        private int failed;
        private Timestamp lastUpdated;

        public UUID getId() { return id; }
        public void setId(UUID id) { this.id = id; }
        public int getPending() { return pending; }
        public void setPending(int pending) { this.pending = pending; }
        public int getProcessing() { return processing; }
        public void setProcessing(int processing) { this.processing = processing; }
        public int getCompleted() { return completed; }
        public void setCompleted(int completed) { this.completed = completed; }
        public int getFailed() { return failed; }
        public void setFailed(int failed) { this.failed = failed; }
        public Timestamp getLastUpdated() { return lastUpdated; }
        public void setLastUpdated(Timestamp lastUpdated) { this.lastUpdated = lastUpdated; }
    }
}