# Shell - Contenedor Principal

## Descripción

Contenedor principal (host) de la aplicación microfrontend. Es el punto de entrada que carga y organiza los microfrontends remotos.

## Ubicación

`apps/frontend/shell/`

## Puerto

- **Desarrollo**: 3000

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
  name: 'shell',
  filename: 'remoteEntry.js',
  remotes: {
    mfeCommands: 'mfeCommands@http://localhost:3001/remoteEntry.js',
  },
  shared: {
    react: { singleton: true, requiredVersion: '^18.3.1' },
    'react-dom': { singleton: true, requiredVersion: '^18.3.1' },
  },
})
```

## Consumo de Microfrontends

```tsx
// src/App.tsx
import { useState, Suspense, lazy } from 'react';

const MfeCommands = lazy(() => import('mfeCommands/CommandsApp'));

function App() {
  return (
    <div>
      <header>
        <h1>CMA Factoria - Shell</h1>
      </header>
      
      <Suspense fallback={<div>Cargando...</div>}>
        <MfeCommands />
      </Suspense>
    </div>
  );
}
```

## Desarrollo

### Instalar dependencias

```bash
cd apps/frontend/shell
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
    "react-dom": "^18.3.1",
    "react-router-dom": "^6.28.0"
  },
  "devDependencies": {
    "webpack": "^5.97.1",
    "webpack-dev-server": "^5.2.0",
    "html-webpack-plugin": "^5.6.3"
  }
}
```

## Notas

- Puerto 3000 (mismo que backend Command Service)
- Carga MFE commands desde puerto 3001
- Usa React.lazy() para carga bajo demanda
- Requiere que MFE commands esté corriendo para funcionar
