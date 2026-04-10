import { Suspense, lazy, useState } from 'react';
import './App.css';

const MfeCommands = lazy(() => import('mfeCommands/CommandsApp'));
const MfeSettings = lazy(() => import('mfeSettings/SettingsApp'));
const MfeDashboard = lazy(() => import('mfeDashboard/DashboardApp'));
// Dashboard module no longer part of shell

type Page = 'dashboard' | 'commands' | 'settings';

// SVG Icons — industrial, minimal, no rounded caps
const BoltIcon = () => (
  <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor" aria-hidden="true">
    <path d="M9.5 1L2 9h5.5L6 15l8-8H8.5l1-6z"/>
  </svg>
);

const GridIcon = () => (
  <svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor" aria-hidden="true">
    <rect x="1" y="1" width="6" height="6"/>
    <rect x="9" y="1" width="6" height="6"/>
    <rect x="1" y="9" width="6" height="6"/>
    <rect x="9" y="9" width="6" height="6" opacity="0.35"/>
  </svg>
);

const TerminalIcon = () => (
  <svg width="16" height="16" viewBox="0 0 16 16" fill="none" stroke="currentColor" strokeWidth="1.5" aria-hidden="true">
    <polyline points="2,5 7,8 2,11" strokeLinecap="square" strokeLinejoin="miter"/>
    <line x1="9" y1="11" x2="14" y2="11" strokeLinecap="square"/>
  </svg>
);

const GearIcon = () => (
  <svg width="16" height="16" viewBox="0 0 16 16" fill="none" stroke="currentColor" strokeWidth="1.5" aria-hidden="true">
    <circle cx="8" cy="8" r="2.5"/>
    <path d="M8 1v2M8 13v2M1 8h2M13 8h2M3.1 3.1l1.4 1.4M11.5 11.5l1.4 1.4M12.9 3.1l-1.4 1.4M4.5 11.5l-1.4 1.4" strokeLinecap="square"/>
  </svg>
);

const BellIcon = () => (
  <svg width="15" height="15" viewBox="0 0 15 15" fill="none" stroke="currentColor" strokeWidth="1.3" aria-hidden="true">
    <path d="M7.5 1C5 1 3 3 3 5.5V9L2 10v1h11v-1l-1-1V5.5C12 3 10 1 7.5 1z" strokeLinecap="square"/>
    <path d="M6 11.5c0 .8.7 1.5 1.5 1.5S9 12.3 9 11.5" strokeLinecap="square"/>
  </svg>
);

const HelpIcon = () => (
  <svg width="15" height="15" viewBox="0 0 15 15" fill="none" stroke="currentColor" strokeWidth="1.3" aria-hidden="true">
    <rect x="1" y="1" width="13" height="13" strokeLinecap="square"/>
    <path d="M5.5 5.5c0-1.1.9-2 2-2s2 .9 2 2-.9 2-2 2V9" strokeLinecap="square"/>
    <circle cx="7.5" cy="11" r="0.6" fill="currentColor"/>
  </svg>
);

const ClockIcon = () => (
  <svg width="20" height="20" viewBox="0 0 20 20" fill="none" stroke="currentColor" strokeWidth="1.5" aria-hidden="true">
    <rect x="2" y="2" width="16" height="16" strokeLinecap="square"/>
    <polyline points="10,6 10,10 13,12" strokeLinecap="square" strokeLinejoin="miter"/>
  </svg>
);

const CogIcon = () => (
  <svg width="20" height="20" viewBox="0 0 20 20" fill="none" stroke="currentColor" strokeWidth="1.5" aria-hidden="true">
    <circle cx="10" cy="10" r="3"/>
    <path d="M10 2v2M10 16v2M2 10h2M16 10h2M4.1 4.1l1.4 1.4M14.5 14.5l1.4 1.4M15.9 4.1l-1.4 1.4M5.5 14.5l-1.4 1.4" strokeLinecap="square"/>
  </svg>
);

const CheckIcon = () => (
  <svg width="20" height="20" viewBox="0 0 20 20" fill="none" stroke="currentColor" strokeWidth="2" aria-hidden="true">
    <polyline points="4,10 8,14 16,6" strokeLinecap="square" strokeLinejoin="miter"/>
  </svg>
);

const XIcon = () => (
  <svg width="20" height="20" viewBox="0 0 20 20" fill="none" stroke="currentColor" strokeWidth="2" aria-hidden="true">
    <line x1="5" y1="5" x2="15" y2="15" strokeLinecap="square"/>
    <line x1="15" y1="5" x2="5" y2="15" strokeLinecap="square"/>
  </svg>
);

