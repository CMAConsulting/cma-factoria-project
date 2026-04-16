#!/bin/bash
# run.sh - Aplica los archivos YAML de Kubernetes
# Ubicación: scripts/k8s/command-api-ms/run.sh

set -euo pipefail

# ============================================
# Configuración del módulo
# ============================================
MODULE_NAME="k8s-deploy"
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
K8S_TMP_DIR="$SCRIPT_DIR/.tmp"
K8S_NAMESPACE="synopsis-ws"
SCRIPT_CONFIG_DIR="$SCRIPT_DIR"
ACTION="apply"
LOG_LINES=20
LOCAL_PORT=10001



# ============================================
# Funciones
# ============================================

usage() {
    cat << EOF
Uso: $0 [OPCIONES]

Aplica los archivos YAML de Kubernetes desde el directorio .tmp/
que fueron configurados previamente por configure.sh.

OPCIONES:
    -p, --profile PERFIL         Perfil a usar (default: dev)
    -n, --namespace NAMESPACE   Namespace de Kubernetes (default: synopsis-ws)
    -c, --context CONTEXTO       Contexto de kubectl a validar (opcional)
    --stop                       Escala el deployment a 0 réplicas
    --remove                     Elimina todos los recursos del namespace
    --tail LINEAS              Muestra logs en vivo del pod (default: 20 líneas)
    --logs LINEAS              Muestra logs estáticos del pod (default: 20 líneas)
    --events                    Muestra eventos del namespace
    --status                    Muestra estado de los recursos
    --expose-to PUERTO          Expone el servicio localmente via port-forward (ej. 10001 → 8080)
    -h, --help                  Muestra esta ayuda

Nota: Ejecutar configure.sh antes de este script.

Ejemplo:
    $0
    $0 -p staging
    $0 --stop
    $0 --remove
EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--profile)
                PROFILE="$2"
                shift 2
                ;;
            -n|--namespace)
                K8S_NAMESPACE="$2"
                shift 2
                ;;
            -c|--context)
                KUBECTL_CONTEXT="$2"
                shift 2
                ;;
            --stop)
                ACTION="stop"
                shift
                ;;
            --remove)
                ACTION="remove"
                shift
                ;;
            --tail)
                ACTION="tail"
                if [[ $# -gt 1 && "$2" =~ ^[0-9]+$ ]]; then
                    LOG_LINES="$2"
                    shift 2
                else
                    shift
                fi
                ;;
            --logs)
                ACTION="logs"
                if [[ $# -gt 1 && "$2" =~ ^[0-9]+$ ]]; then
                    LOG_LINES="$2"
                    shift 2
                else
                    shift
                fi
                ;;
            --events)
                ACTION="events"
                shift
                ;;
            --status)
                ACTION="status"
                shift
                ;;
            --expose-to)
                LOCAL_PORT="$2"
                ACTION="expose"
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

# Verifica que kubectl esté disponible
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        handle_error "kubectl no encontrado. Por favor instale kubectl."
    fi
    log "DEBUG" "kubectl disponible: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
}

# Valida el contexto de kubectl si está configurado
validate_kubectl_context() {
    local current_context
    local available_contexts

    if [[ -n "$KUBECTL_CONTEXT" ]]; then
        log "INFO" "Validando contexto kubectl: $KUBECTL_CONTEXT"

        if ! current_context=$(kubectl config current-context 2>&1); then
            handle_error "No se pudo obtener el contexto actual de kubectl: $current_context"
        fi

        available_contexts=$(kubectl config get-contexts -o name 2>&1)
        if [[ ! "$available_contexts" =~ (^|$'\n'"$KUBECTL_CONTEXT"$'\n'|$'\n'"$KUBECTL_CONTEXT"$) ]]; then
            handle_error "上下文 '$KUBECTL_CONTEXT' no encontrado. Contextos disponibles: $available_contexts"
        fi

        if [[ "$current_context" != "$KUBECTL_CONTEXT" ]]; then
            log "INFO" "Cambiando de contexto '$current_context' a '$KUBECTL_CONTEXT'"
            if ! kubectl config use-context "$KUBECTL_CONTEXT" &> /dev/null; then
                handle_error "No se pudo cambiar al contexto '$KUBECTL_CONTEXT'"
            fi
        fi

        log "SUCCESS" "Contexto kubectl validado: $KUBECTL_CONTEXT"
    else
        current_context=$(kubectl config current-context 2>&1) || current_context="no configurado"
        log "DEBUG" "Sin contexto específico, usando contexto actual: $current_context"
    fi
}

