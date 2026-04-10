# Scripts de Backend

Scripts para el desarrollo local del backend (Quarkus).

## Estructura

```
scripts/backend/
├── local_start.sh    # Inicia el servicio
└── local_stop.sh     # Detiene el servicio
```

## local_start.sh

Inicia el servicio command-service en modo desarrollo.

### Características

- **Puerto:** 8080
- **Ubicación:** `apps/backend/command-service/`
- **Comando:** `mvn quarkus:dev`
- Compila el proyecto con `mvn clean compile` antes de iniciar

### Uso

```bash
./scripts/backend/local_start.sh
```

El servicio estará disponible en: `http://localhost:8080`

Presiona `Ctrl+C` para detener.

## local_stop.sh

Detiene el proceso de Quarkus en el puerto 8080.

### Características

- Busca procesos en puerto 8080 usando `lsof`
- Detiene procesos Java relacionados con Quarkus

### Uso

```bash
./scripts/backend/local_stop.sh
```

## Requisitos

- Maven 3.9+
- Puerto 8080 disponible
- Java 17+