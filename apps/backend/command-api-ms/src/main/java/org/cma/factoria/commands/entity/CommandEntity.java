package org.cma.factoria.commands.entity;

import java.time.OffsetDateTime;
import java.util.UUID;

public class CommandEntity {
    private UUID id;
    private String command;
    private CommandStatus status;
    private OffsetDateTime createdAt;
    private OffsetDateTime completedAt;
    private String error;

    public CommandEntity() {}

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public String getCommand() { return command; }
    public void setCommand(String command) { this.command = command; }

    public CommandStatus getStatus() { return status; }
    public void setStatus(CommandStatus status) { this.status = status; }

    public OffsetDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(OffsetDateTime createdAt) { this.createdAt = createdAt; }

    public OffsetDateTime getCompletedAt() { return completedAt; }
    public void setCompletedAt(OffsetDateTime completedAt) { this.completedAt = completedAt; }

    public String getError() { return error; }
    public void setError(String error) { this.error = error; }

    public enum CommandStatus {
        PENDING, PROCESSING, COMPLETED, FAILED
    }
}