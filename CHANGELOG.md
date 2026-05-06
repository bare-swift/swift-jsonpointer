# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.1.0] - 2026-05-06

### Added
- `JSONPointer` value type — Sendable, Hashable, parses and formats RFC 6901 pointer strings in both standard form (`/foo/0`) and URI Fragment form (`#/foo/0`, RFC 6901 §6).
- `JSONPointer.Token` — decoded UTF-8 reference token with `arrayIndex: Int?` (RFC 6901 §4) and `isNextElement: Bool` (`-` sentinel). `ExpressibleByStringLiteral` and `ExpressibleByIntegerLiteral`.
- `JSONPointer.appending(_:)` overloads for `Token` and `String` programmatic composition.
- `JSONPointerError` typed error enum (`missingLeadingSlash`, `invalidEscape(at:)`, `missingFragmentMarker`, `invalidPercentEncoding(at:)`).
- DocC documentation, full README example, NOTICE crediting upstream `jsonptr` and `json-pointer` Rust crates.

### Limitations (out of scope for v0.1)
- Generic `JSONPointable` protocol + tree navigation (`get(at:)`, `set`, `delete`). Users iterate `tokens` and walk their JSON tree directly. Defer to v0.2 once the Swift JSON ecosystem (swift-foundation `JSONValue`) settles.
- Direct integration with any specific JSON library.
- Relative JSON Pointer (the IETF draft adding `<parent>` and similar).
- JSONPath (RFC 9535) — entirely separate spec.
