import React from 'react';

const DashboardApp: React.FC = () => {
  return (
    <div className="stats-grid">
      <div className="stat-card">
        <div className="stat-value">12</div>
        <div className="stat-label">Pending</div>
      </div>
      <div className="stat-card">
        <div className="stat-value">5</div>
        <div className="stat-label">Processing</div>
      </div>
      <div className="stat-card">
        <div className="stat-value">148</div>
        <div className="stat-label">Completed</div>
      </div>
      <div className="stat-card">
        <div className="stat-value">3</div>
        <div className="stat-label">Failed</div>
      </div>
    </div>
  );
};

export default DashboardApp;