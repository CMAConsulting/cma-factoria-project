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

## API Connection

Consume el backend usando el módulo compartido `@cma-factoria/shared-api`:

```
http://localhost:3000/api/commands
```

### Tipos Usados

```tsx
import { 
  CommandResponse, 
  CommandRequest, 
  CommandsApi,
  Configuration 
} from '@cma-factoria/shared-api';
```

Para más detalles ver `docs/frontend/shared-api.md`

## Componente Principal

```tsx
// src/App.tsx
export default function CommandsApp() {
  const [commands, setCommands] = useState([]);
  
  const fetchCommands = async () => {
    const response = await fetch('http://localhost:3000/api/commands');
    const data = await response.json();
    setCommands(data.items);
  };

  const createCommand = async () => {
    await fetch('http://localhost:3000/api/commands', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        command: 'test-command',
        payload: { environment: 'staging' },
        metadata: { source: 'mfe-commands' }
      }),
    });
    fetchCommands();
  };

  return (
    <div>
      <button onClick={createCommand}>+ New Command</button>
      <ul>
        {commands.map(cmd => (
          <li key={cmd.id}>{cmd.command} - {cmd.status}</li>
        ))}
      </ul>
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
    "react-dom": "^18.3.1"
  },
  "devDependencies": {
    "webpack": "^5.97.1",
    "webpack-dev-server": "^5.2.0",
    "html-webpack-plugin": "^5.6.3"
  }
}
```

## Notas

- Puerto 3001 (diferente al shell/backend)
- Expone `CommandsApp` como módulo remoto
- Requiere backend Command Service en puerto 3000
- Puede ejecutarse de forma independiente para desarrollo
