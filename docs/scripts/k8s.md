# Scripts Kubernetes

Scripts para configurar y desplegar recursos en el clúster Kubernetes (MicroK8s).

## Estructura

```
scripts/k8s/
└── command-api-ms/
    ├── configure.sh         # Genera YAMLs con valores del perfil
    ├── run.sh               # Aplica y gestiona recursos en el clúster
    └── profile.env.example  # Variables disponibles por perfil

infra/k8s/
└── command-api-ms/
    ├── deployment.yaml      # Deployment con 2 réplicas (prod: 3)
    ├── service.yaml         # ClusterIP en puerto 8080
    ├── configmap.yaml       # Variables no sensibles (DB_HOST, CORS, etc.)
    ├── secret.yaml          # Credenciales (DB_USER, DB_PASSWORD)
    └── kustomization.yaml   # Namespace synopsis-ws + patches de prod
```

---

## configure.sh

Toma los manifiestos de `infra/k8s/command-api-ms/` y los genera en `.tmp/k8s/command-api-ms/` con los valores del perfil seleccionado.

```bash
bash scripts/k8s/command-api-ms/configure.sh [OPTIONS]
```

| Opción | Descripción |
|--------|-------------|
| `-p, --profile NAME` | Perfil de variables (default: `dev`) |
| `-h, --help` | Ayuda |

### Variables de perfil

```bash
cp scripts/k8s/command-api-ms/profile.env.example scripts/k8s/command-api-ms/dev.env
```

| Variable | Descripción |
|----------|-------------|
| `ENV_IMAGE_TAG` | Tag de la imagen a desplegar |
| `ENV_REGISTRY_SERVER` | Registry de donde pull la imagen |
| `ENV_DB_HOST` | Host del servicio PostgreSQL en el clúster |
| `ENV_DB_NAME` | Nombre de la base de datos |
| `ENV_CORS_ORIGINS` | Orígenes permitidos (ej. `https://app.cmaconsulting.org`) |
| `ENV_DB_USER` | Usuario BD (se codifica en base64 para el Secret) |
| `ENV_DB_PASSWORD` | Contraseña BD (se codifica en base64 para el Secret) |

### Ejemplos

```bash
# Generar manifiestos para dev
bash scripts/k8s/command-api-ms/configure.sh

# Generar para producción
bash scripts/k8s/command-api-ms/configure.sh --profile prod
```

Los YAMLs generados se escriben en `.tmp/k8s/command-api-ms/` y son los que `run.sh` aplica al clúster.

---

## run.sh

Aplica y gestiona los recursos Kubernetes del microservicio.

```bash
bash scripts/k8s/command-api-ms/run.sh COMMAND [OPTIONS]
```

| Comando | Descripción |
|---------|-------------|
| `apply` | Aplica todos los recursos al clúster (secret → configmap → deployment → service) |
| `status` | Estado del Deployment y pods |
| `logs` | Logs del pod activo (últimas líneas) |
| `tail` | Sigue los logs del pod en tiempo real |
| `events` | Eventos recientes del namespace |
| `stop` | Escala el Deployment a 0 réplicas |
| `remove` | Elimina todos los recursos del clúster |

| Opción | Descripción |
|--------|-------------|
| `-p, --profile NAME` | Perfil de variables (default: `dev`) |
| `-h, --help` | Ayuda |

### Ejemplos

```bash
# Flujo completo de despliegue
bash scripts/k8s/command-api-ms/configure.sh --profile prod
bash scripts/k8s/command-api-ms/run.sh apply --profile prod

# Monitoreo
bash scripts/k8s/command-api-ms/run.sh status
bash scripts/k8s/command-api-ms/run.sh tail

# Detener sin eliminar recursos
bash scripts/k8s/command-api-ms/run.sh stop

# Eliminar todo del clúster
bash scripts/k8s/command-api-ms/run.sh remove
```

---

## Manifiestos (`infra/k8s/command-api-ms/`)

### deployment.yaml

- **Réplicas:** 2 (base) / 3 (patch producción en kustomization.yaml)
- **Imagen:** `registry.synopsis.cloud/command-api-ms:1.0.0`
- **Puerto:** 8080
- **Recursos (base):** 256m–1000m CPU, 512Mi–1Gi RAM
- **Recursos (prod):** 500m–2000m CPU, 1Gi–2Gi RAM
- **Probes:**
  - `livenessProbe`: `GET /health/live` — delay 30s, period 10s
  - `readinessProbe`: `GET /health/ready` — delay 10s, period 5s
  - `startupProbe`: `GET /health/live` — delay 5s, hasta 30 reintentos

### service.yaml

- **Tipo:** `ClusterIP`
- **Puerto:** 8080 → 8080

### configmap.yaml

Variables no sensibles inyectadas como `env` en el Deployment:

| Clave | Valor base |
|-------|-----------|
| `DB_HOST` | `command-db-service` |
| `DB_NAME` | `command_db` |
| `HTTP_HOST` | `0.0.0.0` |
| `HTTP_PORT` | `8080` |
| `CORS_ENABLED` | `true` |
| `CORS_ORIGINS` | `http://localhost:3000` |

### secret.yaml

Credenciales en base64. **Reemplazar antes de desplegar en producción:**

```bash
echo -n "mi_usuario" | base64
echo -n "mi_password" | base64
```

Actualizar `infra/k8s/command-api-ms/secret.yaml` con los valores resultantes.

### kustomization.yaml

- **Namespace:** `synopsis-ws`
- **Common labels:** `app: command-api-ms`, `environment: synopsis-ws`
- **Patch producción:** escala a 3 réplicas y aumenta recursos

---

## Prerequisitos

- `kubectl` instalado y configurado con contexto activo
- Acceso al namespace `synopsis-ws`
- Secret de pull del registry creado en el namespace:

```bash
kubectl create secret docker-registry synopsis-registry-secret \
  --docker-server=registry.synopsis.cloud \
  --docker-username=<user> \
  --docker-password=<password> \
  -n synopsis-ws
```
