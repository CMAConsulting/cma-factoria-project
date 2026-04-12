package org.cma.factoria.commands.service;

import io.smallrye.mutiny.Uni;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import org.cma.factoria.commands.entity.CommandEntity;
import org.cma.factoria.commands.model.*;
import org.cma.factoria.commands.repository.CommandRepository;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

@ApplicationScoped
public class CommandService {

    @Inject
    CommandRepository repository;

    public Uni<CommandResponse> executeCommand(CommandRequest request) {
        String command = request.getCommand();
        
        return repository.insert(command)
            .map(this::entityToResponse);
    }

    public Uni<CommandListResponse> listCommands(String status, String source, Integer limit, Integer offset) {
        int lim = limit != null ? limit : 20;
        int off = offset != null ? offset : 0;
        
        return repository.findAll(status, lim, off)
            .map(list -> {
                CommandListResponse response = new CommandListResponse();
                response.setItems(list.stream().map(this::entityToResponse).toList());
                response.setTotal(list.size());
                response.setLimit(lim);
                response.setOffset(off);
                return response;
            });
    }

    public Uni<CommandResponse> getCommand(String id) {
        try {
            UUID uuid = UUID.fromString(id);
            return repository.findById(uuid)
                .map(entity -> entity != null ? entityToResponse(entity) : null);
        } catch (Exception e) {
            return Uni.createFrom().nullItem();
        }
    }

    public Uni<CommandResult> getCommandResult(String id) {
        try {
            UUID uuid = UUID.fromString(id);
            return repository.findById(uuid)
                .map(entity -> entity != null ? entityToResult(entity) : null);
        } catch (Exception e) {
            return Uni.createFrom().nullItem();
        }
    }

    private CommandResponse entityToResponse(CommandEntity entity) {
        CommandResponse response = new CommandResponse();
        response.setId(entity.getId());
        response.setStatus(CommandResponse.StatusEnum.fromValue(entity.getStatus().toString()));
        response.setCommand(entity.getCommand());
        response.setCreatedAt(entity.getCreatedAt());
        response.setCompletedAt(entity.getCompletedAt());
        return response;
    }

    private CommandResult entityToResult(CommandEntity entity) {
        CommandResult result = new CommandResult();
        result.setId(entity.getId());
        if (entity.getStatus() != null) {
            result.setStatus(CommandResult.StatusEnum.fromValue(entity.getStatus().toString()));
        }
        result.setCompletedAt(entity.getCompletedAt());
        return result;
    }
}