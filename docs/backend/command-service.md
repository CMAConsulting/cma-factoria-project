# Command Service Backend

## Descripción

Microservicio REST para ejecución remota de comandos en el sistema CMA Factoria.

## Ubicación

`apps/backend/command-service/`

## Stack Tecnológico

- **Framework**: Quarkus 3.6.4
- **Lenguaje**: Java 21
- **API**: RESTEasy Reactive
- **Generación**: OpenAPI Generator 7.4.0

## Endpoints

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `POST` | `/api/commands` | Crear comando (201) |
| `GET` | `/api/commands` | Listar comandos (200) |
| `GET` | `/api/commands/{id}` | Consultar estado (200) |
| `GET` | `/api/commands/{id}/result` | Obtener resultado (200) |

## Modelos de Datos

### CommandRequest

```json
{
  "command": "string",
  "payload": {
    "environment": "string",
    "version": "string"
  },
  "metadata": {
    "source": "string",
    "correlationId": "string"
  }
}
```

### CommandResponse

```json
{
  "id": "uuid",
  "status": "pending|processing|completed|failed",
  "command": "string",
  "payload": {},
  "metadata": {},
  "createdAt": "timestamp",
  "completedAt": "timestamp"
}
```

## Configuración

### Puerto

- **Desarrollo**: 8080
- **Configuración**: `application.yaml`

### Autenticación

JWT deshabilitado en desarrollo:
```bash
mvn quarkus:dev -Dquarkus.smallrye-jwt.enabled=false
```

## Desarrollo

### Instalar dependencias

```bash
cd apps/backend/command-service
mvn clean install
```

### Iniciar servidor

```bash
mvn quarkus:dev -Dquarkus.smallrye-jwt.enabled=false
```

### Compilar

```bash
mvn clean compile
```

## API Specification

Especificación OpenAPI: `contracts/openapi/commands.yaml`

## Pruebas

Ver `tests/commands-api.md`

## Notas

- Almacenamiento en memoria (ConcurrentHashMap)
- Los resultados están vacíos (no hay ejecución real de comandos)
- Validación de `command` requerido con StringUtils
- Exclusión de valores nulos en responses (`NON_NULL`)

## Dependencias Principales

- quarkus-resteasy-reactive
- quarkus-resteasy-reactive-jackson
- quarkus-smallrye-openapi
- quarkus-hibernate-validator
- commons-lang3
- jackson-databind-nullable
