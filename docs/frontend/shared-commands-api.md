# Shared Commands API

## Descripción

Módulo TypeScript generado automáticamente desde `contracts/openapi/commands.yaml` usando `@hey-api/openapi-ts`. Proporciona tipos y funciones HTTP con type-safety completo para el Command Service.

## Ubicación

`apps/frontend/shared-commands-api/`

## Nombre del paquete

`@cma-factoria/shared-api`

## Funciones API generadas

| Función | Método | Endpoint |
|---------|--------|----------|
| `listCommands` | GET | `/commands` |
| `executeCommand` | POST | `/commands` |
| `getCommand` | GET | `/commands/{id}` |
| `getCommandResult` | GET | `/commands/{id}/result` |

## Tipos generados

- `CommandRequest` — `{ command, payload?, metadata? }`
- `CommandResponse` — `{ id, status, command, payload?, metadata?, createdAt, completedAt? }`
- `CommandPayload` — `{ environment?, version?, [key: string]: unknown }`
- `CommandMetadata` — `{ source?, correlationId? }`
- `CommandResult` — `{ id, status, result?, error?, completedAt? }`
- `CommandListResponse` — `{ items, total, limit, offset }`

## Uso en MFE

```typescript
import {
  createClient,
  listCommands,
  executeCommand,
  type CommandRequest,
  type CommandResponse,
} from '@cma-factoria/shared-api';

const client = createClient({ baseUrl: 'http://localhost:8080' });

// Listar comandos
const res = await listCommands({ client });
const commands: CommandResponse[] = res.data?.items ?? [];

// Ejecutar comando (usa body:, no data:)
const request: CommandRequest = {
  command: 'deploy-staging',
  payload: { environment: 'staging', version: '1.0.0' },
  metadata: { source: 'mfe-commands' },
};
await executeCommand({ client, body: request });
```

> **Convención crítica:** `executeCommand` usa `body:` como parámetro, **no** `data:`.

## Ciclo de vida

```bash
# Generar src/ desde el contrato OpenAPI
npm run generate   # lee contracts/openapi/commands.yaml

# Compilar a dist/
npm run build

# Limpiar (src/ + dist/)
npm run clean
```

> `npm run clean` elimina **tanto `src/` como `dist/`**. Ejecutar `generate` + `build` tras hacer clean.

## Dependencias

```json
{
  "devDependencies": {
    "typescript": "^5.7.2",
    "@hey-api/openapi-ts": "^0.94.4"
  }
}
```
