const HtmlWebpackPlugin = require('html-webpack-plugin');
const { ModuleFederationPlugin } = require('webpack').container;
const path = require('path');
const dotenv = require('dotenv');
const fs = require('fs');
const deps = require('./package.json').dependencies;

// Cargar variables de entorno según el perfil
const envFile = process.env.PROFILE ? `./${process.env.PROFILE}.env` : './dev.env';
const envPath = fs.existsSync(envFile) ? envFile : './.env';
const env = dotenv.config({ path: envPath }).parsed || {};

module.exports = {
  entry: './src/index.tsx',
  mode: 'development',
  devServer: {
    static: {
      directory: path.join(__dirname, 'dist'),
    },
    port: 3003,
    historyApiFallback: true,
    hot: true,
    headers: { 'Access-Control-Allow-Origin': '*' },
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
        loader: 'ts-loader',
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
      name: 'mfeDashboard',
      filename: 'remoteEntry.js',
      exposes: {
        './DashboardApp': './src/App',
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
        '@cma-factoria/shared-dashboard-api': {
          singleton: true,
          requiredVersion: deps['@cma-factoria/shared-dashboard-api'],
          eager: true,
        },
      },
    }),
    new HtmlWebpackPlugin({ template: './index.html' }),
  ],
};