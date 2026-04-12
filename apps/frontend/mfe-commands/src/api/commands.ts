/**
 * Commands API Client
 * Capa de acceso a datos - AISLA la lógica de red del resto de la aplicación
 */

import {
  listCommands,
  executeCommand,
  getCommand,
  getCommandResult,
  createClient,
  type Client,
  type CommandRequest,
  type CommandResponse,
  type CommandResult,
  type CommandId,
} from '@cma-factoria/shared-commands-api';

// ============================================
// Configuración del cliente
// ============================================

/**
 * URL base del API - configurable via entorno
 * Falls back a proxy en producción (/api)
 */
const API_URL = process.env.COMMANDS_API || '/api';

/**
 * Instancia singleton del cliente
 */
let clientInstance: Client | null = null;

/**
 * Obtiene o crea la instancia del cliente
 */
function getClient(): Client {
  if (!clientInstance) {
    clientInstance = createClient({
      baseUrl: API_URL,
    });
  }
  return clientInstance;
}

/**
 * Resets the client instance (useful for testing)
 */
export function resetClient(): void {
  clientInstance = null;
}

// ============================================
// Tipos locales
// ============================================

export interface ListCommandsParams {
  status?: 'pending' | 'processing' | 'completed' | 'failed';
  source?: string;
  limit?: number;
  offset?: number;
}

export interface ListCommandsResult {
  items: CommandResponse[];
  total?: number;
  limit?: number;
  offset?: number;
}

// ============================================
// Funciones API
// ============================================

/**
 * Lista todos los comandos
 */
export async function listAllCommands(
  params?: ListCommandsParams
): Promise<ListCommandsResult> {
  const client = getClient();
  
  const query = params 
    ? Object.fromEntries(
        Object.entries(params).filter(([, v]) => v !== undefined)
      )
    : undefined;

  const response = await listCommands({
    client,
    query: query as any,
  });

  if (response.error) {
    throw new Error(response.error.message || 'Failed to list commands');
  }

  return {
    items: response.data?.items || [],
    total: response.data?.total,
    limit: response.data?.limit,
    offset: response.data?.offset,
  };
}

/**
 * Crea un nuevo comando
 */
export async function createCommand(request: CommandRequest): Promise<CommandResponse> {
  const client = getClient();

  const response = await executeCommand({
    client,
    body: request,
  } as any);

  if (response.error) {
    throw new Error(response.error.message || 'Failed to create command');
  }

  return response.data as CommandResponse;
}

/**
 * Obtiene un comando por ID
 */
export async function getCommandById(id: CommandId): Promise<CommandResponse> {
  const client = getClient();

  const response = await getCommand({
    client,
    path: { id },
  } as any);

  if (response.error) {
    throw new Error(response.error.message || 'Failed to get command');
  }

  return response.data as CommandResponse;
}

/**
 * Obtiene el resultado de un comando
 */
export async function getResultByCommandId(id: CommandId): Promise<CommandResult> {
  const client = getClient();

  const response = await getCommandResult({
    client,
    path: { id },
  } as any);

  if (response.error) {
    throw new Error(response.error.message || 'Failed to get command result');
  }

  return response.data as CommandResult;
}

// ============================================
// Helper para crear comandos de ejemplo
// ============================================

/**
 * Crea un comando de deploy
 */
export function createDeployCommand(
  environment: 'staging' | 'production',
  version: string,
  source = 'mfe-commands'
): CommandRequest {
  return {
    command: `deploy-${Date.now()}`,
    payload: {
      environment,
      version,
    },
    metadata: {
      source,
    },
  };
}