# Verifica que el directorio temporal existe
check_tmp_dir() {
    if [[ ! -d "$K8S_TMP_DIR" ]]; then
        handle_error "Directorio temporal no encontrado: $K8S_TMP_DIR. Ejecute configure.sh primero."
    fi

    if [[ -z "$(ls -A "$K8S_TMP_DIR"/*.yaml 2>/dev/null)" ]]; then
        handle_error "No se encontraron archivos YAML en: $K8S_TMP_DIR"
    fi
}

# Verifica conexión al cluster
check_cluster_connection() {
    log "INFO" "Verificando conexión al cluster Kubernetes..."

    if ! kubectl cluster-info &> /dev/null; then
        handle_error "No se puede conectar al cluster Kubernetes. Verifique su configuración de kubectl."
    fi

    log "SUCCESS" "Conexión al cluster verificada"

    # Verificar que el namespace existe o crearlo
    if ! kubectl get namespace "$K8S_NAMESPACE" &> /dev/null; then
        log "WARN" "Namespace '$K8S_NAMESPACE' no existe. Creándolo..."
        kubectl create namespace "$K8S_NAMESPACE"
        log "SUCCESS" "Namespace '$K8S_NAMESPACE' creado"
    fi
}

# Aplica todos los recursos usando kustomize
apply_all_yaml_files() {
    log "INFO" "Aplicando recursos con kustomize desde: $K8S_TMP_DIR"
    log "INFO" "============================================"

    if kubectl apply -k "$K8S_TMP_DIR"; then
        log "SUCCESS" "Recursos aplicados correctamente"
    else
        log "ERROR" "Error al aplicar recursos con kustomize"
        return 1
    fi
}

# Muestra el estado de los recursos desplegados
show_deployment_status() {
    log "INFO" "============================================"
    log "INFO" "Estado de los recursos desplegados"
    log "INFO" "============================================"

    echo ""
    kubectl get all -n "$K8S_NAMESPACE" 2>/dev/null || log "WARN" "No se pudieron obtener los recursos"

    echo ""
    log "INFO" "ConfigMaps:"
    kubectl get configmap -n "$K8S_NAMESPACE" 2>/dev/null || true

    echo ""
    log "INFO" "Secrets:"
    kubectl get secret -n "$K8S_NAMESPACE" 2>/dev/null || true
}

# Escala el deployment a 0 réplicas
scale_to_zero() {
    log "INFO" "Escalando deployment a 0 réplicas..."

    if kubectl get deployment command-api-ms -n "$K8S_NAMESPACE" &> /dev/null; then
        kubectl scale deployment command-api-ms --replicas=0 -n "$K8S_NAMESPACE"
        log "SUCCESS" "Deployment escalado a 0 réplicas"
    else
        log "WARN" "Deployment no encontrado en namespace $K8S_NAMESPACE"
    fi
}

# Elimina todos los recursos del namespace
remove_all_resources() {
    log "INFO" "Eliminando todos los recursos del namespace: $K8S_NAMESPACE"

    kubectl delete deployment command-api-ms -n "$K8S_NAMESPACE" --ignore-not-found=true 2>/dev/null || true
    kubectl delete service command-api-ms -n "$K8S_NAMESPACE" --ignore-not-found=true 2>/dev/null || true
    kubectl delete configmap command-api-config -n "$K8S_NAMESPACE" --ignore-not-found=true 2>/dev/null || true
    kubectl delete secret command-api-secret -n "$K8S_NAMESPACE" --ignore-not-found=true 2>/dev/null || true

    log "SUCCESS" "Recursos eliminados"
}

# Obtiene nombre del primer pod
get_pod_name() {
    kubectl get pods -n "$K8S_NAMESPACE" -l app=command-api-ms -o jsonpath='{.items[0].metadata.name}' 2>/dev/null
}

# Obtiene nombres de todos los pods del deployment
get_pod_names() {
    kubectl get pods -n "$K8S_NAMESPACE" -l app=command-api-ms -o jsonpath='{.items[*].metadata.name}' 2>/dev/null
}

# Muestra logs estáticos de todas las instancias del deployment
show_pod_logs() {
    local lines="$1"

    local pod_names
    pod_names=$(get_pod_names)

    if [[ -z "$pod_names" ]]; then
        log "WARN" "No se encontró ningún pod en namespace $K8S_NAMESPACE"
        return 0
    fi

    for pod_name in $pod_names; do
        log "INFO" "=== Pod: $pod_name ==="
        kubectl logs "$pod_name" -n "$K8S_NAMESPACE" --tail="$lines"
        echo ""
    done
}

