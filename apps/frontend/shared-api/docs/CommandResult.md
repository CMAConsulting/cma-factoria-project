
# CommandResult


## Properties

Name | Type
------------ | -------------
`id` | string
`status` | string
`result` | [CommandResultData](CommandResultData.md)
`error` | string
`completedAt` | Date

## Example

```typescript
import type { CommandResult } from ''

// TODO: Update the object below with actual values
const example = {
  "id": null,
  "status": null,
  "result": null,
  "error": null,
  "completedAt": null,
} satisfies CommandResult

console.log(example)

// Convert the instance to a JSON string
const exampleJSON: string = JSON.stringify(example)
console.log(exampleJSON)

// Parse the JSON string back to an object
const exampleParsed = JSON.parse(exampleJSON) as CommandResult
console.log(exampleParsed)
```

[[Back to top]](#) [[Back to API list]](../README.md#api-endpoints) [[Back to Model list]](../README.md#models) [[Back to README]](../README.md)


