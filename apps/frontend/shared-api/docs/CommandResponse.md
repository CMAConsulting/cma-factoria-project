
# CommandResponse


## Properties

Name | Type
------------ | -------------
`id` | string
`status` | string
`command` | string
`payload` | [CommandPayload](CommandPayload.md)
`metadata` | [CommandMetadata](CommandMetadata.md)
`result` | [CommandResultData](CommandResultData.md)
`error` | string
`createdAt` | Date
`completedAt` | Date

## Example

```typescript
import type { CommandResponse } from ''

// TODO: Update the object below with actual values
const example = {
  "id": cmd-550e8400-e29b-41d4-a716-446655440000,
  "status": pending,
  "command": deploy,
  "payload": null,
  "metadata": null,
  "result": null,
  "error": null,
  "createdAt": 2026-04-09T12:00:00Z,
  "completedAt": null,
} satisfies CommandResponse

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as CommandResponse
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


