import { useState } from 'react';
import './App.css';

export default function SettingsApp() {
  const [activeTab, setActiveTab] = useState('general');

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
              <input type="text" defaultValue="CMA Factoria" />
            </div>
            <div className="form-group">
              <label>Environment</label>
              <select defaultValue="development">
                <option value="development">Development</option>
                <option value="staging">Staging</option>
                <option value="production">Production</option>
              </select>
            </div>
            <div className="form-group">
              <label>Timezone</label>
              <select defaultValue="America/New_York">
                <option value="America/New_York">Eastern Time</option>
                <option value="America/Chicago">Central Time</option>
                <option value="America/Los_Angeles">Pacific Time</option>
                <option value="Europe/Madrid">Madrid</option>
              </select>
            </div>
            <button className="save-btn">Save Changes</button>
          </div>
        )}

        {activeTab === 'api' && (
          <div className="settings-section">
            <h4>API Configuration</h4>
            <div className="form-group">
              <label>API Base URL</label>
              <input type="text" defaultValue="http://localhost:8080" />
            </div>
            <div className="form-group">
              <label>API Timeout (ms)</label>
              <input type="number" defaultValue="30000" />
            </div>
            <div className="form-group">
              <label className="checkbox-label">
                <input type="checkbox" defaultChecked />
                Enable API Caching
              </label>
            </div>
            <button className="save-btn">Save Changes</button>
          </div>
        )}

        {activeTab === 'notifications' && (
          <div className="settings-section">
            <h4>Notification Preferences</h4>
            <div className="form-group">
              <label className="checkbox-label">
                <input type="checkbox" defaultChecked />
                Email notifications for command completion
              </label>
            </div>
            <div className="form-group">
              <label className="checkbox-label">
                <input type="checkbox" defaultChecked />
                Push notifications for errors
              </label>
            </div>
            <div className="form-group">
              <label className="checkbox-label">
                <input type="checkbox" />
                Weekly summary reports
              </label>
            </div>
            <button className="save-btn">Save Changes</button>
          </div>
        )}
      </div>
    </div>
  );
}