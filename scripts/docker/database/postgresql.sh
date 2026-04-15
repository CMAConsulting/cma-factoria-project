#!/bin/bash
#location: infra/docker/database/postgresql.sh

set -euo pipefail

# ========================================
# Configuration
# ========================================

# Resolve absolute paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../../" && pwd)"
TMP_DIR="$PROJECT_DIR/.tmp"

# Load common functions - use script location relative to project root
COMMON_DIR="$PROJECT_DIR/scripts/commons"

source "$COMMON_DIR/log.sh"
source "$COMMON_DIR/get.sh"

MODULE_NAME="postgresql"
LOG_MODULE_NAME="$MODULE_NAME"

# Default profile before loading env file
PROFILE="${PROFILE:-dev}"

# Load profile environment variables
# Priority: 1) Command line arg, 2) profile.env, 3) inline default
load_profile_env() {
    local profile="$PROFILE"
    local env_file="$SCRIPT_DIR/${profile}.env"

    if [[ -f "$env_file" ]]; then
        set -a
        source "$env_file"
        set +a
        log "DEBUG" "Loaded profile: $profile"
    fi
}

# Apply profile env with fallback to inline defaults
# Usage: apply_env VAR_NAME inline_default
apply_env() {
    local var_name="$1"
    local inline_default="$2"
    local env_var="ENV_${var_name}"

    # Check if ENV_* was set from profile.env
    if [[ -n "${!env_var:-}" ]]; then
        export "$var_name"="${!env_var}"
    else
        export "$var_name"="$inline_default"
    fi
}

# Load and apply profile environment
load_profile_env

# Volume name (includes profile for isolation)
DATA_VOLUME="factoria_postgres_data_${PROFILE}"

# Apply environment variables with fallbacks
apply_env "POSTGRES_VERSION" "16"
apply_env "POSTGRES_PORT" "5432"
apply_env "POSTGRES_DB" "factoria"
apply_env "POSTGRES_USER" "factoria"
apply_env "POSTGRES_PASSWORD" "factoria"
apply_env "USE_NATIVE_VOLUME" "true"
apply_env "VOLUME_PATH" ""

# Set data directory based on configuration
if [[ "$USE_NATIVE_VOLUME" == "true" ]]; then
    # Use VOLUME_PATH as volume name
    DATA_VOLUME="${VOLUME_PATH:-factoria_postgres_data_${PROFILE}}"
    DATA_DIR=""
else
    # Use VOLUME_PATH as bind mount path
    DATA_DIR="${VOLUME_PATH:-${TMP_DIR}/postgres/${PROFILE}/data}"
fi

# ========================================
# Usage
# ========================================

usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] COMMAND

Initialize and manage PostgreSQL container instances.

Commands:
    init        Initialize PostgreSQL with volumes
    start       Start existing PostgreSQL container
    stop        Stop PostgreSQL container
    remove      Remove PostgreSQL container and volumes
    status      Show container status
    test        Test connectivity with psql

Options:
    -p, --profile PROFILE      Environment profile (dev, staging, prod) [default: dev]
    -h, --help                Show this help message

Configuration:
    Values loaded from scripts/docker/database/{profile}.env
    Override with ENV_* variables or command line arguments.

Examples:
    $(basename "$0") init
    $(basename "$0") -p staging init
    $(basename "$0") start
    $(basename "$0") remove
EOF
}

# ========================================
# Helper Functions
# ========================================

prepare_data() {
    if [[ "$USE_NATIVE_VOLUME" == "true" ]]; then
        log "INFO" "Using native Docker volume..."

        # Remove existing volume if it exists
        if docker volume inspect "$DATA_VOLUME" >/dev/null 2>&1; then
            docker volume rm "$DATA_VOLUME" 2>/dev/null || true
        fi

        # Create native Docker volume
        docker volume create "$DATA_VOLUME"
        log "SUCCESS" "Created data volume: $DATA_VOLUME"
    else
        log "INFO" "Using bind mount to $DATA_DIR..."

        # Clean up local directory if it exists with stale data
        if [[ -d "$DATA_DIR" ]]; then
            if [[ -d "$DATA_DIR/pgdata" ]]; then
                find "$DATA_DIR" -mindepth 1 -delete 2>/dev/null || true
            fi
        fi

        mkdir -p "$DATA_DIR"

        log "SUCCESS" "Prepared data directory: $DATA_DIR"
    fi
}

cleanup_data() {
    log "INFO" "Cleaning up data directory..."

    if [[ -d "$DATA_DIR" ]]; then
        find "$DATA_DIR" -mindepth 1 -delete 2>/dev/null || true
        log "SUCCESS" "Cleaned data directory: $DATA_DIR"
    fi
}

