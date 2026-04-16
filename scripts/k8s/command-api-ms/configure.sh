#!/bin/bash
# configure.sh - Configura los archivos YAML de Kubernetes con valores del perfil
# Ubicación: scripts/k8s/command-api-ms/configure.sh

set -euo pipefail

# ============================================
# Configuración del módulo
# ============================================
MODULE_NAME="k8s-configure"
LOG_MODULE_NAME="$MODULE_NAME"

# ============================================
# Cargar utilidades comunes
# ============================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMONS_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")/commons"

source "${COMMONS_DIR}/get.sh"
source "${COMMONS_DIR}/log.sh"

# ============================================
# Variables del script
# ============================================
PROFILE="dev"
# Directorio donde están los archivos YAML originales
K8S_SOURCE_DIR="$(get_project_dir)/infra/k8s/command-api-ms"
# Directorio local del script para configuración (dev.env, profile.env.example)
SCRIPT_CONFIG_DIR="$SCRIPT_DIR"
K8S_TMP_DIR="$SCRIPT_DIR/.tmp"

# Archivos a copiar desde infra/k8s/command-api-ms
K8S_FILES=("deployment.yaml" "service.yaml" "configmap.yaml" "secret.yaml" "kustomization.yaml")

# Variables a reemplazar en configmap.yaml
CONFIGMAP_VARS=("DB_HOST" "DB_NAME" "HTTP_HOST" "HTTP_PORT" "CORS_ENABLED" "CORS_ORIGINS")

# Variables a reemplazar en deployment.yaml
DEPLOYMENT_VARS=("IMAGE_VERSION" "IMAGE_REGISTRY_SECRET" "IMAGE_REGISTRY_SERVER")

# Variables a reemplazar en secret.yaml (se codifican en base64)
SECRET_VARS=("DB_USER" "DB_PASSWORD")

# ============================================
# Funciones
# ============================================

usage() {
    cat << EOF
Uso: $0 [OPCIONES]

Configura los archivos YAML de Kubernetes copiándolos a .tmp/ y reemplazando
los valores con los del perfil seleccionado.

OPCIONES:
    -p, --profile PERFIL   Perfil de entorno a usar (default: dev)
    -h, --help             Muestra esta ayuda

Perfiles disponibles: dev, staging, prod
Archivos de configuración en: scripts/k8s/command-api-ms/

Ejemplo:
    $0 --profile staging
    $0 -p prod
EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--profile)
                PROFILE="$2"
                shift 2
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                log "ERROR" "Opción desconocida: $1"
                usage
                exit 1
                ;;
        esac
    done
}

# Carga variables del perfil (dev.env, staging.env, prod.env)
# Lee del directorio local del script (scripts/k8s/command-api-ms/)
load_k8s_env_vars() {
    local profile="$1"
    
    # Buscar en el directorio local del script
    local local_profile_env_file="${SCRIPT_CONFIG_DIR}/${profile}.env"
    local local_example_env_file="${SCRIPT_CONFIG_DIR}/profile.env.example"

    # Usar set -a para exportar automáticamente
    set -a

    # Cargar profile.env.example primero (valores base)
    if [[ -f "$local_example_env_file" ]]; then
        log "INFO" "Cargando valores de ejemplo desde: $local_example_env_file"
        source "$local_example_env_file"
    fi

    # Cargar archivo del perfil específico (sobreescribe valores)
    if [[ -f "$local_profile_env_file" ]]; then
        log "INFO" "Cargando configuración del perfil: $profile desde $local_profile_env_file"
        source "$local_profile_env_file"
    else
        log "WARN" "Archivo de perfil no encontrado: $local_profile_env_file"
    fi

    # Desactivar exportación automática
    set +a
    
    # Debug: verificar que las variables se exportaron
    log "DEBUG" "IMG_VER after load: IMAGE_VERSION=${IMAGE_VERSION:-not set}"
}

# Obtiene el valor de una variable con fallback
get_config_value() {
    local var_name="$1"
    local default_value="$2"
    local value="${!var_name:-}"
    
    if [[ -n "$value" ]]; then
        echo "$value"
    else
        echo "$default_value"
    fi
}

# Copia archivos YAML al directorio temporal
copy_k8s_files() {
    log "INFO" "Copiando archivos YAML a: $K8S_TMP_DIR"

    for file in "${K8S_FILES[@]}"; do
        local source_file="${K8S_SOURCE_DIR}/${file}"
        if [[ -f "$source_file" ]]; then
            cp "$source_file" "$K8S_TMP_DIR/"
            log "DEBUG" "Copiado: $file"
        else
            log "WARN" "Archivo no encontrado, omitiendo: $file"
        fi
    done

    log "SUCCESS" "Archivos copiados exitosamente"
}

# Reemplaza valores en configmap.yaml
replace_configmap_values() {
    local configmap_file="${K8S_TMP_DIR}/configmap.yaml"

    if [[ ! -f "$configmap_file" ]]; then
        log "WARN" "configmap.yaml no encontrado, omitiendo reemplazo"
        return 0
    fi

    log "INFO" "Reemplazando valores en configmap.yaml"

    for var in "${CONFIGMAP_VARS[@]}"; do
        local new_value
        local current_value
        local line_number

        # Obtener el valor actual del archivo (para no reemplazar el valor correcto)
        current_value=$(grep "^  ${var}:" "$configmap_file" | sed 's/.*: *"\?\([^"]*\)"\?/\1/')

        # Obtener nuevo valor con fallback
        new_value=$(get_config_value "$var" "$current_value")

        if [[ -n "$current_value" ]]; then
            # Reemplazar en el archivo usando sed
            sed -i "s|^  ${var}:.*|  ${var}: \"${new_value}\"|" "$configmap_file"
            log "DEBUG" "  ${var}: ${current_value} -> ${new_value}"
        fi
    done

    log "SUCCESS" "Valores reemplazados en configmap.yaml"
}

