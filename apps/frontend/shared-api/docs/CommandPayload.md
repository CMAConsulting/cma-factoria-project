
# CommandPayload


## Properties

Name | Type
------------ | -------------
`environment` | string
`version` | string

## Example

```typescript
import type { CommandPayload } from ''

// TODO: Update the object below with actual values
const example = {
  "environment": staging,
  "version": 1.2.0,
} satisfies CommandPayload

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as CommandPayload
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


