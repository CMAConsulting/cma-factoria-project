package org.cma.factoria.commands.mapper;

import io.vertx.mutiny.sqlclient.Row;
import org.cma.factoria.commands.entity.CommandEntity;
import org.cma.factoria.commands.entity.CommandEntity.CommandStatus;
import org.jboss.logging.Logger;

import java.time.OffsetDateTime;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;

public class CommandMapper {

    private static final Logger LOG = Logger.getLogger(CommandMapper.class);

    public static CommandEntity fromRow(Row row) {
        CommandEntity e = new CommandEntity();
        e.setId(row.getUUID("id"));
        e.setCommand(row.getString("command"));
        e.setStatus(parseStatus(row.getString("status")));
        e.setCreatedAt(safeParseOffsetDateTime(row, "created_at"));
        e.setCompletedAt(safeParseOffsetDateTime(row, "completed_at"));
        return e;
    }

    /**
     * Parsea OffsetDateTime de forma segura, capturando fechas BC o valores inválidos.
     * PostgreSQL puede retornar '4714-11-24 00:00:00 BC' para -infinity o NULLs mal interpretados.
     */
    private static OffsetDateTime safeParseOffsetDateTime(Row row, String column) {
        try {
            OffsetDateTime value = row.getOffsetDateTime(column);
            if (value == null) {
                return null;
            }
            // Verificar si es una fecha inválida (antes de 0001-01-01)
            if (value.getYear() < 1) {
                LOG.warnv("Fecha inválida detectada en columna {0}: {1}, returning null", 
                    column, value);
                return null;
            }
            return value;
        } catch (DateTimeParseException e) {
            LOG.warnv("Error parseando {0}: {1}, returning null", column, e.getMessage());
            return null;
        } catch (Exception e) {
            LOG.warnv("Error inesperado parseando {0}: {1}, returning null", 
                column, e.getMessage());
            return null;
        }
    }

    public static List<CommandEntity> fromRows(Iterable<Row> rows) {
        List<CommandEntity> list = new ArrayList<>();
        for (Row row : rows) {
            list.add(fromRow(row));
        }
        return list;
    }

    private static CommandStatus parseStatus(String status) {
        if (status == null) return null;
        return CommandStatus.valueOf(status.toUpperCase());
    }
}