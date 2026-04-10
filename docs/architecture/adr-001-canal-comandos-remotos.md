# ADR-001: Canal de Comandos Remotos

## Estado

**Aceptado** - Implementado

## Contexto

Se requiere un canal de comunicación remota para enviar instrucciones de manera remota a la implementación del sistema. Este canal permitirá a sistemas externos (CI/CD, webhooks, otras aplicaciones) ejecutar comandos en el sistema.

## Decisión

Se implementará una **Command API** integrada en el backend con los siguientes componentes:

### Endpoints propuestos

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| `POST` | `/api/commands` | Enviar un comando para ejecución |
| `GET` | `/api/commands/:id` | Consultar estado de un comando |
| `GET` | `/api/commands/:id/result` | Obtener resultado de un comando |

### Formato de Comando

```json
{
  "command": "string",
  "payload": {},
  "metadata": {
    "source": "string",
    "correlationId": "string"
  }
}
```

### Formato de Respuesta

```json
{
  "id": "uuid",
  "status": "pending|processing|completed|failed",
  "result": {},
  "error": "string|null",
  "createdAt": "timestamp",
  "completedAt": "timestamp|null"
}
```

### Autenticación

- Token de API en header `Authorization: Bearer <token>`
- Rate limiting por IP/fuente

## Consecuencias

### Positivas

- Sistema extensible para ejecutar comandos arbitrary
- Tracking de estado y resultados
- Integración con sistemas externos (CI/CD, webhooks)

### Negativas

- Requiere implementación del backend primero
- Posible vector de ataque si no se securiza correctamente

## Alternativas consideradas

1. **CLI remota via SSH** - Menos seguro, harder de integrar
2. **Message queue (Redis/RabbitMQ)** - Más complejo de operar
3. **gRPC** - Menor adopción, más difícil de exponer externamente