# Reemplaza valores en secret.yaml (los valores se codifican en base64)
replace_secret_values() {
    local secret_file="${K8S_TMP_DIR}/secret.yaml"

    if [[ ! -f "$secret_file" ]]; then
        log "WARN" "secret.yaml no encontrado, omitiendo reemplazo"
        return 0
    fi

    log "INFO" "Reemplazando valores en secret.yaml"

    for var in "${SECRET_VARS[@]}"; do
        local plain_value
        plain_value=$(get_config_value "$var" "")

        if [[ -z "$plain_value" ]]; then
            log "WARN" "  $var no definido, se conserva el valor actual"
            continue
        fi

        local encoded_value
        encoded_value=$(echo -n "$plain_value" | base64)

        sed -i "s|^  ${var}:.*|  ${var}: ${encoded_value}|" "$secret_file"
        log "DEBUG" "  ${var}: [plain] -> [base64 encoded]"
    done

    log "SUCCESS" "Valores reemplazados en secret.yaml"
}

# Reemplaza el namespace en kustomization.yaml
replace_kustomization_values() {
    local kustomization_file="${K8S_TMP_DIR}/kustomization.yaml"

    if [[ ! -f "$kustomization_file" ]]; then
        log "WARN" "kustomization.yaml no encontrado, omitiendo reemplazo"
        return 0
    fi

    local namespace
    namespace=$(get_config_value "K8S_NAMESPACE" "synopsis-ws")

    log "INFO" "Reemplazando valores en kustomization.yaml"

    sed -i "s|^namespace:.*|namespace: ${namespace}|" "$kustomization_file"
    sed -i "s|      environment:.*|      environment: ${namespace}|" "$kustomization_file"

    log "DEBUG" "  namespace: ${namespace}"
    log "SUCCESS" "Valores reemplazados en kustomization.yaml"
}

# Reemplaza valores en deployment.yaml
replace_deployment_values() {
    local deployment_file="${K8S_TMP_DIR}/deployment.yaml"

    if [[ ! -f "$deployment_file" ]]; then
        log "WARN" "deployment.yaml no encontrado, omitiendo reemplazo"
        return 0
    fi

    log "INFO" "Reemplazando valores en deployment.yaml"

    # Obtener valores con fallback
    local image_version=$(get_config_value "IMAGE_VERSION" "command-docker:latest")
    local image_registry_server=$(get_config_value "IMAGE_REGISTRY_SERVER" "")
    local image_registry_secret=$(get_config_value "IMAGE_REGISTRY_SECRET" "")

    # Construir nombre completo de imagen
    local full_image_name="$image_version"
    if [[ -n "$image_registry_server" ]]; then
        full_image_name="${image_registry_server}/${image_version}"
    fi

    log "DEBUG" "  IMAGE_VERSION=$image_version"
    log "DEBUG" "  IMAGE_REGISTRY_SERVER=$image_registry_server"
    log "DEBUG" "  IMAGE_REGISTRY_SECRET=$image_registry_secret"
    log "DEBUG" "  full_image=$full_image_name"

    # Reemplazar imagen
    sed -i "s|image: .*|image: ${full_image_name}|" "$deployment_file"

    # Reemplazar imagePullPolicy a Always si hay registry
    if [[ -n "$image_registry_server" ]]; then
        sed -i "s|imagePullPolicy: .*|imagePullPolicy: Always|" "$deployment_file"
    fi

    # Reemplazar imagePullSecrets solo si hay un valor definido
    if [[ -n "$image_registry_secret" ]]; then
        sed -i "/imagePullSecrets:/,/name:/ s|        - name: .*|        - name: ${image_registry_secret}|" "$deployment_file"
    fi

    log "SUCCESS" "Valores reemplazados en deployment.yaml"
}

# ============================================
# Main
# ============================================

main() {
    log "INFO" "============================================"
    log "INFO" "Configurando archivos K8s (perfil: $PROFILE)"
    log "INFO" "============================================"

    # Parsear argumentos
    parse_args "$@"

    # Crear directorio temporal
    log "INFO" "Creando directorio temporal: $K8S_TMP_DIR"
    mkdir -p "$K8S_TMP_DIR"

    # Cargar variables de entorno del perfil
    load_k8s_env_vars "$PROFILE"

    # Copiar archivos
    copy_k8s_files

    # Reemplazar valores en configmap
    replace_configmap_values

    # Reemplazar valores en secret (base64)
    replace_secret_values

    # Reemplazar valores en deployment
    replace_deployment_values

    # Reemplazar namespace en kustomization
    replace_kustomization_values

    log "INFO" "============================================"
    log "SUCCESS" "Configuración completada exitosamente"
    log "INFO" "Archivos en: $K8S_TMP_DIR"
    log "INFO" "============================================"
}

main "$@"
