# swift-jsonpointer

Sendable, Foundation-free RFC 6901 JSON Pointer for Swift 6. JSON-tree agnostic — pair with any JSON library.

Part of the [bare-swift](https://github.com/bare-swift) ecosystem.

## Install

Add to your `Package.swift`:

```swift
.package(url: "https://github.com/bare-swift/swift-jsonpointer.git", from: "0.1.0")
```

Then depend on the `JSONPointer` product:

```swift
.product(name: "JSONPointer", package: "swift-jsonpointer")
```

## Usage

```swift
import JSONPointer

// Standard form (RFC 6901)
let p = try JSONPointer("/foo/0")
print(p.tokens.map(\.value))     // ["foo", "0"]
print(p.tokens[1].arrayIndex!)   // 0
print(p.description)             // "/foo/0"

// URI Fragment form (RFC 6901 §6)
let q = try JSONPointer(uriFragment: "#/c%25d")
print(q.tokens.map(\.value))     // ["c%d"]
print(q.uriFragment)             // "#/c%25d"

// Programmatic composition
let r = JSONPointer(tokens: [])
    .appending("foo")            // Token("foo")
    .appending(0)                // Token("0")
print(r.description)             // "/foo/0"

// Navigation is left to the caller; iterate `tokens` and walk your JSON tree.
```

## Documentation

Full DocC documentation: <https://bare-swift.github.io/swift-jsonpointer/>

## Source

Translated from the Rust crates [`jsonptr`](https://crates.io/crates/jsonptr) and [`json-pointer`](https://crates.io/crates/json-pointer). Conforms to [RFC 6901](https://datatracker.ietf.org/doc/html/rfc6901).

## License

Apache 2.0 with LLVM exception. See [LICENSE](./LICENSE) and [NOTICE](./NOTICE).
