# Scripts Docker

Scripts para construir y gestionar contenedores Docker del proyecto.

## Estructura

```
scripts/docker/
├── backend/
│   ├── modules/
│   │   ├── container.sh     # Ciclo de vida de contenedores
│   │   └── image.sh         # Build y push de imágenes
│   └── command-api-ms/
│       ├── build.sh         # Construye la imagen nativa
│       ├── run.sh           # Gestiona el contenedor en ejecución
│       ├── dev.env          # Variables del perfil dev
│       └── profile.env.example
└── database/
    ├── modules/
    │   ├── postgres.sh      # Operaciones PostgreSQL
    │   └── volume.sh        # Gestión de volúmenes
    └── postgresql.sh        # Gestiona el contenedor PostgreSQL
```

Los scripts en `modules/` contienen funciones reutilizables que no se ejecutan directamente — son sourced por los scripts principales.

## Variables de entorno

Cada script carga variables desde un archivo `{profile}.env` en su directorio. El archivo `profile.env.example` documenta todas las variables disponibles.

```bash
# Copiar y ajustar para cada perfil
cp scripts/docker/backend/command-api-ms/profile.env.example \
   scripts/docker/backend/command-api-ms/dev.env
```

| Variable | Descripción | Default |
|----------|-------------|---------|
| `ENV_IMAGE_NAME` | Nombre de la imagen | `command-api-ms` |
| `ENV_TAG` | Tag de la imagen | `1.0.0` |
| `ENV_REGISTRY_SERVER` | URL del registry | — |
| `ENV_REGISTRY_USERNAME` | Usuario del registry | — |
| `ENV_REGISTRY_PASSWORD` | Contraseña del registry | — |
| `HTTP_HOST` | Host del servidor HTTP | `0.0.0.0` |
| `HTTP_PORT` | Puerto HTTP | `8080` |
| `CORS_ENABLED` | Activar CORS | `true` |
| `CORS_ORIGINS` | Orígenes CORS permitidos | `*` |
| `DB_HOST` | Host de PostgreSQL | — |
| `DB_PORT` | Puerto de PostgreSQL | `5432` |
| `DB_NAME` | Nombre de la base de datos | — |
| `DB_USER` | Usuario de base de datos | — |
| `DB_PASSWORD` | Contraseña de base de datos | — |

---

## build.sh — Imagen del backend

Construye la imagen Docker nativa de `command-api-ms` usando un build multi-stage:
1. **Stage build:** `ubi9-quarkus-mandrel-builder-image:jdk-21` compila el nativo
2. **Stage runtime:** `ubi9-quarkus-micro-image:2.0` ejecuta el binario (~70 MB imagen final)

```bash
bash scripts/docker/backend/command-api-ms/build.sh [OPTIONS]
```

| Opción | Descripción |
|--------|-------------|
| `-p, --profile NAME` | Perfil de variables (default: `dev`) |
| `--upload` | Push al registry tras el build |
| `-h, --help` | Ayuda |

### Ejemplos

```bash
# Build con perfil dev
bash scripts/docker/backend/command-api-ms/build.sh

# Build con perfil staging
bash scripts/docker/backend/command-api-ms/build.sh --profile staging

# Build + push al registry
bash scripts/docker/backend/command-api-ms/build.sh --upload

# Build + push con perfil prod
bash scripts/docker/backend/command-api-ms/build.sh --profile prod --upload
```

> El build ejecuta `./mvnw package -Pnative -DskipTests` dentro del contenedor Mandrel. La primera ejecución descarga el builder (~1.5 GB) y tarda ~4 min. Las siguientes reusan la caché de dependencias Maven.

---

## run.sh — Contenedor del backend

Gestiona el ciclo de vida del contenedor `command-api-ms`.

```bash
bash scripts/docker/backend/command-api-ms/run.sh [OPTIONS] COMMAND
```

| Comando | Descripción |
|---------|-------------|
| `--start` | Inicia el contenedor en modo detached (`-d`) |
| `--stop` | Detiene el contenedor |
| `--remove` | Detiene y elimina el contenedor |
| `--logs [N]` | Muestra las últimas N líneas de logs (default: 20) |
| `--tail [N]` | Sigue los logs en tiempo real desde las últimas N líneas (default: 20) |

| Opción | Descripción |
|--------|-------------|
| `-p, --profile NAME` | Perfil de variables (default: `dev`) |
| `-h, --help` | Ayuda |

### Ejemplos

