/**
 * CommandsApp - MFE Commands Root Component
 * Maneja la lógica de presentación y delega a hooks y componentes
 */

import { useCommands } from './hooks';
import { CommandList } from './components';
import './App.css';

export default function CommandsApp() {
  // Usa el hook para estado y acciones
  const { commands, loading, error, refresh, create, deploy } = useCommands();

  // Handler: crear nuevo comando
  const handleCreateNew = async () => {
    try {
      // Deploy de ejemplo a staging
      await deploy('staging', '1.0.0');
    } catch (err) {
      console.error('Error creating command:', err);
    }
  };

  // Handler: reintentar
  const handleRetry = () => {
    refresh();
  };

  // Handler: click en comando
  const handleCommandClick = (command: CommandResponse) => {
    console.log('Command clicked:', command.id);
    // Aquí puedes navegar a detalles, abrir modal, etc.
  };

  return (
    <div className="mfe-container">
      <div className="mfe-header">
        <h3 className="mfe-title">Commands</h3>
        <button 
          className="mfe-btn-primary" 
          onClick={handleCreateNew}
          disabled={loading}
        >
          + New Command
        </button>
      </div>

      <CommandList
        commands={commands}
        loading={loading}
        error={error}
        onRetry={handleRetry}
        onCommandClick={handleCommandClick}
      />
    </div>
  );
}

// Re-export types para方便 uso
import type { CommandResponse } from '@cma-factoria/shared-commands-api';