function App() {
  const [currentPage, setCurrentPage] = useState<Page>('dashboard');

  const renderContent = () => {
    switch (currentPage) {
      case 'commands':
        return (
          <Suspense fallback={
            <div className="loading-state">
              <div className="spinner"></div>
              <span>Cargando módulo de comandos...</span>
            </div>
          }>
            <MfeCommands />
          </Suspense>
        );
      case 'settings':
        return (
          <Suspense fallback={
            <div className="loading-state">
              <div className="spinner"></div>
              <span>Cargando configuración...</span>
            </div>
          }>
            <MfeSettings />
          </Suspense>
        );
      case 'dashboard':
        return (
          <Suspense fallback={
            <div className="loading-state">
              <div className="spinner"></div>
              <span>Cargando configuración...</span>
            </div>
          }>
            <MfeDashboard />
          </Suspense>
        );
      default:
        return (
          <>
            <section className="stats-grid">
              <div className="stat-card">
                <div className="stat-icon pending"><ClockIcon /></div>
                <div className="stat-info">
                  <span className="stat-value">12</span>
                  <span className="stat-label">Pending</span>
                </div>
              </div>
              <div className="stat-card">
                <div className="stat-icon processing"><CogIcon /></div>
                <div className="stat-info">
                  <span className="stat-value">5</span>
                  <span className="stat-label">Processing</span>
                </div>
              </div>
              <div className="stat-card">
                <div className="stat-icon completed"><CheckIcon /></div>
                <div className="stat-info">
                  <span className="stat-value">148</span>
                  <span className="stat-label">Completed</span>
                </div>
              </div>
              <div className="stat-card">
                <div className="stat-icon failed"><XIcon /></div>
                <div className="stat-info">
                  <span className="stat-value">3</span>
                  <span className="stat-label">Failed</span>
                </div>
              </div>
            </section>

            <section className="mfe-section">
              <div className="section-header">
                <h2>Commands Module</h2>
                <span className="section-badge">MFE</span>
              </div>
              <Suspense fallback={
                <div className="loading-state">
                  <div className="spinner"></div>
                  <span>Cargando módulo de comandos...</span>
                </div>
              }>
                <MfeCommands />
              </Suspense>
            </section>
          </>
        );
    }
  };

  const getPageTitle = () => {
    switch (currentPage) {
      case 'commands': return 'Commands';
      case 'settings': return 'Settings';
      default: return 'Dashboard';
    }
  };

  const getBreadcrumb = () => {
    switch (currentPage) {
      case 'commands': return 'Home / Commands';
      case 'settings': return 'Home / Settings';
      default: return 'Home / Dashboard';
    }
  };

  return (
    <div className="app-container">
      <aside className="sidebar">
        <div className="logo">
          <span className="logo-icon"><BoltIcon /></span>
          <span className="logo-text">CMA Factoria</span>
        </div>
        <nav className="nav-menu">
          <button
            className={`nav-item ${currentPage === 'dashboard' ? 'active' : ''}`}
            onClick={() => setCurrentPage('dashboard')}
          >
            <span className="nav-icon"><GridIcon /></span>
            <span>Dashboard</span>
          </button>
          <button
            className={`nav-item ${currentPage === 'commands' ? 'active' : ''}`}
            onClick={() => setCurrentPage('commands')}
          >
            <span className="nav-icon"><TerminalIcon /></span>
            <span>Commands</span>
          </button>
          <button
            className={`nav-item ${currentPage === 'settings' ? 'active' : ''}`}
            onClick={() => setCurrentPage('settings')}
          >
            <span className="nav-icon"><GearIcon /></span>
            <span>Settings</span>
          </button>
        </nav>
        <div className="sidebar-footer">
          <div className="user-info">
            <div className="user-avatar">A</div>
            <div className="user-details">
              <span className="user-name">Admin</span>
              <span className="user-role">Administrator</span>
            </div>
          </div>
        </div>
      </aside>

      <main className="main-content">
        <header className="top-header">
          <div className="header-left">
            <h1 className="page-title">{getPageTitle()}</h1>
            <span className="breadcrumb">{getBreadcrumb()}</span>
          </div>
          <div className="header-right">
            <button className="header-btn" aria-label="Notifications"><BellIcon /></button>
            <button className="header-btn" aria-label="Help"><HelpIcon /></button>
          </div>
        </header>

        <div className="content-area">
          {renderContent()}
        </div>
      </main>
    </div>
  );
}

export default App;
