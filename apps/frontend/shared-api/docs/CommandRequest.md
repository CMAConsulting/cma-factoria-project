
# CommandRequest


## Properties

Name | Type
------------ | -------------
`command` | string
`payload` | [CommandPayload](CommandPayload.md)
`metadata` | [CommandMetadata](CommandMetadata.md)

## Example

```typescript
import type { CommandRequest } from ''

// TODO: Update the object below with actual values
const example = {
  "command": deploy,
  "payload": null,
  "metadata": null,
} satisfies CommandRequest

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as CommandRequest
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


