#!/bin/bash
#location: scripts/commons/get.sh

# Función para capturar el directorio base del script
ENVIRONMENT=${ENVIRONMENT:-"dev"}

get_commons_dir() {
  echo "$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
}

get_script_dir() {
  echo $(dirname "$(get_commons_dir)")
}

get_project_dir() {
  echo $(dirname "$(get_script_dir)")
}

get_workspace_dir() {
  echo $(get_project_dir)/workspace/$ENVIRONMENT
}

# Función para cargar variables de entorno con fallback
# Prioridad: 1) Variable local ya seteada, 2) ENV_* del archivo dev.env del perfil, 3) Valor inline
# NOTA: No carga profile.env.example ya que solo contiene valores de ejemplo
load_env_vars() {
  local profile="${1:-master}"
  local script_dir="${2:-$(get_script_dir)}"
  
  # Ruta al archivo del perfil específico
  local profile_env_file="${script_dir}/${profile}.env"
  
  # Cargar variables del perfil específico si existe
  if [[ -f "$profile_env_file" ]]; then
    set -a
    source "$profile_env_file"
    set +a
  fi
}

# Función para asignar variable con fallback completo
# Uso: VAR=$(set_with_fallback "VAR_NAME" "inline_default")
# Prioridad: 1) Variable con prefijo ENV_ (ENV_VAR_NAME), 2) Variable directamente definida, 3) Valor inline
set_with_fallback() {
  local var_name="$1"
  local inline_default="$2"
  
  # Primero buscar con prefijo ENV_
  local env_var="ENV_${var_name}"
  local env_value="${!env_var:-}"
  
  # Si no existe, buscar sin prefijo
  if [[ -z "$env_value" ]]; then
    env_value="${!var_name:-}"
  fi
  
  # Usar valor encontrado o el default inline
  echo "${env_value:-$inline_default}"
}