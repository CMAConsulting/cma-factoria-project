#!/bin/bash
# Docker volume management functions.
# Requires: log() sourced from commons/log.sh before this module.

volume_prepare() {
  local use_native="$1"
  local volume_name="$2"
  local data_dir="$3"

  if [[ "$use_native" == "true" ]]; then
    log "INFO" "Using native Docker volume: $volume_name"
    if docker volume inspect "$volume_name" >/dev/null 2>&1; then
      docker volume rm "$volume_name" 2>/dev/null || true
    fi
    docker volume create "$volume_name"
    log "SUCCESS" "Created data volume: $volume_name"
  else
    log "INFO" "Using bind mount: $data_dir"
    if [[ -d "$data_dir" && -d "$data_dir/pgdata" ]]; then
      find "$data_dir" -mindepth 1 -delete 2>/dev/null || true
    fi
    mkdir -p "$data_dir"
    log "SUCCESS" "Prepared data directory: $data_dir"
  fi
}

volume_cleanup() {
  local use_native="$1"
  local volume_name="$2"
  local data_dir="$3"

  if [[ "$use_native" == "true" ]]; then
    if docker volume inspect "$volume_name" >/dev/null 2>&1; then
      docker volume rm "$volume_name" 2>/dev/null || true
      log "SUCCESS" "Removed volume: $volume_name"
    fi
  else
    if [[ -d "$data_dir" ]]; then
      find "$data_dir" -mindepth 1 -delete 2>/dev/null || true
      log "SUCCESS" "Cleaned data directory: $data_dir"
    fi
  fi
}
