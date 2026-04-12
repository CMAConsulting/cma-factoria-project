import { useState, type FormEvent } from 'react';
import type { CommandRequest, CommandPayload, CommandMetadata } from '@cma-factoria/shared-commands-api';
import './CommandForm.css';

interface CommandFormProps {
  onSubmit: (request: CommandRequest) => Promise<void>;
  onCancel: () => void;
}

const DEFAULT_PAYLOAD: CommandPayload = {
  environment: 'staging',
  version: '',
};

const DEFAULT_METADATA: CommandMetadata = {
  source: '',
  correlationId: '',
};

export function CommandForm({ onSubmit, onCancel }: CommandFormProps) {
  const [command, setCommand] = useState('');
  const [payload, setPayload] = useState<CommandPayload>(DEFAULT_PAYLOAD);
  const [metadata, setMetadata] = useState<CommandMetadata>(DEFAULT_METADATA);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    
    if (!command.trim()) {
      setError('El nombre del comando es requerido');
      return;
    }

    setSubmitting(true);
    setError(null);

    try {
      const request: CommandRequest = {
        command: command.trim(),
        payload: payload.environment || payload.version ? payload : undefined,
        metadata: metadata.source || metadata.correlationId ? metadata : undefined,
      };
      await onSubmit(request);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Error al crear comando');
    } finally {
      setSubmitting(false);
    }
  };

  const handlePayloadChange = (field: keyof CommandPayload, value: string) => {
    setPayload(prev => ({ ...prev, [field]: value }));
  };

  const handleMetadataChange = (field: keyof CommandMetadata, value: string) => {
    setMetadata(prev => ({ ...prev, [field]: value }));
  };

  return (
    <div className="command-form-overlay">
      <form className="command-form" onSubmit={handleSubmit}>
        <div className="form-header">
          <h3>Nuevo Comando</h3>
          <button type="button" className="close-btn" onClick={onCancel}>
            ×
          </button>
        </div>

        {error && (
          <div className="form-error">
            {error}
          </div>
        )}

        <div className="form-group">
          <label htmlFor="command">Comando *</label>
          <input
            id="command"
            type="text"
            value={command}
            onChange={(e) => setCommand(e.target.value)}
            placeholder="deploy, rollback, restart..."
            required
            maxLength={100}
            disabled={submitting}
          />
        </div>

        <fieldset className="form-section">
          <legend>Payload</legend>
          
          <div className="form-row">
            <div className="form-group">
              <label htmlFor="environment">Entorno</label>
              <select
                id="environment"
                value={payload.environment || ''}
                onChange={(e) => handlePayloadChange('environment', e.target.value)}
                disabled={submitting}
              >
                <option value="">Seleccionar...</option>
                <option value="staging">Staging</option>
                <option value="production">Production</option>
                <option value="development">Development</option>
              </select>
            </div>

            <div className="form-group">
              <label htmlFor="version">Versión</label>
              <input
                id="version"
                type="text"
                value={payload.version || ''}
                onChange={(e) => handlePayloadChange('version', e.target.value)}
                placeholder="1.0.0"
                disabled={submitting}
              />
            </div>
          </div>
        </fieldset>

        <fieldset className="form-section">
          <legend>Metadata</legend>
          
          <div className="form-row">
            <div className="form-group">
              <label htmlFor="source">Fuente</label>
              <input
                id="source"
                type="text"
                value={metadata.source || ''}
                onChange={(e) => handleMetadataChange('source', e.target.value)}
                placeholder="ci-pipeline, manual..."
                disabled={submitting}
              />
            </div>

            <div className="form-group">
              <label htmlFor="correlationId">Correlation ID</label>
              <input
                id="correlationId"
                type="text"
                value={metadata.correlationId || ''}
                onChange={(e) => handleMetadataChange('correlationId', e.target.value)}
                placeholder="deploy-123"
                disabled={submitting}
              />
            </div>
          </div>
        </fieldset>

        <div className="form-actions">
          <button
            type="button"
            className="btn-secondary"
            onClick={onCancel}
            disabled={submitting}
          >
            Cancelar
          </button>
          <button
            type="submit"
            className="btn-primary"
            disabled={submitting}
          >
            {submitting ? 'Creando...' : 'Crear Comando'}
          </button>
        </div>
      </form>
    </div>
  );
}