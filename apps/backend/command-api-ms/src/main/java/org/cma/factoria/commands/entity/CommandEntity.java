package org.cma.factoria.commands.entity;

import lombok.*;
import org.cma.factoria.commands.model.*;
import java.time.OffsetDateTime;
import java.util.UUID;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CommandEntity {
    private UUID id;
    private CommandResponse.StatusEnum status;
    private String command;
    private CommandPayload payload;
    private CommandMetadata metadata;
    private CommandResultData result;
    private String error;
    private OffsetDateTime createdAt;
    private OffsetDateTime completedAt;
}