package org.cma.factoria.commands.mapper;

import io.vertx.mutiny.sqlclient.Row;
import org.cma.factoria.commands.entity.CommandEntity;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class CommandMapperTest {

    private Row mockRow;

    @BeforeEach
    void setUp() {
        mockRow = Mockito.mock(Row.class);
    }

    @Test
    void fromRow_withValidData_mapsCorrectly() {
        UUID id = UUID.randomUUID();
        OffsetDateTime createdAt = OffsetDateTime.of(2024, 1, 15, 10, 30, 0, 0, ZoneOffset.UTC);
        OffsetDateTime completedAt = OffsetDateTime.of(2024, 1, 15, 11, 0, 0, 0, ZoneOffset.UTC);

        when(mockRow.getUUID("id")).thenReturn(id);
        when(mockRow.getString("command")).thenReturn("test-command");
        when(mockRow.getString("status")).thenReturn("COMPLETED");
        when(mockRow.getOffsetDateTime("created_at")).thenReturn(createdAt);
        when(mockRow.getOffsetDateTime("completed_at")).thenReturn(completedAt);

        CommandEntity entity = CommandMapper.fromRow(mockRow);

        assertEquals(id, entity.getId());
        assertEquals("test-command", entity.getCommand());
        assertEquals(CommandEntity.CommandStatus.COMPLETED, entity.getStatus());
        assertEquals(createdAt, entity.getCreatedAt());
        assertEquals(completedAt, entity.getCompletedAt());
        assertNull(entity.getError());
    }

    @Test
    void fromRow_withNullDates_returnsNullForDates() {
        UUID id = UUID.randomUUID();

        when(mockRow.getUUID("id")).thenReturn(id);
        when(mockRow.getString("command")).thenReturn("test-command");
        when(mockRow.getString("status")).thenReturn("PENDING");
        when(mockRow.getOffsetDateTime("created_at")).thenReturn(null);
        when(mockRow.getOffsetDateTime("completed_at")).thenReturn(null);

        CommandEntity entity = CommandMapper.fromRow(mockRow);

        assertEquals(id, entity.getId());
        assertNull(entity.getCreatedAt());
        assertNull(entity.getCompletedAt());
    }

    @Test
    void fromRow_withBCDate_returnsNullForInvalidDate() {
        UUID id = UUID.randomUUID();
        // Simula una fecha BC que Vert.x no puede parsear correctamente
        OffsetDateTime bcDate = OffsetDateTime.of(-4714, 11, 24, 0, 0, 0, 0, ZoneOffset.UTC);

        when(mockRow.getUUID("id")).thenReturn(id);
        when(mockRow.getString("command")).thenReturn("test-command");
        when(mockRow.getString("status")).thenReturn("PENDING");
        when(mockRow.getOffsetDateTime("created_at")).thenReturn(bcDate);
        when(mockRow.getOffsetDateTime("completed_at")).thenReturn(null);

        CommandEntity entity = CommandMapper.fromRow(mockRow);

        assertEquals(id, entity.getId());
        // La fecha BC debería retornar null, no la fecha inválida
        assertNull(entity.getCreatedAt());
    }

    @Test
    void fromRow_withPendingStatus_parsesCorrectly() {
        UUID id = UUID.randomUUID();
        OffsetDateTime createdAt = OffsetDateTime.now(ZoneOffset.UTC);

        when(mockRow.getUUID("id")).thenReturn(id);
        when(mockRow.getString("command")).thenReturn("start-service");
        when(mockRow.getString("status")).thenReturn("PENDING");
        when(mockRow.getOffsetDateTime("created_at")).thenReturn(createdAt);
        when(mockRow.getOffsetDateTime("completed_at")).thenReturn(null);

        CommandEntity entity = CommandMapper.fromRow(mockRow);

        assertEquals(CommandEntity.CommandStatus.PENDING, entity.getStatus());
        assertNull(entity.getCompletedAt());
    }

    @Test
    void fromRow_withFailedStatus_parsesCorrectly() {
        UUID id = UUID.randomUUID();
        OffsetDateTime createdAt = OffsetDateTime.now(ZoneOffset.UTC);

        when(mockRow.getUUID("id")).thenReturn(id);
        when(mockRow.getString("command")).thenReturn("deploy-app");
        when(mockRow.getString("status")).thenReturn("FAILED");
        when(mockRow.getOffsetDateTime("created_at")).thenReturn(createdAt);
        when(mockRow.getOffsetDateTime("completed_at")).thenReturn(null);

        CommandEntity entity = CommandMapper.fromRow(mockRow);

        assertEquals(CommandEntity.CommandStatus.FAILED, entity.getStatus());
    }
}
