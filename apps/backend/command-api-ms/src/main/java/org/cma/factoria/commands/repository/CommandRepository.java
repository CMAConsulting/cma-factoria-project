package org.cma.factoria.commands.repository;

import io.smallrye.mutiny.Uni;
import io.vertx.core.json.JsonObject;
import io.vertx.mutiny.pgclient.PgPool;
import io.vertx.mutiny.sqlclient.Row;
import io.vertx.mutiny.sqlclient.Tuple;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import lombok.Data;
import org.cma.factoria.commands.entity.CommandEntity;
import org.cma.factoria.commands.model.CommandResponse;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@ApplicationScoped
public class CommandRepository {

    @Inject
    PgPool client;

    public Uni<CommandEntity> insert(CommandEntity entity) {
        JsonObject payload  = entity.getPayload()  != null ? JsonObject.mapFrom(entity.getPayload())  : null;
        JsonObject metadata = entity.getMetadata() != null ? JsonObject.mapFrom(entity.getMetadata()) : null;

        return client.preparedQuery("SELECT * FROM sp_insert_command($1, $2, $3)")
                .execute(Tuple.of(entity.getCommand(), payload, metadata))
                .map(rows -> mapRowToEntity(rows.iterator().next()));
    }

    public Uni<CommandEntity> findById(UUID id) {
        return client.preparedQuery("SELECT * FROM sp_get_command($1)")
                .execute(Tuple.of(id))
                .map(rows -> {
                    var iter = rows.iterator();
                    return iter.hasNext() ? mapRowToEntityWithResult(iter.next()) : null;
                });
    }

    public Uni<CommandListResult> findAll(String status, String source, int limit, int offset) {
        return client.preparedQuery("SELECT * FROM sp_list_commands($1, $2, $3, $4)")
                .execute(Tuple.of(status, source, limit, offset))
                .map(rows -> {
                    CommandListResult result = new CommandListResult();
                    rows.forEach(row -> {
                        result.getItems().add(mapRowToEntity(row));
                        result.setTotal(row.getLong("total"));
                    });
                    return result;
                });
    }

    private CommandEntity mapRowToEntity(Row row) {
        return CommandEntity.builder()
                .id(row.getUUID("id"))
                .command(row.getString("command"))
                .status(parseStatus(row.getString("status")))
                .createdAt(row.getOffsetDateTime("created_at"))
                .completedAt(row.getOffsetDateTime("completed_at"))
                .build();
    }

    private CommandEntity mapRowToEntityWithResult(Row row) {
        return CommandEntity.builder()
                .id(row.getUUID("id"))
                .command(row.getString("command"))
                .status(parseStatus(row.getString("status")))
                .error(row.getString("error"))
                .createdAt(row.getOffsetDateTime("created_at"))
                .completedAt(row.getOffsetDateTime("completed_at"))
                .build();
    }

    private CommandResponse.StatusEnum parseStatus(String status) {
        if (status == null) return null;
        return CommandResponse.StatusEnum.valueOf(status.toUpperCase());
    }

    @Data
    public static class CommandListResult {
        private List<CommandEntity> items = new ArrayList<>();
        private long total;
    }
}
