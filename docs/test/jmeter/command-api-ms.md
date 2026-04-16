# JMeter — command-api-ms

Pruebas de carga y estrés para el endpoint `GET /api/commands`.

## Estructura

```
tests/jmeter/
└── command-api-ms/
    ├── scenarie-001.jmx          # Test plan: carga sostenida + burst
    ├── dev.properties            # Propiedades JMeter para perfil dev
    └── profile.properties.example

scripts/jmeter/
├── install.sh                    # Instala plugins en JMETER_HOME
├── dev.env                       # Variables del entorno JMeter (perfil global)
├── profile.env.example
├── plugins/                      # JARs copiados por install.sh
└── command-api-ms/
    ├── start.sh                  # Script de ejecución
    └── dev.env                   # Variables del perfil command-api-ms
```

---

## Instalación

```bash
# Ejecutar desde la raíz del proyecto
bash scripts/jmeter/install.sh
```

Copia todos los JARs de `scripts/jmeter/plugins/` a `$JMETER_HOME/lib/ext/`.

### Plugins incluidos

| Plugin | Versión | Uso en test plan |
|--------|---------|-----------------|
| `jmeter-plugins-manager` | 1.12 | Gestión de plugins |
| `jmeter-plugins-casutg` | 3.1.1 | Concurrent Users Shaping Timer |
| `jmeter-plugins-tst` | 2.6 | **Throughput Shaping Timer** (control de TPS) |
| `jmeter-plugins-graphs-basic` | 2.0 | Gráficas básicas |
| `jmeter-plugins-ffw` | 2.0 | Flexible File Writer |
| `jmeter-plugins-fifo` | 0.2 | FIFO queues entre thread groups |
| `jmeter-plugins-functions` | 2.2 | Funciones adicionales `${__}` |
| `jmeter-plugins-dummy` | 0.4 | Dummy Sampler para pruebas |
| `jmeter-plugins-perfmon` | 2.1 | Métricas del servidor (CPU/RAM) |

---

## Configuración

### Propiedades JMeter — `tests/jmeter/command-api-ms/dev.properties`

Pasadas a JMeter con `-q`. El test plan las lee con `${__P(key,default)}`.

| Propiedad | Ejemplo dev | Descripción |
|-----------|-------------|-------------|
| `host` | `microk8s.cmaconsulting.local` | Host del servidor bajo prueba |
| `port` | `31060` | Puerto del servidor bajo prueba |

Para crear un nuevo perfil:

```bash
cp tests/jmeter/command-api-ms/profile.properties.example \
   tests/jmeter/command-api-ms/staging.properties
# Editar host y port para staging
```

---

## Ejecución

```bash
# Perfil dev (non-GUI)
bash scripts/jmeter/command-api-ms/start.sh

# Perfil staging
bash scripts/jmeter/command-api-ms/start.sh --profile staging

# Escenario específico
bash scripts/jmeter/command-api-ms/start.sh --jmeter-file scenarie-001

# Modo GUI (abre interfaz gráfica)
bash scripts/jmeter/command-api-ms/start.sh --gui
```

### Argumentos de `start.sh`

| Argumento | Descripción |
|-----------|-------------|
| `-p`, `--profile` | Perfil a usar (default: `dev`) |
| `--jmeter-file` | Nombre del `.jmx` sin extensión (default: desde env o `scenarie-001`) |
| `--gui` | Abre JMeter en modo gráfico (omite `-n`) |

### JVM

El script arranca JMeter con:

```
-Xms1g -Xmx3g -XX:MaxMetaspaceSize=256m
```

Ajustar `ENV_JMETER_HOME` en `scripts/jmeter/command-api-ms/dev.env` si JMeter está en una ruta distinta.

### Resultados

Los archivos de salida se escriben en `.tmp/jmeter/command-api-ms/`:

| Archivo | Contenido |
|---------|-----------|
| `{jmeter-file}.jtl` | Resultados de las muestras (CSV) |
| `{jmeter-file}.log` | Log de ejecución de JMeter |

Para generar un dashboard HTML desde el `.jtl`:

```bash
$JMETER_HOME/bin/jmeter -g .tmp/jmeter/command-api-ms/scenarie-001.jtl \
  -o .tmp/jmeter/command-api-ms/dashboard
```

---

## Test plan — `scenarie-001.jmx`

### Thread Group

| Parámetro | Valor |
|-----------|-------|
| Threads | 18 000 |
| Ramp-up | 1 s |
| Loops | Infinito (controlado por el timer) |
| On error | Continue |

### Throughput Shaping Timer (jp@gc)

Controla los TPS reales independientemente del número de hilos:

| Fase | TPS inicio | TPS fin | Duración |
|------|-----------|---------|----------|
| Carga sostenida | 14 500 | 14 500 | 120 s |
| Rampa de bajada | 14 500 | 1 | 60 s |

Total de ejecución: **3 minutos**.

### HTTP Sampler

| Campo | Valor |
|-------|-------|
| Método | `GET` |
| Host | `${host}` (leído de `.properties`) |
| Puerto | `${port}` (leído de `.properties`) |
| Path | `/api/commands` |
| Keep-Alive | `true` |

### Assertion

Valida que la respuesta sea HTTP `200`. Cualquier otro código marca la muestra como error.

### Listeners (gráficas)

| Listener | Propósito |
|----------|-----------|
| View Results Tree | Inspección de respuestas individuales (solo errores) |
| Active Threads Over Time | Evolución de hilos activos en el tiempo |
| Response Times Over Time | Latencia de respuesta por muestra |
| Transactions per Second | TPS reales durante la prueba |

---

## Métricas objetivo

| Métrica | Objetivo |
|---------|----------|
| TPS sostenido | 14 500 |
| Error rate | 0 % |
| Latencia p99 | ≤ 500 ms |
