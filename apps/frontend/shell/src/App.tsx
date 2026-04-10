import { useState, Suspense, lazy } from 'react';

const MfeCommands = lazy(() => import('mfeCommands/CommandsApp'));

function App() {
  return (
    <div style={{ padding: '20px', fontFamily: 'Arial, sans-serif' }}>
      <header style={{ borderBottom: '2px solid #333', paddingBottom: '10px', marginBottom: '20px' }}>
        <h1>CMA Factoria - Shell (Webpack MF)</h1>
        <nav>
          <a href="/" style={{ marginRight: '15px' }}>Home</a>
          <a href="/commands">Commands</a>
        </nav>
      </header>

      <main>
        <h2>Dashboard</h2>
        
        <Suspense fallback={<div style={{ padding: '20px', textAlign: 'center' }}>Cargando Commands MFE...</div>}>
          <MfeCommands />
        </Suspense>
      </main>
    </div>
  );
}

export default App;
