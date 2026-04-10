---
name: frontend-api-integration
description: Integrar frontend con APIs backend usando fetch, axios y React Query
license: MIT
compatibility: opencode
metadata:
  category: frontend
  audience: frontend-developers
---

# Frontend API Integration Skill

## What I do

Ayudo a integrar el frontend con APIs backend:
- **Fetch API** - Requests nativos
- **Axios** - Cliente HTTP con interceptores
- **React Query** - Gestión de estado de servidor
- **TypeScript** - Tipado de respuestas

## When to use me

Usar este skill cuando:
- Consumir REST APIs desde React
- Configurar cliente HTTP con autenticación
- Manejar estados de carga, error y éxito
- Implementar polling o refetching
- Manejar retry automático

## Configuración de API Client

### Usando Fetch

```typescript
// services/api.ts
const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000/api';

interface RequestOptions extends RequestInit {
  params?: Record<string, string>;
}

class ApiClient {
  private baseUrl: string;

  constructor(baseUrl: string) {
    this.baseUrl = baseUrl;
  }

  private async request<T>(
    endpoint: string,
    options: RequestOptions = {}
  ): Promise<T> {
    const { params, ...fetchOptions } = options;
    let url = `${this.baseUrl}${endpoint}`;

    if (params) {
      const searchParams = new URLSearchParams(params);
      url += `?${searchParams}`;
    }

    const response = await fetch(url, {
      ...fetchOptions,
      headers: {
        'Content-Type': 'application/json',
        ...fetchOptions.headers,
      },
    });

    if (!response.ok) {
      const error = await response.json().catch(() => ({}));
      throw new ApiError(response.status, error.message || 'Request failed');
    }

    return response.json();
  }

  get<T>(endpoint: string, params?: Record<string, string>) {
    return this.request<T>(endpoint, { method: 'GET', params });
  }

  post<T>(endpoint: string, data?: unknown) {
    return this.request<T>(endpoint, {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }

  put<T>(endpoint: string, data?: unknown) {
    return this.request<T>(endpoint, {
      method: 'PUT',
      body: JSON.stringify(data),
    });
  }

  delete<T>(endpoint: string) {
    return this.request<T>(endpoint, { method: 'DELETE' });
  }
}

class ApiError extends Error {
  constructor(public status: number, message: string) {
    super(message);
    this.name = 'ApiError';
  }
}

export const api = new ApiClient(API_BASE_URL);
export { ApiError };
```

### Usando Axios

```typescript
// services/axios.ts
import axios, { AxiosError, InternalAxiosRequestConfig } from 'axios';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:3000/api',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Interceptor de request
api.interceptors.request.use(
  (config: InternalAxiosRequestConfig) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Interceptor de response
api.interceptors.response.use(
  (response) => response,
  (error: AxiosError) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export default api;
```

## Integración con Command API

### Tipos TypeScript

```typescript
// types/command.ts
export interface CommandPayload {
  environment?: string;
  version?: string;
  [key: string]: unknown;
}

export interface CommandMetadata {
  source?: string;
  correlationId?: string;
}

export interface CommandRequest {
  command: string;
  payload?: CommandPayload;
  metadata?: CommandMetadata;
}

export interface CommandResponse {
  id: string;
  status: 'pending' | 'processing' | 'completed' | 'failed';
  command: string;
  payload?: CommandPayload;
  metadata?: CommandMetadata;
  createdAt: string;
  completedAt?: string;
}

export interface CommandResult {
  id: string;
  status: 'pending' | 'processing' | 'completed' | 'failed';
  result?: {
    message?: string;
    output?: string;
  };
  error?: string;
  completedAt?: string;
}

export interface CommandListResponse {
  items: CommandResponse[];
  total: number;
  limit: number;
  offset: number;
}
```

### Servicio de Comandos

