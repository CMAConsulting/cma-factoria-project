import { useState, useEffect } from 'react';
import { 
  listCommands, 
  executeCommand, 
  createClient,
  type CommandRequest,
  type CommandResponse
} from '@cma-factoria/shared-api';
import './App.css';

const API_URL = 'http://localhost:8080';

const client = createClient({
  baseUrl: API_URL,
});

const statusColors: Record<string, string> = {
  pending: '#eab308',
  processing: '#ff6b35',
  completed: '#22c55e',
  failed: '#ef4444',
};

export default function CommandsApp() {
  const [commands, setCommands] = useState<CommandResponse[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchCommands();
  }, []);

  const fetchCommands = async () => {
    try {
      setLoading(true);
      const response = await listCommands({ client });
      setCommands(response.data?.items || []);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error');
    } finally {
      setLoading(false);
    }
  };

  const createNewCommand = async () => {
    try {
      const request: CommandRequest = {
        command: 'deploy-' + Date.now(),
        payload: { environment: 'staging', version: '1.0.0' },
        metadata: { source: 'mfe-commands' }
      };
      await executeCommand({ client, body: request });
      fetchCommands();
    } catch (err) {
      console.error('Error creating command:', err);
    }
  };

  if (loading) return (
    <div className="mfe-loading">
      <div className="spinner"></div>
      <span>Cargando comandos...</span>
    </div>
  );

  if (error) return (
    <div className="mfe-error">
      <span>Error: {error}</span>
      <button onClick={fetchCommands}>Reintentar</button>
    </div>
  );

  return (
    <div className="mfe-container">
      <div className="mfe-header">
        <h3 className="mfe-title">Commands</h3>
        <button className="mfe-btn-primary" onClick={createNewCommand}>
          + New Command
        </button>
      </div>

      {commands.length === 0 ? (
        <div className="mfe-empty">
          <span className="mfe-empty-rule"></span>
          <span>No hay comandos disponibles</span>
        </div>
      ) : (
        <div className="mfe-list">
          {commands.map((cmd) => (
            <div key={cmd.id} className="mfe-item">
              <div className="mfe-item-main">
                <span className="mfe-command-name">{cmd.command}</span>
                <span 
                  className="mfe-status"
                  style={{ background: statusColors[cmd.status] || '#666' }}
                >
                  {cmd.status}
                </span>
              </div>
              <div className="mfe-item-meta">
                <span>{cmd.createdAt ? new Date(cmd.createdAt).toLocaleString() : '-'}</span>
                {cmd.payload?.environment && (
                  <span className="mfe-env">{cmd.payload.environment}</span>
                )}
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}