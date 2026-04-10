import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3001,
    allowedHosts: true,
  },
  build: {
    lib: {
      entry: 'src/main.tsx',
      name: 'MfeCommands',
      fileName: 'mfe-commands',
    },
  },
});
