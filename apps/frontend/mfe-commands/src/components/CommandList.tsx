/**
 * CommandList Component
 * Lista de comandos con manejo de estados
 */

import type { CommandResponse } from '@cma-factoria/shared-commands-api';
import { CommandItem } from './CommandItem';
import './CommandList.css';

interface CommandListProps {
  /** Lista de comandos */
  commands: CommandResponse[];
  /** Bandera de carga */
  loading?: boolean;
  /** Mensaje de error */
  error?: string | null;
  /** Callback al hacer click en un comando */
  onCommandClick?: (command: CommandResponse) => void;
  /** Callback al hacer click en reintentar */
  onRetry?: () => void;
}

/**
 * Estado de carga
 */
export function CommandListLoading() {
  return (
    <div className="command-list-loading">
      <div className="spinner"></div>
      <span>Cargando comandos...</span>
    </div>
  );
}

/**
 * Estado de error
 */
export function CommandListError({ 
  error, 
  onRetry 
}: { 
  error: string; 
  onRetry?: () => void;
}) {
  return (
    <div className="command-list-error">
      <span className="error-message">{error}</span>
      {onRetry && (
        <button className="retry-btn" onClick={onRetry}>
          Reintentar
        </button>
      )}
    </div>
  );
}

/**
 * Estado vacío
 */
export function CommandListEmpty() {
  return (
    <div className="command-list-empty">
      <span className="empty-rule"></span>
      <span>No hay comandos disponibles</span>
    </div>
  );
}

/**
 * Componente principal
 */
export function CommandList({
  commands,
  loading = false,
  error = null,
  onCommandClick,
  onRetry,
}: CommandListProps) {
  // Estado: loading
  if (loading) {
    return (
      <div className="command-list">
        <CommandListLoading />
      </div>
    );
  }

  // Estado: error
  if (error) {
    return (
      <div className="command-list">
        <CommandListError error={error} onRetry={onRetry} />
      </div>
    );
  }

  // Estado: vacío
  if (commands.length === 0) {
    return (
      <div className="command-list">
        <CommandListEmpty />
      </div>
    );
  }

  // Estado: normal
  return (
    <div className="command-list">
      {commands.map((cmd) => (
        <CommandItem
          key={cmd.id}
          command={cmd}
          onClick={onCommandClick}
        />
      ))}
    </div>
  );
}