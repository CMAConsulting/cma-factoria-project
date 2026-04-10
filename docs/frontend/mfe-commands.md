# MFE Commands — Microfrontend de Comandos

## Descripción

Microfrontend remoto que gestiona el ciclo de vida de los comandos: listado, creación y visualización de estado. Expone el componente `CommandsApp` para ser consumido por el Shell.

## Ubicación

`apps/frontend/mfe-commands/`

## Puerto

- **Desarrollo**: 3001

## Stack

- React 18 + TypeScript 5.7
- Webpack 5 + Module Federation
- `@cma-factoria/shared-api` para consumo de la API

## Configuración Module Federation

```javascript
// webpack.config.js
new ModuleFederationPlugin({
  name: 'mfeCommands',
  filename: 'remoteEntry.js',
  exposes: {
    './CommandsApp': './src/App',
  },
  shared: {
    react: { singleton: true, requiredVersion: '^18.3.1' },
    'react-dom': { singleton: true, requiredVersion: '^18.3.1' },
  },
})
```

## Integración con Backend

Conecta al backend Quarkus en el **puerto 8080**:

```typescript
const API_URL = 'http://localhost:8080';
const client = createClient({ baseUrl: API_URL });
```

## Uso de la Shared API

```tsx
import {
  listCommands,
  executeCommand,
  createClient,
  type CommandRequest,
  type CommandResponse,
} from '@cma-factoria/shared-api';

// Listar comandos
const response = await listCommands({ client });
const commands = response.data?.items || [];

// Crear comando — usar body, no data
const request: CommandRequest = {
  command: 'deploy-' + Date.now(),
  payload: { environment: 'staging', version: '1.0.0' },
  metadata: { source: 'mfe-commands' },
};
await executeCommand({ client, body: request });
```

> **Importante:** `executeCommand` usa el parámetro `body`, no `data`.

## Estados del Componente

| Estado | Descripción |
|--------|-------------|
| Loading | Spinner mientras carga la lista |
| Error | Mensaje de error + botón "Reintentar" |
| Empty | Línea decorativa + texto cuando no hay comandos |
| List | Lista de comandos con nombre, status, timestamp y entorno |

## Colores de Status (inline style)

| Status | Color |
|--------|-------|
| `pending` | `#eab308` |
| `processing` | `#ff6b35` (accent del sistema) |
| `completed` | `#22c55e` |
| `failed` | `#ef4444` |

## Diseño

Hereda el sistema de diseño del shell mediante variables CSS:

- Sin `border-radius` (estética industrial)
- Botón "New Command": outlined naranja, fill al hover
- Indicador de hover por item: borde izquierdo naranja animado (`::before`)
- Status badges: bloque sin redondeo, tipografía `JetBrains Mono`
- Scrollbar personalizado (3px, sin track)

## Desarrollo

```bash
# Compilar shared-api primero
cd apps/frontend/shared-api && npm run build

# Iniciar el MFE
cd apps/frontend/mfe-commands
npm install
npm run dev    # http://localhost:3001
npm run build
```

## Dependencias

```json
{
  "dependencies": {
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "@cma-factoria/shared-api": "file:../shared-api"
  }
}
```

## Notas

- Puede ejecutarse de forma independiente en `http://localhost:3001`
- Requiere backend en `http://localhost:8080` para datos reales
- Tipos `CommandResponse`, `CommandRequest` provienen de `@cma-factoria/shared-api` (generados desde `contracts/openapi/commands.yaml`)
