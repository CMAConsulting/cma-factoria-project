# Integración de Backends con Bases de Datos

## Resumen

Se integraron los 3 microservicios de backend con sus bases de datos PostgreSQL correspondientes usando JDBC y stored procedures.

## Configuración Realizada

### Dependencias Agregadas a cada pom.xml

```xml
<!-- Hibernate Reactive -->
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-hibernate-reactive</artifactId>
</dependency>

<!-- Reactive PostgreSQL Client -->
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-reactive-pg-client</artifactId>
</dependency>

<!-- JDBC PostgreSQL for stored procedures -->
<dependency>
    <groupId>io.quarkus</groupId>
    <artifactId>quarkus-jdbc-postgresql</artifactId>
</dependency>
```

### Configuración de Datasources

Cada microservicio tiene su propia base de datos configurada en `application.yaml`:

| Microservicio | Base de Datos | Puerto |
|--------------|--------------|--------|
| command-api-ms | command_db | 5432 |
| dashboard-api-ms | dashboard_db | 5432 |
| settings-api-ms | settings_db | 5432 |

### Variables de Entorno

```bash
DB_JDBC_URL=jdbc:postgresql://localhost:5432/<db_name>
DB_USER=postgres
DB_PASSWORD=postgres
```

## Repositories Creados

### CommandRepository
- `insert(CommandEntity)` → `sp_insert_command()`
- `findById(UUID)` → `sp_get_command()`
- `findAll(status, source, limit, offset)` → `sp_list_commands()`

### DashboardRepository
- `getMetrics()` → `sp_get_dashboard_metrics()`
- `getActivity(limit, offset, userId)` → `sp_get_dashboard_activity()`

### SettingsRepository
- `getGeneralSettings()` → SELECT from settings_general
- `getApiSettings()` → SELECT from settings_api_config
- `getNotificationSettings()` → `sp_get_settings_notifications()`
- `updateNotificationSettings()` → `sp_update_settings_notifications()`

## Stored Procedures Utilizadas

### command_db
- `001_sp_insert_command`
- `002_sp_get_command`
- `003_sp_list_commands`
- `004_sp_get_command_result`

### dashboard_db
- `001_sp_get_dashboard_metrics`
- `002_sp_get_dashboard_activity`

### settings_db
- `001_sp_get_settings_notifications`
- `002_sp_update_settings_notifications`

## Notas de Implementación

- Se usa JDBC directo con CallableStatement para llamar stored procedures
- La conexión se obtiene via DriverManager usando variables de entorno
- Los repositories usan Mutiny Uni para operaciones asíncronas
- Los modelos (entity classes) usan Lombok para builders

## Estado

✅ Implementado y compilado correctamente