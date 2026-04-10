package org.cma.factoria.dashboard.service;

import jakarta.enterprise.context.ApplicationScoped;
import org.cma.factoria.dashboard.model.ActivityItem;
import org.cma.factoria.dashboard.model.DashboardMetrics;

import java.time.OffsetDateTime;
import java.util.List;

@ApplicationScoped
public class DashboardService {

    public DashboardMetrics getMetrics() {
        return DashboardMetrics.builder()
                .pending(12)
                .processing(5)
                .completed(148)
                .failed(3)
                .build();
    }

    public List<ActivityItem> getActivity() {
        return List.of(
                ActivityItem.builder()
                        .id("cmd-10001")
                        .timestamp(OffsetDateTime.parse("2026-04-10T10:00:00Z"))
                        .type(ActivityItem.TypeEnum.COMMAND_START)
                        .description("Command 'deploy-staging' started")
                        .userId("user-42")
                        .build(),
                ActivityItem.builder()
                        .id("cmd-10002")
                        .timestamp(OffsetDateTime.parse("2026-04-10T10:05:00Z"))
                        .type(ActivityItem.TypeEnum.COMMAND_COMPLETE)
                        .description("Command 'deploy-staging' completed successfully")
                        .userId("user-42")
                        .build(),
                ActivityItem.builder()
                        .id("cmd-10003")
                        .timestamp(OffsetDateTime.parse("2026-04-10T10:12:00Z"))
                        .type(ActivityItem.TypeEnum.COMMAND_START)
                        .description("Command 'run-tests' started")
                        .userId("user-17")
                        .build(),
                ActivityItem.builder()
                        .id("cmd-10004")
                        .timestamp(OffsetDateTime.parse("2026-04-10T10:15:00Z"))
                        .type(ActivityItem.TypeEnum.COMMAND_ERROR)
                        .description("Command 'run-tests' failed with exit code 1")
                        .userId("user-17")
                        .build(),
                ActivityItem.builder()
                        .id("ntf-10005")
                        .timestamp(OffsetDateTime.parse("2026-04-10T10:20:00Z"))
                        .type(ActivityItem.TypeEnum.NOTIFICATION)
                        .description("System health check completed - all services operational")
                        .build()
        );
    }
}
