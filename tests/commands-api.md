# Pruebas - Command API

## Servicio

- **Ubicación**: `apps/backend/command-service/`
- **Puerto**: 3000
- **Base URL**: `http://localhost:3000/api`

## Endpoints Probados

### 1. POST /api/commands - Enviar comando

**Propósito**: Crear un nuevo comando para ejecución asíncrona.

**Request**:
```json
{
  "command": "deploy",
  "payload": {
    "environment": "staging",
    "version": "1.2.0"
  },
  "metadata": {
    "source": "ci-pipeline",
    "correlationId": "deploy-123"
  }
}
```

**Response esperado**: 201 Created
```json
{
  "id": "uuid-v4",
  "status": "pending",
  "command": "deploy",
  "createdAt": "2026-04-10T..."
}
```

**Resultado**: ✅ PASS - Retorna 201 con CommandResponse (sin valores null)

---

### 2. GET /api/commands - Listar comandos

**Propósito**: Obtener lista de comandos con paginación.

**Query Parameters**:
- `status` (optional): filtrar por estado
- `source` (optional): filtrar por fuente
- `limit` (optional, default: 20): límite de resultados
- `offset` (optional, default: 0): offset de paginación

**Response esperado**: 200 OK
```json
{
  "items": [...],
  "total": 1,
  "limit": 20,
  "offset": 0
}
```

**Resultado**: ✅ PASS - Retorna lista paginada

---

### 3. GET /api/commands/{id} - Consultar estado

**Propósito**: Obtener el estado de un comando específico.

**Path Parameters**:
- `id`: UUID del comando

**Response esperado**: 200 OK o 404 Not Found

**Resultado**: ✅ PASS - Retorna CommandResponse

---

### 4. GET /api/commands/{id}/result - Obtener resultado

**Propósito**: Obtener el resultado de un comando.

**Path Parameters**:
- `id`: UUID del comando

**Response esperado**: 200 OK o 404 Not Found
```json
{
  "id": "uuid-v4",
  "status": "pending",
  "result": null,
  "error": null,
  "completedAt": null
}
```

**Resultado**: ✅ PASS - Retorna CommandResult (result está vacío porque no hay ejecución real)

---

## Casos de Prueba

| # | Endpoint | Caso | Status |
|---|----------|------|--------|
| 1 | POST /api/commands | Comando válido | ✅ PASS | Retorna 201 con CommandResponse |
| 2 | POST /api/commands | Sin comando (400) | ✅ PASS | Retorna 400 con Error: "El campo 'command' es requerido" |
| 3 | GET /api/commands | Sin filtros | ✅ PASS |
| 4 | GET /api/commands | Con limit/offset | ✅ PASS |
| 5 | GET /api/commands/{id} | ID válido | ✅ PASS |
| 6 | GET /api/commands/{id} | ID inválido (404) | ✅ PASS |
| 7 | GET /api/commands/{id}/result | ID válido | ✅ PASS |
| 8 | GET /api/commands/{id}/result | ID inválido (404) | ✅ PASS |

## Ejecutar Pruebas Manuales

```bash
# Iniciar servicio
cd apps/backend/command-service
mvn quarkus:dev -Dquarkus.smallrye-jwt.enabled=false

# En otra terminal - ejecutar comandos:

# 1. Crear comando
curl -X POST http://localhost:3000/api/commands \
  -H "Content-Type: application/json" \
  -d '{
    "command": "deploy",
    "payload": {"environment": "staging", "version": "1.2.0"},
    "metadata": {"source": "ci-pipeline", "correlationId": "deploy-123"}
  }'

# 2. Listar comandos
curl http://localhost:3000/api/commands

# 3. Consultar estado (reemplazar {id})
curl http://localhost:3000/api/commands/{id}

# 4. Obtener resultado
curl http://localhost:3000/api/commands/{id}/result
```

## Notas

- El servicio usa almacenamiento en memoria (ConcurrentHashMap)
- Los resultados están vacíos porque no hay ejecución real de comandos
- Autenticación JWT deshabilitada para desarrollo (`quarkus.smallrye-jwt.enabled=false`)
- Puerto configurado en `apps/backend/command-service/src/main/resources/application.yaml`