```bash
# Ciclo básico
bash scripts/docker/backend/command-api-ms/run.sh --start
bash scripts/docker/backend/command-api-ms/run.sh --logs
bash scripts/docker/backend/command-api-ms/run.sh --stop

# Con perfil staging
bash scripts/docker/backend/command-api-ms/run.sh --start --profile staging

# Ver últimas 50 líneas
bash scripts/docker/backend/command-api-ms/run.sh --logs 50

# Seguir logs en vivo desde las últimas 100 líneas
bash scripts/docker/backend/command-api-ms/run.sh --tail 100

# Limpiar completamente
bash scripts/docker/backend/command-api-ms/run.sh --remove
```

---

## postgresql.sh — Base de datos PostgreSQL

Gestiona un contenedor PostgreSQL para desarrollo y pruebas.

```bash
bash scripts/docker/database/postgresql.sh [OPTIONS] COMMAND
```

| Comando | Descripción |
|---------|-------------|
| `init` | Crea el volumen y lanza el contenedor |
| `start` | Inicia un contenedor ya existente |
| `stop` | Detiene el contenedor |
| `remove` | Elimina el contenedor y el volumen de datos |
| `status` | Muestra estado, configuración y puertos |
| `test` | Valida conectividad con `pg_isready` y `psql` |

| Opción | Descripción |
|--------|-------------|
| `-p, --profile NAME` | Perfil de variables (default: `dev`) |
| `-h, --help` | Ayuda |

### Variables de perfil (database)

```bash
cp scripts/docker/database/profile.env.example scripts/docker/database/dev.env
```

| Variable | Default |
|----------|---------|
| `ENV_POSTGRES_VERSION` | `16` |
| `ENV_POSTGRES_PORT` | `5432` |
| `ENV_POSTGRES_DB` | `factoria` |
| `ENV_POSTGRES_USER` | `factoria` |
| `ENV_POSTGRES_PASSWORD` | `factoria` |
| `ENV_USE_NATIVE_VOLUME` | `true` |
| `ENV_VOLUME_PATH` | volumen Docker o ruta bind-mount |

### Ejemplos

```bash
# Ciclo completo
bash scripts/docker/database/postgresql.sh init
bash scripts/docker/database/postgresql.sh test
bash scripts/docker/database/postgresql.sh status
bash scripts/docker/database/postgresql.sh stop

# Entorno staging
bash scripts/docker/database/postgresql.sh -p staging init

# Limpiar todo
bash scripts/docker/database/postgresql.sh remove
```

---

## Módulos reutilizables

### `backend/modules/container.sh`

Funciones para el ciclo de vida de contenedores backend. Requiere `log.sh` sourced.

| Función | Descripción |
|---------|-------------|
| `container_start NAME IMAGE HOST_PORT CONTAINER_PORT [args...]` | `docker run -d` con puerto y env vars |
| `container_stop NAME` | `docker stop` |
| `container_remove NAME` | `docker stop` + `docker rm` |
| `container_logs NAME [LINES]` | `docker logs --tail` |
| `container_tail NAME [LINES]` | `docker logs -f --tail` |
| `container_is_running NAME` | Retorna 0 si el contenedor está corriendo |
| `container_exists NAME` | Retorna 0 si el contenedor existe (running o stopped) |

### `backend/modules/image.sh`

Funciones para build y distribución de imágenes.

| Función | Descripción |
|---------|-------------|
| `image_build LOCAL_IMAGE DOCKERFILE CONTEXT [args...]` | `docker build --no-cache` |
| `image_push LOCAL_IMAGE REGISTRY_IMAGE SERVER USER PASS` | tag + login + `docker push` |

### `database/modules/volume.sh`

Gestión de almacenamiento para bases de datos.

| Función | Descripción |
|---------|-------------|
| `volume_prepare USE_NATIVE VOLUME_NAME DATA_DIR` | Crea volumen Docker o directorio bind-mount |
| `volume_cleanup USE_NATIVE VOLUME_NAME DATA_DIR` | Elimina volumen o limpia directorio |

### `database/modules/postgres.sh`

Operaciones específicas de PostgreSQL. Requiere `volume.sh` sourced.

| Función | Parámetros clave |
|---------|-----------------|
| `postgres_init` | container, version, port, db, user, pass, use_native, volume, dir |
| `postgres_start` | container |
| `postgres_stop` | container |
| `postgres_remove` | container, use_native, volume, dir |
| `postgres_status` | container, version, port, db, user, use_native, volume, dir |
| `postgres_test` | container, user, db |
