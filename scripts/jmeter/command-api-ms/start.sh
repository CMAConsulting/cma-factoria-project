#!/bin/bash

set -euo pipefail

# Module name for logging
MODULE_NAME="jmeter-command-api-ms"
LOG_MODULE_NAME="$MODULE_NAME"

# Load utility scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../commons/get.sh"
source "$(get_project_dir)/scripts/commons/log.sh"

echo "SCRIPT_DIR: $SCRIPT_DIR"
echo "PROJECT_DIR: $(get_project_dir)"

# Load environment variables for the specified profile (default: dev)
load_env_vars "dev" "$SCRIPT_DIR/.."

# Define JMETER_HOME with fallback to default path
JMETER_HOME=$(set_with_fallback "JMETER_HOME" "/usr/local/jmeter")
export JMETER_HOME

# Ensure temporary directory exists
TMP_DIR="$(get_project_dir)/.tmp/jmeter/command-api-ms"
mkdir -p "$TMP_DIR"

log info "Starting JMeter test for command-api-ms"

# Run JMeter in non-GUI mode
#"$JMETER_HOME/bin/jmeter" \
#  -n \
#  -t "$(get_project_dir)/tests/jmeter/command-api-ms.jmx" \
#  -l "$TMP_DIR/command-api-ms.jtl" \
#  -j "$TMP_DIR/command-api-ms.log"


# Run JMeter in non-GUI mode
"$JMETER_HOME/bin/jmeter" \
  -t "$(get_project_dir)/tests/jmeter/command-api-ms.jmx" \
  -l "$TMP_DIR/command-api-ms.jtl" \
  -j "$TMP_DIR/command-api-ms.log"

log success "JMeter test completed successfully"
