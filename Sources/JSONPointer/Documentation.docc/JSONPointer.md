# ``JSONPointer``

Sendable, Foundation-free RFC 6901 JSON Pointer for Swift 6.

## Overview

`JSONPointer` parses and formats RFC 6901 pointer strings in both standard
form (e.g. `/foo/0`) and URI Fragment form (e.g. `#/foo/0`). It does not
bundle a JSON value type or couple to any specific JSON library — pair it
with whatever JSON representation you already use.

```swift
import JSONPointer

let p = try JSONPointer("/foo/bar/0")
for token in p.tokens {
    if let i = token.arrayIndex {
        // navigate array at index i
    } else {
        // navigate object at key token.value
    }
}
```

## Topics

### Pointer

- ``JSONPointer/init(_:)``
- ``JSONPointer/init(uriFragment:)``
- ``JSONPointer/init(tokens:)``
- ``JSONPointer/tokens``
- ``JSONPointer/description``
- ``JSONPointer/uriFragment``
- ``JSONPointer/appending(_:)-(Token)``
- ``JSONPointer/appending(_:)-(String)``

### Token

- ``JSONPointer/Token``
- ``JSONPointer/Token/value``
- ``JSONPointer/Token/arrayIndex``
- ``JSONPointer/Token/isNextElement``

### Errors

- ``JSONPointerError``
