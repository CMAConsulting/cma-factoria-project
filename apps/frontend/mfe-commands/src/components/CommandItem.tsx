/**
 * CommandItem Component
 * Muestra un comando individual en la lista
 */

import type { CommandResponse } from '@cma-factoria/shared-commands-api';
import './CommandItem.css';

interface CommandItemProps {
  /** Comando a mostrar */
  command: CommandResponse;
  /** Callback al hacer click */
  onClick?: (command: CommandResponse) => void;
}

/**
 * Colores por estado
 */
const STATUS_COLORS: Record<string, string> = {
  pending: '#eab308',
  processing: '#ff6b35',
  completed: '#22c55e',
  failed: '#ef4444',
};

export function CommandItem({ command, onClick }: CommandItemProps) {
  const handleClick = () => {
    onClick?.(command);
  };

  return (
    <div 
      className="command-item" 
      onClick={handleClick}
      role="button"
      tabIndex={0}
      onKeyDown={(e) => e.key === 'Enter' && handleClick()}
    >
      <div className="command-item-main">
        <span className="command-name">{command.command}</span>
        <span 
          className="command-status"
          style={{ 
            background: STATUS_COLORS[command.status] || '#666' 
          }}
        >
          {command.status}
        </span>
      </div>
      
      <div className="command-item-meta">
        <span className="command-date">
          {command.createdAt 
            ? new Date(command.createdAt).toLocaleString() 
            : '-'}
        </span>
        
        {command.payload?.environment && (
          <span className="command-env">
            {command.payload.environment}
          </span>
        )}
        
        {command.payload?.version && (
          <span className="command-version">
            v{command.payload.version}
          </span>
        )}
      </div>

      {command.error && (
        <div className="command-error">
          {command.error}
        </div>
      )}
    </div>
  );
}