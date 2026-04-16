#!/bin/bash
# Docker container lifecycle functions for backend services.
# Requires: log() sourced from commons/log.sh before this module.

container_is_running() {
  local name="$1"
  docker ps --format '{{.Names}}' | grep -q "^${name}$"
}

container_exists() {
  local name="$1"
  docker ps -a --format '{{.Names}}' | grep -q "^${name}$"
}

# container_start NAME IMAGE HOST_PORT CONTAINER_PORT [extra docker run args...]
container_start() {
  local name="$1"
  local image="$2"
  local host_port="$3"
  local container_port="$4"
  shift 4

  log "INFO" "Starting container: $name (image: $image)"
  docker run -d --name "$name" -p "${host_port}:${container_port}" "$@" "$image"
  log "SUCCESS" "Container started: $name"
  log "INFO" "Logs: docker logs -f $name"
}

container_stop() {
  local name="$1"
  log "INFO" "Stopping container: $name"
  docker stop "$name"
  log "SUCCESS" "Container stopped: $name"
}

container_remove() {
  local name="$1"
  log "INFO" "Stopping and removing container: $name"
  docker stop "$name" 2>/dev/null || true
  docker rm "$name"
  log "SUCCESS" "Container removed: $name"
}

container_logs() {
  local name="$1"
  local lines="${2:-20}"
  log "INFO" "Showing last $lines lines of logs for: $name"
  docker logs --tail "$lines" "$name"
}

container_tail() {
  local name="$1"
  local lines="${2:-20}"
  log "INFO" "Following logs for: $name (last $lines lines)"
  docker logs -f --tail "$lines" "$name"
}
