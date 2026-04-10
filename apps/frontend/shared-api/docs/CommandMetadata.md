
# CommandMetadata


## Properties

Name | Type
------------ | -------------
`source` | string
`correlationId` | string

## Example

```typescript
import type { CommandMetadata } from ''

// TODO: Update the object below with actual values
const example = {
  "source": ci-pipeline,
  "correlationId": deploy-123,
} satisfies CommandMetadata

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as CommandMetadata
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