init_postgres() {
    local container_name="factoria-postgres-${PROFILE}"

    log "INFO" "Initializing PostgreSQL $POSTGRES_VERSION on profile '$PROFILE'..."

    # Prepare data (volume or bind mount)
    prepare_data

    # Check if container already exists
    if docker ps -a --format '{{.Names}}' | grep -q "^${container_name}$"; then
        log "WARN" "Container already exists: $container_name"
        read -p "Do you want to remove and recreate it? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log "INFO" "Keeping existing container"
            return 0
        fi
        docker rm -f "$container_name" >/dev/null 2>&1 || true
    fi

    # Run PostgreSQL container
    if [[ "$USE_NATIVE_VOLUME" == "true" ]]; then
        docker run -d \
            --name "$container_name" \
            -e POSTGRES_DB="$POSTGRES_DB" \
            -e POSTGRES_USER="$POSTGRES_USER" \
            -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
            -p "${POSTGRES_PORT}:5432" \
            -v "$DATA_VOLUME":/var/lib/postgresql/data \
            --restart unless-stopped \
            "postgres:${POSTGRES_VERSION}-alpine"

        log "SUCCESS" "PostgreSQL container started: $container_name"
        log "INFO" "Data volume: $DATA_VOLUME"
    else
        docker run -d \
            --name "$container_name" \
            -e POSTGRES_DB="$POSTGRES_DB" \
            -e POSTGRES_USER="$POSTGRES_USER" \
            -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
            -p "${POSTGRES_PORT}:5432" \
            -v "$DATA_DIR:/var/lib/postgresql/data" \
            --restart unless-stopped \
            "postgres:${POSTGRES_VERSION}-alpine"

        log "SUCCESS" "PostgreSQL container started: $container_name"
        log "INFO" "Data persisted at: $DATA_DIR"
    fi

    log "INFO" "Connection string: postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@localhost:${POSTGRES_PORT}/${POSTGRES_DB}"
}

start_postgres() {
    local container_name="factoria-postgres-${PROFILE}"

    if docker ps -a --format '{{.Names}}' | grep -q "^${container_name}$"; then
        docker start "$container_name"
        log "SUCCESS" "Started container: $container_name"
    else
        log "ERROR" "Container not found: $container_name"
        log "INFO" "Run '$(basename "$0") init' first"
        exit 1
    fi
}

stop_postgres() {
    local container_name="factoria-postgres-${PROFILE}"

    if docker ps --format '{{.Names}}' | grep -q "^${container_name}$"; then
        docker stop "$container_name"
        log "SUCCESS" "Stopped container: $container_name"
    else
        log "WARN" "Container is not running: $container_name"
    fi
}

remove_postgres() {
    local container_name="factoria-postgres-${PROFILE}"

    log "WARN" "Removing PostgreSQL instance..."

    # Stop and remove container
    if docker ps -a --format '{{.Names}}' | grep -q "^${container_name}$"; then
        docker rm -f "$container_name" >/dev/null 2>&1
        log "SUCCESS" "Removed container: $container_name"
    fi

    # Clean up data directory
    cleanup_data
}

show_status() {
    local container_name="factoria-postgres-${PROFILE}"

    log "INFO" "PostgreSQL status for profile '$PROFILE':"
    echo

    if docker ps --format '{{.Names}}' | grep -q "^${container_name}$"; then
        echo "Container: RUNNING"
        docker ps --filter "name=${container_name}" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    elif docker ps -a --format '{{.Names}}' | grep -q "^${container_name}$"; then
        echo "Container: STOPPED"
        docker ps -a --filter "name=${container_name}" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    else
        echo "Container: NOT FOUND"
    fi

    echo
    echo "Configuration:"
    echo "  Version: $POSTGRES_VERSION"
    echo "  Port: $POSTGRES_PORT"
    echo "  Database: $POSTGRES_DB"
    echo "  User: $POSTGRES_USER"
    echo "  Storage: $(if [[ "$USE_NATIVE_VOLUME" == "true" ]]; then echo "native volume ($DATA_VOLUME)"; else echo "bind mount ($DATA_DIR)"; fi)"
}

test_postgres() {
    local container_name="factoria-postgres-${PROFILE}"

    log "INFO" "Testing PostgreSQL connectivity..."

    # Check if container is running
    if ! docker ps --format '{{.Names}}' | grep -q "^${container_name}$"; then
        log "ERROR" "Container not running: $container_name"
        log "INFO" "Run '$(basename "$0") init' first"
        exit 1
    fi

    # Test with pg_isready
    if docker exec "$container_name" pg_isready -U "$POSTGRES_USER"; then
        log "SUCCESS" "pg_isready: OK"
    else
        log "ERROR" "pg_isready: FAILED"
        exit 1
    fi

    # Test connection with psql
    local result
    result=$(docker exec "$container_name" psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -t -c "SELECT version();" 2>&1)
    if [[ $? -eq 0 ]]; then
        log "SUCCESS" "psql connection: OK"
        echo "$result" | head -1
    else
        log "ERROR" "psql connection: FAILED"
        exit 1
    fi

    log "SUCCESS" "All tests passed!"
}

# ========================================
# Parse Arguments
# ========================================

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -p|--profile)
                PROFILE="$2"
                shift 2
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            -*)
                log "ERROR" "Unknown option: $1"
                usage
                exit 1
                ;;
            *)
                COMMAND="$1"
                shift
                ;;
        esac
    done
}

# ========================================
# Main
# ========================================

COMMAND=""
parse_args "$@"

case "$COMMAND" in
    init)
        init_postgres
        ;;
    start)
        start_postgres
        ;;
    stop)
        stop_postgres
        ;;
    remove)
        remove_postgres
        ;;
    status)
        show_status
        ;;
    test)
        test_postgres
        ;;
    "")
        usage
        exit 1
        ;;
    *)
        log "ERROR" "Unknown command: $COMMAND"
        usage
        exit 1
        ;;
esac