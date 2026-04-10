---
name: microfrontends-setup
description: Configurar arquitectura de microfrontends con Module Federation y Nx/Turborepo
license: MIT
compatibility: opencode
metadata:
  category: architecture
  audience: frontend-developers
---

# Microfrontends Setup Skill

## What I do

Ayudo a configurar una arquitectura de microfrontends escalable usando:
- **Webpack Module Federation** - Carga dinámica de módulos remotos
- **Nx o Turborepo** - Gestión de monorepo
- **React/Vue/Angular** - Frameworks soportados

## When to use me

Usar este skill cuando:
- Necesitas inicializar un proyecto de microfrontends
- Configurar Module Federation en Webpack
- Establecer estructura de monorepo con Nx o Turborepo
- Configurar comunicación entre microfrontends
- Manejar estado compartido y estilos

## Estructura de Proyecto Recomendada

```
my-app/
├── apps/
│   ├── shell/              # Contenedor principal
│   ├── mfe-header/         # Microfrontend de header
│   ├── mfe-dashboard/      # Microfrontend de dashboard
│   └── mfe-analytics/      # Microfrontend de analytics
├── libs/
│   ├── shared-ui/          # Componentes compartidos
│   ├── shared-utils/       # Utilidades compartidas
│   └── shared-types/       # Tipos TypeScript
├── package.json
├── nx.json                 # Configuración Nx
└── turbo.json              # Configuración Turborepo
```

## Configuración de Module Federation

### Shell (app principal)

```javascript
// webpack.config.js
const { ModuleFederationPlugin } = require('webpack').container;
const deps = require('./package.json').dependencies;

module.exports = {
  plugins: [
    new ModuleFederationPlugin({
      name: 'shell',
      remotes: {
        header: 'header@http://localhost:3001/remoteEntry.js',
        dashboard: 'dashboard@http://localhost:3002/remoteEntry.js',
      },
      shared: {
        ...deps,
        react: { singleton: true, requiredVersion: deps.react },
        'react-dom': { singleton: true, requiredVersion: deps['react-dom'] },
      },
    }),
  ],
};
```

### Microfrontend Remoto

```javascript
// webpack.config.js para mfe-header
const { ModuleFederationPlugin } = require('webpack').container;
const deps = require('./package.json').dependencies;

module.exports = {
  plugins: [
    new ModuleFederationPlugin({
      name: 'header',
      filename: 'remoteEntry.js',
      exposes: {
        './Header': './src/Header.tsx',
      },
      shared: {
        ...deps,
        react: { singleton: true, requiredVersion: deps.react },
        'react-dom': { singleton: true, requiredVersion: deps['react-dom'] },
      },
    }),
  ],
};
```

## Consumo de Microfrontends

### En Shell

```tsx
// App.tsx
import { useEffect, useState } from 'react';

const Header = React.lazy(() => import('header/Header'));
const Dashboard = React.lazy(() => import('dashboard/Dashboard'));

function App() {
  return (
    <React.Suspense fallback="Loading...">
      <Header />
      <Dashboard />
    </React.Suspense>
  );
}
```

## Configuración Nx

```json
// nx.json
{
  "npmScope": "my-app",
  "implicitDependencies": {
    "package.json": "*"
  },
  "targetDefaults": {
    "build": {
      "dependsOn": ["^build"]
    }
  }
}
```

```json
// apps/shelf/project.json
{
  "name": "shell",
  "$schema": "./node_modules/nx/schemas/project-schema.json",
  "sourceRoot": "apps/shell/src",
  "targets": {
    "build": {
      "executor": "@nrwl/web:build",
      "options": {
        "outputPath": "dist/apps/shell",
        "index": "apps/shell/src/index.html",
        "main": "apps/shell/src/main.tsx"
      }
    },
    "serve": {
      "executor": "@nrwl/web:dev-server",
      "options": {
        "port": 3000
      }
    }
  }
}
```

## Configuración Turborepo

```json
// turbo.json
{
  "$schema": "https://turbo.build/schema.json",
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**"]
    },
    "lint": {},
    "test": {},
    "dev": {
      "cache": false,
      "persistent": true
    }
  }
}
```

```json
// package.json
{
  "workspaces": ["apps/*", "packages/*"],
  "scripts": {
    "build": "turbo run build",
    "dev": "turbo run dev --parallel",
    "lint": "turbo run lint"
  }
}
```

## Buenas Prácticas

### 1. Versionado Semántico de Microfrontends

- Usar `1.x.x` con compatibilidad hacia atrás
- Nunca exponer breaking changes sin migración
- Documentar cambios entre versiones

### 2. Aislamiento de Estilos

- Usar CSS Modules o Shadow DOM
- Evitar selectores globales
- Prefijos para evitar conflictos

### 3. Comunicación entre Microfrontends

- **Custom Events**: Para comunicación débil
- **Context compartido**: Para estado global
- **Event Bus**: Para eventos más complejos

```typescript
// shared-event-bus
class EventBus {
  private listeners: Map<string, Function[]> = new Map();

  subscribe(event: string, callback: Function) {
    if (!this.listeners.has(event)) {
      this.listeners.set(event, []);
    }
    this.listeners.get(event)!.push(callback);
  }

  publish(event: string, data: any) {
    this.listeners.get(event)?.forEach(cb => cb(data));
  }
}
```

### 4. Manejo de Errores

```tsx
// Error Boundary por microfrontend
function MFEErrorBoundary({ children }) {
  const [hasError, setHasError] = useState(false);

  useEffect(() => {
    const handler = () => setHasError(true);
    window.addEventListener('error', handler);
    return () => window.removeEventListener('error', handler);
  }, []);

  if (hasError) {
    return <div>Error loading component</div>;
  }

  return children;
}
```

## Anti-Patrones

| Práctica | Problema | Solución |
|----------|----------|----------|
| Compartir estado global | Acoplamiento | Usar Custom Events |
| CSS global | Conflictos | CSS Modules |
| Versiones exactas en shared | Break en actualizaciones | Usar singleton con requiredVersion |
| Sin Fallback | Pantalla blanca si falla | Always有心Plan de fallback |

## Troubleshooting

### Error: Shared module is not available

```javascript
// Asegurar que el modulo compartido tiene versión compatible
shared: {
  react: { singleton: true, eager: true, requiredVersion: '18.0.0' }
}
```

### Error: Remote container not found

```bash
# Verificar que el remote está corriendo
curl http://localhost:3001/remoteEntry.js
```

### Error: Circular dependency

```javascript
// Evitar referencias circulares entre MFEs
// Usar abstracción con libs compartidas
```
