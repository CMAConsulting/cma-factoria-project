package org.cma.factoria.commands.endpoint;

import jakarta.inject.Inject;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import org.apache.commons.lang3.StringUtils;
import org.cma.factoria.commands.model.*;
import org.cma.factoria.commands.service.CommandService;

@Path("/api/commands")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class CommandEndpoint {

    @Inject
    CommandService commandService;

    @POST
    public Response executeCommand(CommandRequest request) {
        if (request == null || StringUtils.isBlank(request.getCommand())) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity(org.cma.factoria.commands.model.Error.builder()
                            .error("INVALID_REQUEST")
                            .message("El campo 'command' es requerido")
                            .build())
                    .build();
        }
        CommandResponse response = commandService.executeCommand(request);
        return Response.status(Response.Status.CREATED).entity(response).build();
    }

    @GET
    public Response listCommands(
            @QueryParam("status") String status,
            @QueryParam("source") String source,
            @QueryParam("limit") Integer limit,
            @QueryParam("offset") Integer offset) {
        CommandListResponse response = commandService.listCommands(status, source, limit, offset);
        return Response.ok(response).build();
    }

    @GET
    @Path("/{id}")
    public Response getCommand(@PathParam("id") String id) {
        CommandResponse response = commandService.getCommand(id);
        if (response == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }
        return Response.ok(response).build();
    }

    @GET
    @Path("/{id}/result")
    public Response getCommandResult(@PathParam("id") String id) {
        CommandResult result = commandService.getCommandResult(id);
        if (result == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }
        return Response.ok(result).build();
    }
}
