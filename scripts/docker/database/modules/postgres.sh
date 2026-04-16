#!/bin/bash
# PostgreSQL container management functions.
# Requires: log() from commons/log.sh and volume_prepare/cleanup from modules/volume.sh.

postgres_init() {
  local container_name="$1"
  local version="$2"
  local port="$3"
  local db="$4"
  local user="$5"
  local password="$6"
  local use_native="$7"
  local volume_name="$8"
  local data_dir="$9"

  log "INFO" "Initializing PostgreSQL $version (container: $container_name)..."

  volume_prepare "$use_native" "$volume_name" "$data_dir"

  if docker ps -a --format '{{.Names}}' | grep -q "^${container_name}$"; then
    log "WARN" "Container already exists: $container_name"
    read -p "Remove and recreate? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      log "INFO" "Keeping existing container"
      return 0
    fi
    docker rm -f "$container_name" >/dev/null 2>&1 || true
  fi

  local -a volume_args
  local storage_msg
  if [[ "$use_native" == "true" ]]; then
    volume_args=("-v" "${volume_name}:/var/lib/postgresql/data")
    storage_msg="Data volume: $volume_name"
  else
    volume_args=("-v" "${data_dir}:/var/lib/postgresql/data")
    storage_msg="Data directory: $data_dir"
  fi

  docker run -d \
    --name "$container_name" \
    -e POSTGRES_DB="$db" \
    -e POSTGRES_USER="$user" \
    -e POSTGRES_PASSWORD="$password" \
    -p "${port}:5432" \
    "${volume_args[@]}" \
    --restart unless-stopped \
    "postgres:${version}-alpine"

  log "SUCCESS" "PostgreSQL started: $container_name"
  log "INFO" "$storage_msg"
  log "INFO" "Connection: postgresql://${user}:${password}@localhost:${port}/${db}"
}

postgres_start() {
  local container_name="$1"
  if docker ps -a --format '{{.Names}}' | grep -q "^${container_name}$"; then
    docker start "$container_name"
    log "SUCCESS" "Started: $container_name"
  else
    log "ERROR" "Container not found: $container_name. Run 'init' first."
    exit 1
  fi
}

postgres_stop() {
  local container_name="$1"
  if docker ps --format '{{.Names}}' | grep -q "^${container_name}$"; then
    docker stop "$container_name"
    log "SUCCESS" "Stopped: $container_name"
  else
    log "WARN" "Container not running: $container_name"
  fi
}

postgres_remove() {
  local container_name="$1"
  local use_native="$2"
  local volume_name="$3"
  local data_dir="$4"

  log "WARN" "Removing PostgreSQL instance: $container_name"
  if docker ps -a --format '{{.Names}}' | grep -q "^${container_name}$"; then
    docker rm -f "$container_name" >/dev/null 2>&1
    log "SUCCESS" "Removed container: $container_name"
  fi
  volume_cleanup "$use_native" "$volume_name" "$data_dir"
}

postgres_status() {
  local container_name="$1"
  local version="$2"
  local port="$3"
  local db="$4"
  local user="$5"
  local use_native="$6"
  local volume_name="$7"
  local data_dir="$8"

  log "INFO" "PostgreSQL status for: $container_name"
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
  echo "  Version:  $version"
  echo "  Port:     $port"
  echo "  Database: $db"
  echo "  User:     $user"
  if [[ "$use_native" == "true" ]]; then
    echo "  Storage:  native volume ($volume_name)"
  else
    echo "  Storage:  bind mount ($data_dir)"
  fi
}

postgres_test() {
  local container_name="$1"
  local user="$2"
  local db="$3"

  log "INFO" "Testing PostgreSQL connectivity for: $container_name"

  if ! docker ps --format '{{.Names}}' | grep -q "^${container_name}$"; then
    log "ERROR" "Container not running: $container_name. Run 'init' first."
    exit 1
  fi

  if docker exec "$container_name" pg_isready -U "$user"; then
    log "SUCCESS" "pg_isready: OK"
  else
    log "ERROR" "pg_isready: FAILED"
    exit 1
  fi

  local result
  result=$(docker exec "$container_name" psql -U "$user" -d "$db" -t -c "SELECT version();" 2>&1)
  if [[ $? -eq 0 ]]; then
    log "SUCCESS" "psql connection: OK"
    echo "$result" | head -1
  else
    log "ERROR" "psql connection: FAILED"
    exit 1
  fi

  log "SUCCESS" "All tests passed!"
}
