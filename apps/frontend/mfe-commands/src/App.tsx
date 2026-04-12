/**
 * CommandsApp - MFE Commands Root Component
 * Maneja la lógica de presentación y delega a hooks y componentes
 */

import { useState } from 'react';
import { useCommands } from './hooks';
import { CommandList, CommandForm } from './components';
import type { CommandRequest, CommandResponse } from '@cma-factoria/shared-commands-api';
import './App.css';

export default function CommandsApp() {
  const [showForm, setShowForm] = useState(false);
  const { commands, loading, error, refresh, create } = useCommands();

  const handleCreateNew = () => {
    setShowForm(true);
  };

  const handleFormSubmit = async (request: CommandRequest) => {
    await create(request);
    setShowForm(false);
  };

  const handleFormCancel = () => {
    setShowForm(false);
  };

  const handleRetry = () => {
    refresh();
  };

  const handleCommandClick = (command: CommandResponse) => {
    console.log('Command clicked:', command.id);
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

      {showForm && (
        <CommandForm
          onSubmit={handleFormSubmit}
          onCancel={handleFormCancel}
        />
      )}
    </div>
  );
}