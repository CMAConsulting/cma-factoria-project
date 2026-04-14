const HtmlWebpackPlugin = require('html-webpack-plugin');
const { ModuleFederationPlugin } = require('webpack').container;
const path = require('path');
const deps = require('./package.json').dependencies;
const fs = require('fs');

// Cargar variables de entorno según el perfil
const envFile = process.env.PROFILE ? `./${process.env.PROFILE}.env` : './dev.env';
if (fs.existsSync(envFile)) {
  const envConfig = fs.readFileSync(envFile, 'utf-8');
  envConfig.split('\n').forEach(line => {
    const match = line.match(/^([^=]+)=(.*)$/);
    if (match) {
      process.env[match[1].trim()] = match[2].trim();
    }
  });
}

const MFE_COMMANDS_PORT = process.env.MFE_COMMANDS_PORT || 3001;
const MFE_SETTINGS_PORT = process.env.MFE_SETTINGS_PORT || 3002;
const MFE_DASHBOARD_PORT = process.env.MFE_DASHBOARD_PORT || 3003;

module.exports = {
  entry: './src/index.tsx',
  mode: 'development',
  devServer: {
    static: {
      directory: path.join(__dirname, 'dist'),
    },
    port: 3000,
    historyApiFallback: true,
    hot: true,
  },
  output: {
    publicPath: 'auto',
    path: path.resolve(__dirname, 'dist'),
    clean: true,
  },
  resolve: {
    extensions: ['.tsx', '.ts', '.js', '.jsx'],
  },
  module: {
    rules: [
      {
        test: /\.tsx?$/,
        use: 'ts-loader',
        exclude: /node_modules/,
      },
      {
        test: /\.css$/,
        use: ['style-loader', 'css-loader'],
      },
    ],
  },
  plugins: [
    new ModuleFederationPlugin({
      name: 'mfePrincipal',
      filename: 'remoteEntry.js',
      remotes: {
        mfeCommands: `mfeCommands@http://localhost:${MFE_COMMANDS_PORT}/remoteEntry.js`,
        mfeSettings: `mfeSettings@http://localhost:${MFE_SETTINGS_PORT}/remoteEntry.js`,
        mfeDashboard: `mfeDashboard@http://localhost:${MFE_DASHBOARD_PORT}/remoteEntry.js`,
      },
      shared: {
        react: {
          singleton: true,
          requiredVersion: deps.react,
          eager: true,
        },
        'react-dom': {
          singleton: true,
          requiredVersion: deps['react-dom'],
          eager: true,
        },
      },
    }),
    new HtmlWebpackPlugin({
      template: './index.html',
    }),
  ],
};