# Muestra logs en vivo del pod
tail_pod_logs() {
    local lines="$1"
    log "INFO" "Observando logs del pod (últimas $lines líneas + follow)..."

    local pod_name
    pod_name=$(get_pod_name)

    if [[ -z "$pod_name" ]]; then
        log "WARN" "No se encontró ningún pod en namespace $K8S_NAMESPACE"
        return 0
    fi

    log "INFO" "Pod: $pod_name"
    kubectl logs "$pod_name" -n "$K8S_NAMESPACE" --tail="$lines" -f
}

# Muestra eventos del namespace
show_namespace_events() {
    log "INFO" "Obteniendo eventos del namespace: $K8S_NAMESPACE"
    kubectl get events -n "$K8S_NAMESPACE" --sort-by='.lastTimestamp' | tail -30
}

# Expone el servicio localmente via port-forward
expose_service() {
    local local_port="$1"
    local service_port=8080

    log "INFO" "Exponiendo service/command-api-ms → localhost:${local_port} (service port: ${service_port})"
    log "INFO" "Presiona Ctrl+C para detener el port-forward"

    kubectl port-forward "service/command-api-ms" \
        "${local_port}:${service_port}" \
        -n "$K8S_NAMESPACE"
}

# Muestra estado de los recursos aprovisionados
show_resource_status() {
    log "INFO" "Estado de los recursos aprovisionados en namespace: $K8S_NAMESPACE"
    echo ""
    log "INFO" "=== Deployment ==="
    kubectl get deployment command-api-ms -n "$K8S_NAMESPACE" -o wide 2>/dev/null || echo "No encontrado"
    echo ""
    log "INFO" "=== Pods ==="
    kubectl get pods -n "$K8S_NAMESPACE" -l app=command-api-ms -o wide 2>/dev/null || echo "No hay pods"
    echo ""
    log "INFO" "=== Service ==="
    kubectl get service command-api-ms -n "$K8S_NAMESPACE" -o wide 2>/dev/null || echo "No encontrado"
    echo ""
    log "INFO" "=== ConfigMap ==="
    kubectl get configmap command-api-config -n "$K8S_NAMESPACE" -o wide 2>/dev/null || echo "No encontrado"
    echo ""
    log "INFO" "=== Secret ==="
    kubectl get secret command-api-secret -n "$K8S_NAMESPACE" -o wide 2>/dev/null || echo "No encontrado"
}

# ============================================
# Main
# ============================================

main() {
    log "INFO" "============================================"
    log "INFO" "Desplegando recursos K8s"
    log "INFO" "============================================"

    # Parsear argumentos
    parse_args "$@"

    # Cargar variables del perfil y asignar con fallback
    load_env_vars "$PROFILE" "$SCRIPT_CONFIG_DIR"
    KUBECTL_CONTEXT=$(set_with_fallback "KUBECTL_CONTEXT" "")
    K8S_NAMESPACE=$(set_with_fallback "K8S_NAMESPACE" "synopsis-ws")

    # Verificaciones previas
    check_kubectl
    validate_kubectl_context

    case "$ACTION" in
        stop)
            log "INFO" "Acción: STOP"
            scale_to_zero
            ;;
        remove)
            log "INFO" "Acción: REMOVE"
            check_tmp_dir
            remove_all_resources
            ;;
        logs)
            log "INFO" "Acción: LOGS"
            show_pod_logs "$LOG_LINES"
            ;;
        tail)
            log "INFO" "Acción: TAIL (logs en vivo)"
            tail_pod_logs "$LOG_LINES"
            ;;
        events)
            log "INFO" "Acción: EVENTS"
            show_namespace_events
            ;;
        status)
            log "INFO" "Acción: STATUS"
            show_resource_status
            ;;
        expose)
            log "INFO" "Acción: EXPOSE → localhost:${LOCAL_PORT}"
            expose_service "$LOCAL_PORT"
            ;;
        *)
            log "INFO" "Acción: APPLY"
            check_tmp_dir
            check_cluster_connection
            apply_all_yaml_files
            show_resource_status
            log "INFO" "============================================"
            log "SUCCESS" "Despliegue completado exitosamente"
            log "INFO" "============================================"
            ;;
    esac
}

main "$@"
