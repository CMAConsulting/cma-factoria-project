# Preparación de escenarios de estrés para `GET /api/commands`

## Objetivo
Validar el rendimiento sostenido (≥7,260 TPS) y bursts (≥14,500 TPS) del endpoint `http://localhost:8080/api/commands`, midiendo estabilidad, errores y latencias.

---

## Requisitos previos

### Herramientas necesarias
1. **JMeter** (≥5.6):
   - Instalado en la máquina de prueba o distribuido.
   - Script de instalación de plugins: `scripts/jmeter/install.sh`.
2. **Plugins recomendados**:
   - `jmeter-plugins-manager` (para gestión dinámica de plugins).
   - **Throughput Shaping Timer** (control de carga sostenida y bursts).
   - **PerfMon Metrics Collector** (monitoreo de recursos del backend).
3. **Ambiente**:
   - API servidor activo en `http://localhost:8080`.
   - Permisos para acceder al endpoint `/api/commands`.
4. **Métricas de negocio**:
   - Dashboard de visualización (ej: Grafana + InfluxDB) para resultados en tiempo real.

---

## Configuración del Test Plan

### Estructura del archivo `.jmx`
1. **Thread Group**:
   - **Nombre**: `Stress Test /api/commands`.
   - **Número de hilos**:
     - Sostenido: `8,712 hilos` (calculado: 7,260 TPS × 60 segundos × 5 minutos ÷ 100% de uso).
     - Burst: `17,400 hilos` (14,500 TPS × 60 segundos).
   - **Duración**:
     - Sostenido: 5 minutos.
     - Burst: 1 minuto al final.

2. **Samplers**:
   - **HTTP Request**:
     - Método: `GET`.
     - URL: `http://localhost:8080/api/commands`.
     - Headers: `Accept: application/json`.

3. **Controladores de carga**:
   - **Throughput Shaping Timer** (pluggable):
     - Configurar rampas:
       - Sostenido: `7,260 TPS` durante 5 min.
       - Burst: `14,500 TPS` durante 1 min.

4. **Listeners**:
   - **View Results Tree** (para validar respuestas individuales).
   - **PerfMon Metrics Collector** (para CPU, memoria, GC en el servidor).
   - **CSV Results Writer** (exportar datos para análisis).

---

## Ejecución del Test

### Modo no GUI (recomendado)
```bash
jmeter -n \
  -t jmeter-command-api-ms.jmx \
  -l results.jtl \
  -j jmeter.log
```

### Comandos adicionales para análisis
1. Generar dashboard:
   ```bash
   jmeter -g results.jtl -o results-dashboard
   ```
2. Extraer métricas clave (ej. TPS, latencia):
   ```bash
   ajs ontparse results.jtl -o metrics.csv
   ```

---

## Métricas esperadas

| Métrica | Objetivo | Valor crítico |
|--------|----------|---------------|
| TPS sostenido | ≥7,260 | <50% reduction |
| TPS burst | ≥14,500 | <20% failure |
| Latencia (99%) | ≤500 ms | >750 ms |
| Errores | 0% | ≥5% → alerta |

---

## Post-procesamiento y análisis

1. **Identificar cuellos de botella**:
   - PerfMon para CPU/memoria del backend.
   - Logs del backend (ej: `system.out` o JMX).
2. **Ajustes si no se alcanzan objetivos**:
   - Aumentar hilos o escalar la infraestructura.
   - Optimizar consultas en la base de datos (si aplica).

---

## Notas adicionales
- **Distributed Testing** (opcional):
  - Configurar nodos remotos en `jmeter.properties` (`remote_hosts=IP1:1099,IP2:1099`).
  - Dividir hilos entre nodos para escalar horizontalmente.
- **Seguridad**: Asegurar que el endpoint no exponga información sensible en respuestas de error.
- **Reintento automático**: Configurar samplers para manejar fallos transitorios.

> **Referencia**: [Artículo de BlazeMeter sobre plugins recomendados](https://www.blazemeter.com/blog/top-ten-jmeter-plugins)