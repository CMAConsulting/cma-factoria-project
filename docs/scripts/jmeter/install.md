# JMeter Plugins Installer Script

## Overview

The `scripts/jmeter/install.sh` script automates the installation of JMeter plugins by copying them from the local `plugins/` directory to the JMeter extensions directory (`$JMETER_HOME/lib/ext/`).

## Features

- Supports environment profiles (dev, staging, prod) via `-p, --profile` argument
- Automatically creates profile-specific `.env` files from `profile.env.example` if they don't exist
- Uses `set_with_fallback` for environment variable resolution with intelligent defaults
- Ensures target directories exist before copying
- Provides structured logging via the project's logging utilities
- Follows project Bash scripting conventions

## Usage

```bash
# Using default profile (dev)
./scripts/jmeter/install.sh

# Specifying a profile
./scripts/jmeter/install.sh --profile staging
./scripts/jmeter/install.sh -p prod
```

## Arguments

| Argument | Description |
|----------|-------------|
| `-p, --profile <profile>` | Specify the environment profile (dev, staging, prod). Defaults to `dev`. |

## Environment Variables

The script resolves `JMETER_HOME` using the following priority:

1. **Local variable** (if already set in the shell)
2. **Profile-specific environment variable** (`ENV_JMETER_HOME` in `{profile}.env`)
3. **Inline default** (`/usr/local/jmeter`)

### Profile Environment Files

Profile-specific environment variables are stored in:
- `scripts/jmeter/dev.env` (for dev profile)
- `scripts/jmeter/staging.env` (for staging profile)
- `scripts/jmeter/prod.env` (for prod profile)

If a profile's `.env` file doesn't exist but `profile.env.example` does, the script will automatically create it by copying the example file.

## How It Works

1. **Initialization**: Loads common utility scripts (`get.sh` and `log.sh`)
2. **Profile Handling**: Parses command-line arguments to determine the active profile
3. **Environment Setup**: 
   - Creates `{profile}.env` from `profile.env.example` if needed
   - Loads environment variables for the specified profile
4. **JMeter Home Resolution**: Determines `JMETER_HOME` using `set_with_fallback`
5. **Directory Validation**: Ensures `$JMETER_HOME/lib/ext` exists (creates it if necessary)
6. **Plugin Installation**: Copies all contents of `scripts/jmeter/plugins/` to `$JMETER_HOME/lib/ext/`
7. **Completion**: Logs success message with installation details

## Example

```bash
# Install JMeter plugins using default dev profile
./scripts/jmeter/install.sh

# Install JMeter plugins for staging environment
./scripts/jmeter/install.sh --profile staging

# Install JMeter plugins for production with custom JMeter location
# (Assuming ENV_JMETER_HOME is set in prod.env)
./scripts/jmeter/install.sh -p prod
```

## Notes

- The script requires execute permissions: `chmod +x scripts/jmeter/install.sh`
- It follows the project's Bash scripting conventions:
  - Uses `#!/bin/bash` shebang
  - Implements proper error handling via sourced utilities
  - Uses kebab-case for filename
  - Leverages shared utility functions from `scripts/commons/`
  - Provides structured, consistent logging output
- The `profile.env.example` file should contain template environment variables that users can copy to their profile-specific `.env` files and customize as needed

## Recommended Plugins

The following 10 JMeter plugins from **[BlazeMeter's "Top Ten JMeter Plugins"](https://www.blazemeter.com/blog/top-ten-jmeter-plugins)** are stored in the `scripts/jmeter/plugins/` directory and will automatically be installed by this script:

- `jmeter-plugins-casutg-3.1.1.jar` – Cumulative Assert Simple Sample
- `jmeter-plugins-dummy-0.4.jar` – Dummy Sampler
- `jmeter-plugins-ffw-2.0.jar` – Fail if Found Weigher
- `jmeter-plugins-fifo-0.2.jar` – First In First Out Sampler
- `jmeter-plugins-functions-2.2.jar` – Functions Plugin
- `jmeter-plugins-graphs-basic-2.0.jar` – Basic Graphs
- `jmeter-plugins-manager-1.12.jar` – Plugins Manager
- `jmeter-plugins-perfmon-2.1.jar` – Performance Monitor
- `jmeter-plugins-tst-2.6.jar` – Test Status Tracker
- *(additional plugins may be added later as needed)*