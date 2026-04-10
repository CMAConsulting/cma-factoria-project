---
name: quarkus-backend
description: Java Quarkus development guidelines for building cloud-native microservices with REST API, CDI, and OpenAPI
license: MIT
---

# Quarkus Backend Development

## Project Structure

```
apps/backend/command-service/
├── src/main/java/org/cma/factoria/[service]/
│   ├── endpoint/          # REST endpoints (JAX-RS/Reactive)
│   │   └── *Resource.java
│   └── service/           # Business logic
│       └── *Service.java
├── src/main/resources/
│   └── application.yaml   # Configuration
└── pom.xml
```

## Core Principles

- Use RESTEasy Reactive for REST APIs
- Follow package-by-feature pattern (not by layer)
- Model classes are auto-generated from OpenAPI specs
- Use Lombok only on entity classes (not on generated models)

## Development Commands

```bash
# Start in dev mode (hot reload)
cd apps/backend/command-service
mvn quarkus:dev

# Compile (generates models from OpenAPI)
mvn clean compile

# Build for production
mvn clean package

# Run tests
mvn test
```

## Configuration

### application.yaml
```yaml
quarkus:
  http:
    port: 8080
  smallrye-jwt:
    enabled: false  # Disable for dev
  jackson:
    serialization-inclusion: NON_NULL  # Exclude nulls
```

### Environment Variables
```bash
# Disable JWT for local dev
mvn quarkus:dev -Dquarkus.smallrye-jwt.enabled=false
```

## REST Endpoints Pattern

```java
package org.cma.factoria.commands.endpoint;

import jakarta.inject.Inject;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import org.cma.factoria.commands.service.CommandsService;

@Path("/api/commands")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class CommandsResource {

    @Inject
    CommandsService service;

    @GET
    public List<CommandResponse> list() {
        return service.listAll();
    }

    @POST
    public Response create(CommandRequest request) {
        // Validate required fields
        if (request.getCommand() == null || request.getCommand().isBlank()) {
            return Response.status(400).build();
        }
        var result = service.create(request);
        return Response.status(201).entity(result).build();
    }
}
```

## Validation

```java
import org.apache.commons.lang3.StringUtils;

// Using StringUtils for validation
if (StringUtils.isBlank(commandRequest.getCommand())) {
    throw new BadRequestException("Command is required");
}
```

## OpenAPI Integration

1. Define spec in `contracts/openapi/commands.yaml`
2. Run `mvn clean compile` to generate models
3. Models go to `target/generated-sources/openapi/src/gen/java/main/`

### Model Package
Generated models: `org.cma.factoria.commands.model.*`

## Common Issues

| Error | Solution |
|-------|----------|
| `cannot find symbol` | Run `mvn clean compile` to generate models |
| `incompatible types` | Use model classes, not entity classes |
| Null values in response | Set `quarkus.jackson.serialization-inclusion: NON_NULL` |

## Testing

```bash
# Test endpoint
curl http://localhost:8080/api/commands

# Create command
curl -X POST http://localhost:8080/api/commands \
  -H "Content-Type: application/json" \
  -d '{"command": "deploy", "payload": {"environment": "staging"}}'
```

## Key Dependencies (pom.xml)

```xml
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-resteasy-reactive</artifactId>
</dependency>
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-resteasy-reactive-jackson</artifactId>
</dependency>
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-smallrye-openapi</artifactId>
</dependency>
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-hibernate-validator</artifactId>
</dependency>
<dependency>
    <groupId>org.apache.commons</groupId>
    <artifactId>commons-lang3</artifactId>
</dependency>
```