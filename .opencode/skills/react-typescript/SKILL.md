---
name: react-typescript
description: Configurar proyectos React con TypeScript, Vite y mejores prácticas
license: MIT
compatibility: opencode
metadata:
  category: frontend
  audience: frontend-developers
---

# React + TypeScript Setup Skill

## What I do

Ayudo a configurar proyectos React con TypeScript usando:
- **Vite** - Build tool moderno y rápido
- **TypeScript** - Tipado estático
- **ESLint + Prettier** - Calidad de código
- **Testing** - Vitest, React Testing Library, Playwright

## When to use me

Usar este skill cuando:
- Inicializar un nuevo proyecto React
- Configurar TypeScript correctamente
- Configurar linting y formatting
- Establecer estructura de proyecto
- Configurar testing

## Inicializar Proyecto

```bash
# Crear proyecto con Vite
npm create vite@latest my-app -- --template react-ts

# O con pnpm
pnpm create vite my-app --template react-ts

# Instalar dependencias
cd my-app
pnpm install
```

## Estructura de Proyecto

```
src/
├── components/          # Componentes reutilizables
│   ├── Button/
│   │   ├── Button.tsx
│   │   ├── Button.module.css
│   │   └── index.ts
├── pages/              # Páginas/Rutas
│   ├── Home/
│   └── Dashboard/
├── hooks/               # Custom hooks
│   └── useAuth.ts
├── services/            # API calls
│   └── api.ts
├── types/               # Tipos TypeScript
│   └── user.ts
├── utils/               # Utilidades
│   └── format.ts
├── assets/              # Recursos estáticos
├── App.tsx              # Componente principal
├── main.tsx             # Entry point
└── vite-env.d.ts        # Tipos de Vite
```

## Configuración TypeScript

```json
// tsconfig.json
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"],
      "@components/*": ["src/components/*"]
    }
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
```

## Configuración ESLint

```bash
# Instalar ESLint
pnpm add -D eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin
```

```javascript
// .eslintrc.cjs
module.exports = {
  root: true,
  env: { browser: true, es2020: true },
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:react-hooks/recommended',
  ],
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module',
    ecmaFeatures: { jsx: true },
  },
  plugins: ['@typescript-eslint', 'react-hooks'],
  rules: {
    '@typescript-eslint/no-unused-vars': ['warn', { argsIgnorePattern: '^_' }],
    'react-hooks/rules-of-hooks': 'error',
    'react-hooks/exhaustive-deps': 'warn',
  },
};
```

## Componentes con TypeScript

### Componente Básico

```tsx
interface ButtonProps {
  children: React.ReactNode;
  onClick?: () => void;
  variant?: 'primary' | 'secondary';
  disabled?: boolean;
}

export function Button({ 
  children, 
  onClick, 
  variant = 'primary',
  disabled = false 
}: ButtonProps) {
  return (
    <button 
      className={`btn btn-${variant}`}
      onClick={onClick}
      disabled={disabled}
    >
      {children}
    </button>
  );
}
```

### Custom Hook

```tsx
interface UseFetchResult<T> {
  data: T | null;
  loading: boolean;
  error: Error | null;
}

function useFetch<T>(url: string): UseFetchResult<T> {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    fetch(url)
      .then(res => res.json())
      .then(setData)
      .catch(setError)
      .finally(() => setLoading(false));
  }, [url]);

  return { data, loading, error };
}
```

## Testing con Vitest

```bash
pnpm add -D vitest @testing-library/react @testing-library/jest-dom jsdom
```

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./src/test/setup.ts'],
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
});
```

```tsx
// Button.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import { Button } from './Button';

describe('Button', () => {
  it('renders children correctly', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByRole('button')).toHaveTextContent('Click me');
  });

  it('calls onClick when clicked', () => {
    const handleClick = vi.fn();
    render(<Button onClick={handleClick}>Click me</Button>);
    fireEvent.click(screen.getByRole('button'));
    expect(handleClick).toHaveBeenCalled();
  });
});
```

## Variables de Entorno

```
# .env
VITE_API_URL=http://localhost:3000
VITE_APP_TITLE=My App
```

```typescript
// Uso en código
const apiUrl = import.meta.env.VITE_API_URL;
```

## Anti-Patrones

| Práctica | Problema | Solución |
|----------|----------|----------|
| `any` en TypeScript | Pierde tipado | Usar tipos específicos |
| useEffect sin cleanup | Memory leaks | Retornar función de cleanup |
| Props drilling | Acoplamiento | Usar Context o composición |
| Fetch sin manejo de errores | App quebrada | Always handle errors |

## Comandos Útiles

```bash
# Development
pnpm dev

# Build
pnpm build

# Preview build
pnpm preview

# Testing
pnpm test

# Coverage
pnpm test --coverage

# Lint
pnpm lint
```
