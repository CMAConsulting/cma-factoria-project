package org.cma.factoria.commands.repository;

import io.smallrye.mutiny.Uni;
import io.vertx.mutiny.pgclient.PgPool;
import io.vertx.mutiny.sqlclient.Tuple;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import org.cma.factoria.commands.entity.CommandEntity;
import org.cma.factoria.commands.mapper.CommandMapper;

import java.util.List;
import java.util.UUID;

@ApplicationScoped
public class CommandRepository {

    @Inject
    PgPool client;

    public Uni<CommandEntity> insert(String command) {
        return client.preparedQuery("SELECT * FROM sp_insert_command($1, NULL::jsonb, NULL::jsonb)")
            .execute(Tuple.of(command))
            .map(rows -> CommandMapper.fromRow(rows.iterator().next()));
    }

    public Uni<CommandEntity> findById(UUID id) {
        return client.preparedQuery("SELECT * FROM sp_get_command($1)")
            .execute(Tuple.of(id))
            .map(rows -> rows.iterator().hasNext() ? CommandMapper.fromRow(rows.iterator().next()) : null);
    }

    public Uni<List<CommandEntity>> findAll(String status, int limit, int offset) {
        return client.preparedQuery("SELECT * FROM sp_list_commands($1, $2, $3, $4)")
            .execute(Tuple.of(status, null, limit, offset))
            .map(rows -> CommandMapper.fromRows(rows));
    }

    public Uni<Long> count(String status) {
        return client.preparedQuery("SELECT * FROM sp_count_commands($1)")
            .execute(Tuple.of(status != null && !status.isBlank() ? status : null))
            .map(rows -> rows.iterator().next().getLong("count"));
    }
}