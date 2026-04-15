# PostgreSQL Docker Script

Script para inicializar y gestionar instancias PostgreSQL en contenedores Docker.

## Ubicación

```
scripts/docker/database/postgresql.sh
```

## Requisitos

- Docker instalado y en ejecución
- Imagen `postgres` disponible (se descarga automáticamente)

## Uso

```bash
./scripts/docker/database/postgresql.sh [OPTIONS] COMMAND
```

## Comandos

| Comando | Descripción |
|---------|------------|
| `init` | Inicializa PostgreSQL con volúmenes |
| `start` | Inicia contenedor existente |
| `stop` | Detiene el contenedor |
| `remove` | Elimina contenedor y datos |
| `status` | Muestra estado del contenedor |

## Opciones

| Opción | Descripción | Default |
|--------|------------|---------|
| `-p, --profile` | Perfil (dev, staging, prod) | `dev` |
| `-v, --version` | Versión de PostgreSQL | `16` |
| `--port` | Puerto | `5432` |
| `--db` | Nombre de base de datos | `factoria` |
| `--user` | Usuario | `factoria` |
| `--password` | Contraseña | `factoria` |

## Ejemplos

### Inicializar instancia básica

```bash
./scripts/docker/database/postgresql.sh init
```

### Inicializar con perfil staging

```bash
./scripts/docker/database/postgresql.sh --profile staging init
```

### Especificar versión y puerto

```bash
./scripts/docker/database/postgresql.sh -v 15 --port 5433 init
```

### Ver estado

```bash
./scripts/docker/database/postgresql.sh status
```

### Detener contenedor

```bash
./scripts/docker/database/postgresql.sh stop
```

### Iniciar contenedor

```bash
./scripts/docker/database/postgresql.sh start
```

### Eliminar instancia

```bash
./scripts/docker/database/postgresql.sh remove
```

## Configuración

### Variables de Entorno

```bash
# Perfil de entorno
export PROFILE=dev

# Versión de PostgreSQL
export POSTGRES_VERSION=16

# Puerto
export POSTGRES_PORT=5432

# Credenciales
export POSTGRES_DB=factoria
export POSTGRES_USER=factoria
export POSTGRES_PASSWORD=factoria
```

### Almacenamiento

Por defecto, el script usa **volúmenes nativos de Docker**:

```
factoria_postgres_data  →  /var/lib/docker/volumes/
```

Para usar **bind mount** a `.tmp`:

```bash
USE_NATIVE_VOLUME=false ./scripts/docker/database/postgresql.sh init
```

> **Nota**: El bind mount a `.tmp` requiere ejecutar `chown -R 999:999 .tmp/postgres/data` como root antes de inicializar.

## Conexión

### Connection String

```
postgresql://factoria:factoria@localhost:5432/factoria
```

### Verificar conexión

```bash
docker exec factoria-postgres-dev pg_isready -U factoria
```

### Conectar desde-Host

```bash
psql -h localhost -p 5432 -U factoria -d factoria
```

## Estructura de Archivos

```
.tmp/
└── postgres/
    └── data/           # Solo cuando se usa bind mount
```

### Volúmenes Docker

```
factoria_postgres_data    # Volumen de datos (cuando se usa volumen nativo)
```

## Solución de Problemas

### El contenedor se reinicia continuamente

**Causa**: Problema de permisos con el volumen.

**Solución**:

```bash
# Eliminar y recrear
./scripts/docker/database/postgresql.sh remove
./scripts/docker/database/postgresql.sh init
```

### Puerto en uso

**Causa**: Otro servicio está usando el puerto 5432.

**Solución**: Usar otro puerto:

```bash
./scripts/docker/database/postgresql.sh --port 5433 init
```

### Permiso denegado en bind mount

**Causa**: El directorio `.tmp` tiene permisos de root.

**Solución**: Usar volumen nativo (default):

```bash
USE_NATIVE_VOLUME=true ./scripts/docker/database/postgresql.sh init
```

## Integración con Scripts

El script reutiliza funciones de `scripts/commons/`:

```bash
source "$PROJECT_DIR/scripts/commons/log.sh"   # Logging
source "$PROJECT_DIR/scripts/commons/get.sh"   # Utilidades
```

## Notas

- El contenedor usa `postgres:XX-alpine` (imagen ligera)
- `restart: unless-stopped` - se reinicia automáticamente si el host reinicia
- La base de datos se inicializa automáticamente con las variables de entorno