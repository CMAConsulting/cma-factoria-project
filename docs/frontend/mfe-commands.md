# MFE Commands - Microfrontend de Comandos

## Descripción

Microfrontend para la gestión de comandos remotos. Expone el componente `CommandsApp` para ser consumido por el Shell.

## Ubicación

`apps/frontend/mfe-commands/`

## Puerto

- **Desarrollo**: 3001

## Stack Tecnológico

- React 18
- TypeScript 5.7
- Webpack 5
- Module Federation

## Configuración Module Federation

```javascript
// webpack.config.js
const { ModuleFederationPlugin } = require('webpack').container;

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

Consume el backend usando el módulo compartido `@cma-factoria/shared-api`:

```
http://localhost:3000/api/commands
```

## Dependencia

```json
{
  "dependencies": {
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "@cma-factoria/shared-api": "file:../shared-api"
  }
}
```

Para más detalles ver `docs/frontend/shared-api.md`

## Componente Principal

```tsx
// src/App.tsx
import { useState, useEffect } from 'react';
import { 
  listCommands, 
  executeCommand, 
  createClient,
  type CommandRequest
} from '@cma-factoria/shared-api';

const API_URL = 'http://localhost:3000/api';

const client = createClient({
  baseUrl: API_URL,
});

export default function CommandsApp() {
  const [commands, setCommands] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchCommands();
  }, []);

  const fetchCommands = async () => {
    try {
      setLoading(true);
      const response = await listCommands({ client });
      setCommands(response.data?.items || []);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error');
    } finally {
      setLoading(false);
    }
  };

  const createNewCommand = async () => {
    try {
      const request: CommandRequest = {
        command: 'test-' + Date.now(),
        payload: { environment: 'staging' },
        metadata: { source: 'mfe-commands' }
      };
      await executeCommand({ client, data: request });
      fetchCommands();
    } catch (err) {
      console.error('Error creating command:', err);
    }
  };

  if (loading) return <div>Cargando comandos...</div>;
  if (error) return <div style={{ color: 'red' }}>Error: {error}</div>;

  return (
    <div style={{ border: '1px solid #ccc', padding: '15px', borderRadius: '8px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '15px' }}>
        <h3>Commands MFE</h3>
        <button onClick={createNewCommand} style={{ padding: '8px 16px', cursor: 'pointer' }}>
          + New Command
        </button>
      </div>

      {commands.length === 0 ? (
        <p>No hay comandos</p>
      ) : (
        <ul style={{ listStyle: 'none', padding: 0 }}>
          {commands.map((cmd) => (
            <li key={cmd.id} style={{ padding: '10px', borderBottom: '1px solid #eee' }}>
              <strong>{cmd.command}</strong>
              <span style={{ marginLeft: '10px', padding: '2px 8px', borderRadius: '4px', background: cmd.status === 'pending' ? '#ffd700' : '#90EE90' }}>
                {cmd.status}
              </span>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
```

## Desarrollo

### Instalar dependencias

```bash
cd apps/frontend/mfe-commands
npm install
```

### Build shared-api primero

```bash
cd apps/frontend/shared-api
npm run build
```

### Iniciar servidor

```bash
npm run dev
```

### Build

```bash
npm run build
```

## Dependencias

```json
{
  "dependencies": {
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "@cma-factoria/shared-api": "file:../shared-api"
  },
  "devDependencies": {
    "webpack": "^5.97.1",
    "webpack-dev-server": "^5.2.0",
    "html-webpack-plugin": "^5.6.3",
    "typescript": "^5.7.2",
    "ts-loader": "^9.5.1"
  }
}
```

## Notas

- Puerto 3001 (diferente al shell/backend)
- Expone `CommandsApp` como módulo remoto
- Usa `@cma-factoria/shared-api` para consumo de API con type-safety
- Requiere backend Command Service en puerto 3000
- Puede ejecutarse de forma independiente para desarrollo