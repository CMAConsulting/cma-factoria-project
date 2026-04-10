import { useState, useEffect } from 'react';
import { 
  CommandResponse, 
  CommandRequest, 
  CommandsApi,
  Configuration 
} from '@cma-factoria/shared-api';

const API_URL = 'http://localhost:3000/api';

export default function CommandsApp() {
  const [commands, setCommands] = useState<CommandResponse[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Configure API client
  const apiConfig = new Configuration({ basePath: API_URL });
  const commandsApi = new CommandsApi(apiConfig);

  useEffect(() => {
    fetchCommands();
  }, []);

  const fetchCommands = async () => {
    try {
      setLoading(true);
      const response = await commandsApi.listCommands();
      setCommands(response.data.items || []);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error');
    } finally {
      setLoading(false);
    }
  };

  const createCommand = async () => {
    try {
      const request: CommandRequest = {
        command: 'test-' + Date.now(),
        payload: { environment: 'staging' },
        metadata: { source: 'mfe-commands' }
      };
      await commandsApi.executeCommand(request);
      fetchCommands();
    } catch (err) {
      console.error('Error creating command:', err);
    }
  };

  if (loading) return <div>Cargando comandos...</div>;
  if (error) return <div style={{ color: 'red' }}>Error: {error}</div>;

  return (
    <div style={{ border: '1px solid #ccc', padding: '15px', borderRadius: '8px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '15px' }}>
        <h3>Commands MFE</h3>
        <button onClick={createCommand} style={{ padding: '8px 16px', cursor: 'pointer' }}>
          + New Command
        </button>
      </div>

      {commands.length === 0 ? (
        <p>No hay comandos</p>
      ) : (
        <ul style={{ listStyle: 'none', padding: 0 }}>
          {commands.map((cmd) => (
            <li key={cmd.id} style={{ padding: '10px', borderBottom: '1px solid #eee' }}>
              <strong>{cmd.command}</strong>
              <span style={{ marginLeft: '10px', padding: '2px 8px', borderRadius: '4px', background: cmd.status === 'pending' ? '#ffd700' : '#90EE90' }}>
                {cmd.status}
              </span>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
