package org.cma.factoria.commands.service;

import jakarta.enterprise.context.ApplicationScoped;
import org.cma.factoria.commands.model.*;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

@ApplicationScoped
public class CommandService {

    // Static map para persistencia en modo dev
    private static final Map<UUID, CommandResponse> commands = new ConcurrentHashMap<>();

    public CommandResponse executeCommand(CommandRequest request) {
        UUID id = UUID.randomUUID();
        
        CommandResponse response = CommandResponse.builder()
            .id(id)
            .status(CommandResponse.StatusEnum.PENDING)
            .command(request.getCommand())
            .payload(request.getPayload())
            .metadata(request.getMetadata())
            .createdAt(java.time.OffsetDateTime.now())
            .build();
        
        commands.put(id, response);
        
        return response;
    }

    public CommandListResponse listCommands(String status, String source, Integer limit, Integer offset) {
        limit = limit != null ? limit : 20;
        offset = offset != null ? offset : 0;
        
        List<CommandResponse> filtered = commands.values().stream()
                .sorted(Comparator.comparing(CommandResponse::getCreatedAt).reversed())
                .toList();
        
        List<CommandResponse> page = filtered.stream()
                .skip(offset)
                .limit(limit)
                .collect(Collectors.toList());
        
        return CommandListResponse.builder()
            .items(page)
            .total(filtered.size())
            .limit(limit)
            .offset(offset)
            .build();
    }

    public CommandResponse getCommand(String id) {
        try {
            return commands.get(UUID.fromString(id));
        } catch (Exception e) {
            return null;
        }
    }

    public CommandResult getCommandResult(String id) {
        try {
            UUID uuid = UUID.fromString(id);
            CommandResponse response = commands.get(uuid);
            
            if (response == null) {
                return null;
            }
            
            // Si el comando existe pero no tiene resultado, retornamos un resultado vacío con el estado actual
            return CommandResult.builder()
                .id(response.getId())
                .status(response.getStatus() != null ? CommandResult.StatusEnum.valueOf(response.getStatus().name()) : null)
                .completedAt(response.getCompletedAt())
                .build();
        } catch (Exception e) {
            return null;
        }
    }
}