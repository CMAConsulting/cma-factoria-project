# CommandsApi

All URIs are relative to *http://localhost:3000/api*

| Method | HTTP request | Description |
|------------- | ------------- | -------------|
| [**executeCommand**](CommandsApi.md#executecommand) | **POST** /commands | Enviar un comando para ejecución |
| [**getCommand**](CommandsApi.md#getcommand) | **GET** /commands/{id} | Consultar estado de un comando |
| [**getCommandResult**](CommandsApi.md#getcommandresult) | **GET** /commands/{id}/result | Obtener resultado de un comando |
| [**listCommands**](CommandsApi.md#listcommands) | **GET** /commands | Listar comandos |



## executeCommand

> CommandResponse executeCommand(commandRequest)

Enviar un comando para ejecución

### Example

```ts
import {
  Configuration,
  CommandsApi,
} from '';
import type { ExecuteCommandRequest } from '';

async function example() {
  console.log("🚀 Testing  SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new CommandsApi(config);

  const body = {
    // CommandRequest
    commandRequest: {"command":"deploy","payload":{"environment":"staging","version":"1.2.0"},"metadata":{"source":"ci-pipeline","correlationId":"deploy-123"}},
  } satisfies ExecuteCommandRequest;

  try {
    const data = await api.executeCommand(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **commandRequest** | [CommandRequest](CommandRequest.md) |  | |

### Return type

[**CommandResponse**](CommandResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: `application/json`
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **202** | Comando aceptado para procesamiento |  -  |
| **400** | Solicitud inválida |  -  |
| **401** | No autorizado |  -  |
| **429** | Demasiadas solicitudes |  -  |
| **500** | Error interno del servidor |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getCommand

> CommandResponse getCommand(id)

Consultar estado de un comando

### Example

```ts
import {
  Configuration,
  CommandsApi,
} from '';
import type { GetCommandRequest } from '';

async function example() {
  console.log("🚀 Testing  SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new CommandsApi(config);

  const body = {
    // string | ID del comando
    id: cmd-550e8400-e29b-41d4-a716-446655440000,
  } satisfies GetCommandRequest;

  try {
    const data = await api.getCommand(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **id** | `string` | ID del comando | [Defaults to `undefined`] |

### Return type

[**CommandResponse**](CommandResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | Estado del comando |  -  |
| **404** | Recurso no encontrado |  -  |
| **401** | No autorizado |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## getCommandResult

> CommandResult getCommandResult(id)

Obtener resultado de un comando

### Example

```ts
import {
  Configuration,
  CommandsApi,
} from '';
import type { GetCommandResultRequest } from '';

async function example() {
  console.log("🚀 Testing  SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new CommandsApi(config);

  const body = {
    // string | ID del comando
    id: cmd-550e8400-e29b-41d4-a716-446655440000,
  } satisfies GetCommandResultRequest;

  try {
    const data = await api.getCommandResult(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **id** | `string` | ID del comando | [Defaults to `undefined`] |

### Return type

[**CommandResult**](CommandResult.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | Resultado del comando |  -  |
| **404** | Recurso no encontrado |  -  |
| **401** | No autorizado |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


## listCommands

> CommandListResponse listCommands(status, source, limit, offset)

Listar comandos

### Example

```ts
import {
  Configuration,
  CommandsApi,
} from '';
import type { ListCommandsRequest } from '';

async function example() {
  console.log("🚀 Testing  SDK...");
  const config = new Configuration({ 
    // Configure HTTP bearer authorization: bearerAuth
    accessToken: "YOUR BEARER TOKEN",
  });
  const api = new CommandsApi(config);

  const body = {
    // 'pending' | 'processing' | 'completed' | 'failed' | Filtrar por estado (optional)
    status: status_example,
    // string | Filtrar por fuente (optional)
    source: source_example,
    // number | Límite de resultados (optional)
    limit: 56,
    // number | Offset de paginación (optional)
    offset: 56,
  } satisfies ListCommandsRequest;

  try {
    const data = await api.listCommands(body);
    console.log(data);
  } catch (error) {
    console.error(error);
  }
}

// Run the test
example().catch(console.error);
```

### Parameters


| Name | Type | Description  | Notes |
|------------- | ------------- | ------------- | -------------|
| **status** | `pending`, `processing`, `completed`, `failed` | Filtrar por estado | [Optional] [Defaults to `undefined`] [Enum: pending, processing, completed, failed] |
| **source** | `string` | Filtrar por fuente | [Optional] [Defaults to `undefined`] |
| **limit** | `number` | Límite de resultados | [Optional] [Defaults to `20`] |
| **offset** | `number` | Offset de paginación | [Optional] [Defaults to `0`] |

### Return type

[**CommandListResponse**](CommandListResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: `application/json`


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
| **200** | Lista de comandos |  -  |
| **401** | No autorizado |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)

