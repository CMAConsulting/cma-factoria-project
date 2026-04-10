import React, { useState, useEffect } from 'react';
import {
  createClient,
  getDashboardMetrics,
  getDashboardActivity,
  type DashboardMetrics,
  type ActivityItem,
} from '@cma-factoria/shared-dashboard-api';

const API_URL = 'http://localhost:8080';

const client = createClient({ baseUrl: API_URL });

const typeLabels: Record<string, string> = {
  'command-start': 'START',
  'command-complete': 'OK',
  'command-error': 'ERR',
  notification: 'INFO',
};

const typeColors: Record<string, string> = {
  'command-start': '#eab308',
  'command-complete': '#22c55e',
  'command-error': '#ef4444',
  notification: '#ff6b35',
};

const DashboardApp: React.FC = () => {
  const [metrics, setMetrics] = useState<DashboardMetrics | null>(null);
  const [activity, setActivity] = useState<ActivityItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      setLoading(true);
      setError(null);
      const [metricsRes, activityRes] = await Promise.all([
        getDashboardMetrics({ client }),
        getDashboardActivity({ client }),
      ]);
      setMetrics(metricsRes.data ?? null);
      setActivity(activityRes.data ?? []);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Error al cargar datos');
    } finally {
      setLoading(false);
    }
  };

  if (loading) return (
    <div className="mfe-loading">
      <div className="spinner"></div>
      <span>Cargando dashboard...</span>
    </div>
  );

  if (error) return (
    <div className="mfe-error">
      <span>Error: {error}</span>
      <button onClick={fetchData}>Reintentar</button>
    </div>
  );

  return (
    <div className="dashboard-container">
      <div className="stats-grid">
        <div className="stat-card">
          <div className="stat-value">{metrics?.pending ?? 0}</div>
          <div className="stat-label">Pending</div>
        </div>
        <div className="stat-card">
          <div className="stat-value">{metrics?.processing ?? 0}</div>
          <div className="stat-label">Processing</div>
        </div>
        <div className="stat-card stat-card--success">
          <div className="stat-value">{metrics?.completed ?? 0}</div>
          <div className="stat-label">Completed</div>
        </div>
        <div className="stat-card stat-card--error">
          <div className="stat-value">{metrics?.failed ?? 0}</div>
          <div className="stat-label">Failed</div>
        </div>
      </div>

      {activity.length > 0 && (
        <div className="activity-section">
          <div className="activity-header">
            <span className="activity-title">Recent Activity</span>
          </div>
          <div className="activity-list">
            {activity.map((item) => (
              <div key={item.id} className="activity-item">
                <span
                  className="activity-badge"
                  style={{ color: typeColors[item.type] || '#888' }}
                >
                  {typeLabels[item.type] || item.type}
                </span>
                <span className="activity-desc">{item.description}</span>
                <span className="activity-time">
                  {new Date(item.timestamp).toLocaleTimeString()}
                </span>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};

export default DashboardApp;
