# Shared API - Módulo de Tipos Compartidos

## Descripción

Módulo TypeScript que genera tipos y clientes API automaticamente desde las especificaciones OpenAPI. Permite que los microfrontends consuman backends con type-safety.

## Ubicación

`apps/frontend/shared-api/`

## Uso

### Instalación

```bash
cd apps/frontend/shared-api
npm install
npm run generate
npm run build
```

### Consumir en MFE

```bash
# En el MFE que lo consumirá
npm install @cma-factoria/shared-api
```

### Uso en Componente

```tsx
import { 
  CommandResponse, 
  CommandRequest, 
  CommandsApi,
  Configuration 
} from '@cma-factoria/shared-api';

// Configurar cliente
const apiConfig = new Configuration({ basePath: 'http://localhost:3000/api' });
const commandsApi = new CommandsApi(apiConfig);

// Listar comandos
const response = await commandsApi.listCommands();
const commands: CommandResponse[] = response.data.items;

// Crear comando
const request: CommandRequest = {
  command: 'deploy',
  payload: { environment: 'staging' },
  metadata: { source: 'web' }
};
await commandsApi.executeCommand(request);
```

## Modelos Generados

| Modelo | Descripción |
|--------|-------------|
| `CommandRequest` | Request para crear comando |
| `CommandResponse` | Respuesta de comando |
| `CommandPayload` | Datos del payload |
| `CommandMetadata` | Metadatos del comando |
| `CommandResult` | Resultado de comando |
| `CommandResultData` | Datos del resultado |
| `CommandListResponse` | Lista paginada de comandos |
| `ModelError` | Respuesta de error |

## API Generada

### CommandsApi

| Método | Descripción |
|--------|-------------|
| `executeCommand` | Crear comando |
| `listCommands` | Listar comandos |
| `getCommand` | Obtener comando por ID |
| `getCommandResult` | Obtener resultado |

## Regenerar Tipos

Si cambia la especificación OpenAPI:

```bash
cd apps/frontend/shared-api
npm run generate
npm run build
```

## Dependencias

```json
{
  "devDependencies": {
    "typescript": "^5.7.2",
    "@openapitools/openapi-generator-cli": "^2.15.0"
  }
}
```

## Configuración

El archivo `openapi.config.yaml` especifica:
- Input: `contracts/openapi/commands.yaml`
- Output: Tipos TypeScript con fetch API
- Paquete: `@cma-factoria/shared-api`

## Notas

- Usa `typescript-fetch` generator
- Tipos 100% consistentes con el backend
- API cliente lista para usar
