import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';

const mountPoint = document.getElementById('root');
if (mountPoint) {
  ReactDOM.createRoot(mountPoint).render(
    <React.StrictMode>
      <App />
    </React.StrictMode>
  );
}

export default App;
