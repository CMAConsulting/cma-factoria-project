/**
 * Custom Hook: useCommands
 * Maneja el estado y la lógica de negocio para Commands
 */

import { useState, useEffect, useCallback } from 'react';
import {
  listAllCommands,
  createCommand,
  getCommandById,
  getResultByCommandId,
  createDeployCommand,
  type ListCommandsParams,
  type ListCommandsResult,
} from '../api/commands';
import type { CommandRequest, CommandResponse, CommandResult } from '@cma-factoria/shared-commands-api';
import type { CommandId } from '@cma-factoria/shared-commands-api';

// ============================================
// Tipos del Hook
// ============================================

/**
 * Estado del hook
 */
export interface UseCommandsState {
  /** Lista de comandos */
  commands: CommandResponse[];
  /** Bandera de carga */
  loading: boolean;
  /** Mensaje de error */
  error: string | null;
  /** Total de comandos disponibles */
  total?: number;
}

/**
 * Acciones del hook
 */
export interface UseCommandsActions {
  /** Recargar comandos */
  refresh: () => Promise<void>;
  /** Crear un nuevo comando */
  create: (request: CommandRequest) => Promise<void>;
  /** Crear comando de deploy */
  deploy: (environment: 'staging' | 'production', version: string) => Promise<void>;
  /** Obtener comando por ID */
  getById: (id: CommandId) => Promise<CommandResponse | null>;
  /** Obtener resultado de comando */
  getResult: (id: CommandId) => Promise<CommandResult | null>;
  /** Limpiar error */
  clearError: () => void;
}

/**
 * Hook completo
 */
export type UseCommands = UseCommandsState & UseCommandsActions;

// ============================================
// Hook Implementation
// ============================================

/**
 * Custom hook para gestionar comandos
 * @param initialParams - Parámetros iniciales para listar
 */
export function useCommands(initialParams?: ListCommandsParams): UseCommands {
  const [commands, setCommands] = useState<CommandResponse[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [total, setTotal] = useState<number | undefined>(undefined);

  /**
   * Fetch commands from API
   */
  const fetchCommands = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);
      
      const result: ListCommandsResult = await listAllCommands(initialParams);
      setCommands(result.items);
      setTotal(result.total);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error');
    } finally {
      setLoading(false);
    }
  }, [initialParams?.status, initialParams?.source, initialParams?.limit, initialParams?.offset]);

  // Fetch on mount
  useEffect(() => {
    fetchCommands();
  }, [fetchCommands]);

  /**
   * Create a new command
   */
  const create = useCallback(async (request: CommandRequest) => {
    try {
      setError(null);
      await createCommand(request);
      await fetchCommands();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to create command');
      throw err;
    }
  }, [fetchCommands]);

  /**
   * Create a deploy command
   */
  const deploy = useCallback(async (environment: 'staging' | 'production', version: string) => {
    const request = createDeployCommand(environment, version);
    await create(request);
  }, [create]);

  /**
   * Get command by ID
   */
  const getById = useCallback(async (id: CommandId): Promise<CommandResponse | null> => {
    try {
      setError(null);
      return await getCommandById(id);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to get command');
      return null;
    }
  }, []);

  /**
   * Get command result
   */
  const getResult = useCallback(async (id: CommandId): Promise<CommandResult | null> => {
    try {
      setError(null);
      return await getResultByCommandId(id);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to get command result');
      return null;
    }
  }, []);

  /**
   * Clear error
   */
  const clearError = useCallback(() => {
    setError(null);
  }, []);

  return {
    // State
    commands,
    loading,
    error,
    total,
    // Actions
    refresh: fetchCommands,
    create,
    deploy,
    getById,
    getResult,
    clearError,
  };
}