# Shared API - Módulo de Tipos Compartidos

## Descripción

Módulo TypeScript que genera tipos y cliente API automáticamente desde las especificaciones OpenAPI usando `@hey-api/openapi-ts`. Permite que los microfrontends consuman backends con type-safety completo.

## Ubicación

`apps/frontend/shared-api/`

## Stack

- **Generador**: @hey-api/openapi-ts v0.94+
- **Cliente HTTP**: Fetch API
- **Output**: TypeScript compilado a `dist/`

## Estructura

```
shared-api/
├── src/                        # Código fuente generado
│   ├── index.ts                # Exports principales
│   ├── sdk.gen.ts              # Funciones API (listCommands, executeCommand, etc.)
│   ├── types.gen.ts            # Tipos TypeScript
│   ├── client/                 # Cliente HTTP
│   └── core/                  # Utilidades core
│
└── dist/                       # JavaScript compilado
    ├── index.js, index.d.ts
    ├── sdk.gen.js, sdk.gen.d.ts
    └── ...
```

## Uso

### Instalar

```bash
cd apps/frontend/shared-api
npm install
npm run build
```

### Consumir en MFE

```bash
# En el MFE
npm install @cma-factoria/shared-api
```

### Ejemplo de Uso

```tsx
import { 
  listCommands, 
  executeCommand, 
  createClient,
  type CommandRequest 
} from '@cma-factoria/shared-api';

// Crear cliente
const client = createClient({
  baseUrl: 'http://localhost:3000/api'
});

// Listar comandos
const response = await listCommands({ client });
const commands = response.data?.items;

// Crear comando
const request: CommandRequest = {
  command: 'deploy',
  payload: { environment: 'staging' },
  metadata: { source: 'web' }
};
await executeCommand({ client, data: request });
```

## Funciones API Generadas

| Función | Método | Endpoint |
|---------|--------|----------|
| `listCommands` | GET | `/commands` |
| `executeCommand` | POST | `/commands` |
| `getCommand` | GET | `/commands/{id}` |
| `getCommandResult` | GET | `/commands/{id}/result` |

## Tipos Generados

- `CommandRequest`
- `CommandResponse`
- `CommandPayload`
- `CommandMetadata`
- `CommandResult`
- `CommandListResponse`
- `Error`

## Comandos

```bash
# Generar tipos desde OpenAPI
npm run generate

# Compilar TypeScript
npm run build

# Generar + compilar
npm run build
```

## Regenerar Tipos

Si cambia la especificación OpenAPI:

```bash
cd apps/frontend/shared-api
npm run build
```

## Dependencias

```json
{
  "devDependencies": {
    "typescript": "^5.7.2",
    "@hey-api/openapi-ts": "^0.94.4"
  }
}
```

## Notas

- Genera código 100% compatible con TypeScript strict
- Usa Fetch API nativa (sin dependencias adicionales)
- Soporta autenticación JWT (configurable)
- Tipos siempre sincronizados con el backend

## Alternativas Consideradas

- **openapi-generator-cli** - Más complejo, requiere Java
- **apigen-ts** - Un solo archivo de salida
- **@nicolas-chaulet/openapi-typescript-codegen** - Sin mantenimiento activo