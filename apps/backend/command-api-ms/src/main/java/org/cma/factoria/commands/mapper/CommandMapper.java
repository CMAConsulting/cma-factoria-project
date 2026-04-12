package org.cma.factoria.commands.mapper;

import io.vertx.mutiny.sqlclient.Row;
import org.cma.factoria.commands.entity.CommandEntity;
import org.cma.factoria.commands.entity.CommandEntity.CommandStatus;

import java.util.ArrayList;
import java.util.List;

public class CommandMapper {

    public static CommandEntity fromRow(Row row) {
        CommandEntity e = new CommandEntity();
        e.setId(row.getUUID("id"));
        e.setCommand(row.getString("command"));
        e.setStatus(parseStatus(row.getString("status")));
        e.setCreatedAt(row.getOffsetDateTime("created_at"));
        e.setCompletedAt(row.getOffsetDateTime("completed_at"));
        return e;
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