```typescript
// services/commands.ts
import { api } from './axios';
import type {
  CommandRequest,
  CommandResponse,
  CommandResult,
  CommandListResponse,
} from '../types/command';

export const commandService = {
  async createCommand(data: CommandRequest): Promise<CommandResponse> {
    const response = await api.post<CommandResponse>('/commands', data);
    return response.data;
  },

  async listCommands(params?: {
    status?: string;
    source?: string;
    limit?: number;
    offset?: number;
  }): Promise<CommandListResponse> {
    const response = await api.get<CommandListResponse>('/commands', { params });
    return response.data;
  },

  async getCommand(id: string): Promise<CommandResponse> {
    const response = await api.get<CommandResponse>(`/commands/${id}`);
    return response.data;
  },

  async getCommandResult(id: string): Promise<CommandResult> {
    const response = await api.get<CommandResult>(`/commands/${id}/result`);
    return response.data;
  },
};
```

## React Query Integration

```typescript
// hooks/useCommands.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { commandService } from '../services/commands';
import type { CommandRequest } from '../types/command';

export function useCommands(params?: {
  status?: string;
  source?: string;
  limit?: number;
  offset?: number;
}) {
  return useQuery({
    queryKey: ['commands', params],
    queryFn: () => commandService.listCommands(params),
  });
}

export function useCommand(id: string) {
  return useQuery({
    queryKey: ['command', id],
    queryFn: () => commandService.getCommand(id),
    enabled: !!id,
  });
}

export function useCommandResult(id: string) {
  return useQuery({
    queryKey: ['command-result', id],
    queryFn: () => commandService.getCommandResult(id),
    enabled: !!id,
    refetchInterval: 2000, // Polling cada 2 segundos
  });
}

export function useCreateCommand() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CommandRequest) => commandService.createCommand(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['commands'] });
    },
  });
}
```

## Ejemplo de Componente

```tsx
// components/CommandForm.tsx
import { useState } from 'react';
import { useCreateCommand } from '../hooks/useCommands';
import type { CommandRequest } from '../types/command';

export function CommandForm() {
  const [command, setCommand] = useState('');
  const createCommand = useCreateCommand();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    const data: CommandRequest = {
      command,
      payload: { environment: 'staging' },
      metadata: { source: 'web-ui' },
    };

    try {
      await createCommand.mutateAsync(data);
      setCommand('');
      alert('Comando enviado!');
    } catch (error) {
      alert('Error al enviar comando');
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        type="text"
        value={command}
        onChange={(e) => setCommand(e.target.value)}
        placeholder="Nombre del comando"
      />
      <button type="submit" disabled={createCommand.isPending}>
        {createCommand.isPending ? 'Enviando...' : 'Enviar'}
      </button>
    </form>
  );
}
```

## Manejo de Errores

```tsx
// components/ErrorDisplay.tsx
interface ErrorDisplayProps {
  error: Error | null;
}

export function ErrorDisplay({ error }: ErrorDisplayProps) {
  if (!error) return null;

  return (
    <div className="error">
      <h3>Error</h3>
      <p>{error.message}</p>
      <button onClick={() => window.location.reload()}>Reintentar</button>
    </div>
  );
}
```

## Anti-Patrones

| Práctica | Problema | Solución |
|----------|----------|----------|
| No manejar loading state | UX poor | Usar isPending de React Query |
| No manejar errores | User sin feedback | Mostrar errores al usuario |
| No validar datos antes de enviar | Errores 400/500 | Validar con Zod o Yup |
| Hardcoded URLs | Difícil mantener | Usar variables de entorno |
| No hacer retry en errores de red | Fallos temporales | Configurar retry en axios/query |

## Configuración de Entorno

```
# .env
VITE_API_URL=http://localhost:3000/api
VITE_API_TIMEOUT=10000
```

## Referencias

- [Axios](https://axios-http.com)
- [React Query](https://tanstack.com/query)
- [OpenAPI Generator](https://openapi-generator.tech)
