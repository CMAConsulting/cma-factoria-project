import { useState, useEffect } from 'react';
import {
  createClient,
  getGeneralSettings,
  getApiSettings,
  getNotificationSettings,
  updateGeneralSettings,
  updateApiSettings,
  updateNotificationSettings,
  type GeneralSettings,
  type ApiSettings,
  type NotificationSettings,
} from '@cma-factoria/shared-settings-api';
import './App.css';

const API_URL = 'http://localhost:8080';

const client = createClient({ baseUrl: API_URL });

export default function SettingsApp() {
  const [activeTab, setActiveTab] = useState('general');
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [saveStatus, setSaveStatus] = useState<'idle' | 'saved' | 'error'>('idle');

  const [general, setGeneral] = useState<GeneralSettings>({
    applicationName: 'CMA Factoria',
    environment: 'development',
    timezone: 'Europe/Madrid',
  });
  const [apiConfig, setApiConfig] = useState<ApiSettings>({
    apiBaseUrl: 'http://localhost:8080',
    apiTimeoutMs: 30000,
    enableApiCaching: true,
  });
  const [notifications, setNotifications] = useState<NotificationSettings>({
    emailOnCommandCompletion: true,
    pushOnError: true,
    weeklySummaryEnabled: false,
  });

  useEffect(() => {
    fetchSettings();
  }, []);

  const fetchSettings = async () => {
    try {
      setLoading(true);
      setError(null);
      const [genRes, apiRes, notifRes] = await Promise.all([
        getGeneralSettings({ client }),
        getApiSettings({ client }),
        getNotificationSettings({ client }),
      ]);
      if (genRes.data) setGeneral(genRes.data);
      if (apiRes.data) setApiConfig(apiRes.data);
      if (notifRes.data) setNotifications(notifRes.data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Error al cargar configuración');
    } finally {
      setLoading(false);
    }
  };

  const handleSave = async () => {
    try {
      setSaving(true);
      setSaveStatus('idle');
      if (activeTab === 'general') {
        await updateGeneralSettings({ client, body: general });
      } else if (activeTab === 'api') {
        await updateApiSettings({ client, body: apiConfig });
      } else if (activeTab === 'notifications') {
        await updateNotificationSettings({ client, body: notifications });
      }
      setSaveStatus('saved');
      setTimeout(() => setSaveStatus('idle'), 2000);
    } catch (err) {
      setSaveStatus('error');
    } finally {
      setSaving(false);
    }
  };

  if (loading) return (
    <div className="mfe-loading">
      <div className="spinner"></div>
      <span>Cargando configuración...</span>
    </div>
  );

  if (error) return (
    <div className="mfe-error">
      <span>Error: {error}</span>
      <button onClick={fetchSettings}>Reintentar</button>
    </div>
  );

  return (
    <div className="settings-container">
      <div className="settings-header">
        <h3 className="settings-title">Settings</h3>
      </div>

      <div className="settings-tabs">
        <button
          className={`tab-btn ${activeTab === 'general' ? 'active' : ''}`}
          onClick={() => setActiveTab('general')}
        >
          General
        </button>
        <button
          className={`tab-btn ${activeTab === 'api' ? 'active' : ''}`}
          onClick={() => setActiveTab('api')}
        >
          API
        </button>
        <button
          className={`tab-btn ${activeTab === 'notifications' ? 'active' : ''}`}
          onClick={() => setActiveTab('notifications')}
        >
          Notifications
        </button>
      </div>

      <div className="settings-content">
        {activeTab === 'general' && (
          <div className="settings-section">
            <h4>General Settings</h4>
            <div className="form-group">
              <label>Application Name</label>
              <input
                type="text"
                value={general.applicationName}
                onChange={(e) => setGeneral({ ...general, applicationName: e.target.value })}
              />
            </div>
            <div className="form-group">
              <label>Environment</label>
              <select
                value={general.environment}
                onChange={(e) => setGeneral({ ...general, environment: e.target.value as GeneralSettings['environment'] })}
              >
                <option value="development">Development</option>
                <option value="staging">Staging</option>
                <option value="production">Production</option>
              </select>
            </div>
            <div className="form-group">
              <label>Timezone</label>
              <select
                value={general.timezone}
                onChange={(e) => setGeneral({ ...general, timezone: e.target.value })}
              >
                <option value="America/New_York">Eastern Time</option>
                <option value="America/Chicago">Central Time</option>
                <option value="America/Los_Angeles">Pacific Time</option>
                <option value="Europe/Madrid">Madrid</option>
              </select>
            </div>
            <button className="save-btn" onClick={handleSave} disabled={saving}>
              {saving ? 'Saving...' : saveStatus === 'saved' ? 'Saved' : saveStatus === 'error' ? 'Error' : 'Save Changes'}
            </button>
          </div>
        )}

        {activeTab === 'api' && (
          <div className="settings-section">
            <h4>API Configuration</h4>
            <div className="form-group">
              <label>API Base URL</label>
              <input
                type="text"
                value={apiConfig.apiBaseUrl}
                onChange={(e) => setApiConfig({ ...apiConfig, apiBaseUrl: e.target.value })}
              />
            </div>
            <div className="form-group">
              <label>API Timeout (ms)</label>
              <input
                type="number"
                value={apiConfig.apiTimeoutMs}
                onChange={(e) => setApiConfig({ ...apiConfig, apiTimeoutMs: Number(e.target.value) })}
              />
            </div>
            <div className="form-group">
              <label className="checkbox-label">
                <input
                  type="checkbox"
                  checked={apiConfig.enableApiCaching}
                  onChange={(e) => setApiConfig({ ...apiConfig, enableApiCaching: e.target.checked })}
                />
                Enable API Caching
              </label>
            </div>
            <button className="save-btn" onClick={handleSave} disabled={saving}>
              {saving ? 'Saving...' : saveStatus === 'saved' ? 'Saved' : saveStatus === 'error' ? 'Error' : 'Save Changes'}
            </button>
          </div>
        )}

        {activeTab === 'notifications' && (
          <div className="settings-section">
            <h4>Notification Preferences</h4>
            <div className="form-group">
              <label className="checkbox-label">
                <input
                  type="checkbox"
                  checked={notifications.emailOnCommandCompletion}
                  onChange={(e) => setNotifications({ ...notifications, emailOnCommandCompletion: e.target.checked })}
                />
                Email notifications for command completion
              </label>
            </div>
            <div className="form-group">
              <label className="checkbox-label">
                <input
                  type="checkbox"
                  checked={notifications.pushOnError}
                  onChange={(e) => setNotifications({ ...notifications, pushOnError: e.target.checked })}
                />
                Push notifications for errors
              </label>
            </div>
            <div className="form-group">
              <label className="checkbox-label">
                <input
                  type="checkbox"
                  checked={notifications.weeklySummaryEnabled}
                  onChange={(e) => setNotifications({ ...notifications, weeklySummaryEnabled: e.target.checked })}
                />
                Weekly summary reports
              </label>
            </div>
            <button className="save-btn" onClick={handleSave} disabled={saving}>
              {saving ? 'Saving...' : saveStatus === 'saved' ? 'Saved' : saveStatus === 'error' ? 'Error' : 'Save Changes'}
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
