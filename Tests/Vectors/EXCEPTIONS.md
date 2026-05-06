# Test-parity exceptions

Per [RFC-0002](https://github.com/bare-swift/bare-swift/blob/main/rfcs/0002-test-parity-policy.md), this file documents why some upstream test cases are not extracted as fixtures.

## Source: RFC 6901 (the canonical spec)

The strongest test vectors are the §5 and §6 reference tables in the RFC
itself. Those tables map a fixed example JSON document to the values reached
by each pointer. We can't validate the *resulting JSON values* without a JSON
tree (intentional v0.1 scope), but we can validate that each pointer parses
to the right token sequence. Each row of the §5 table is captured in
`ParseStandardTests.swift` and `FormatStandardTests.swift`; §6 in the URI-form
counterparts.

## Source: `jsonptr` (Rust crate)

`jsonptr` uses inline `#[test]` cases plus `proptest`-driven property tests.
Its anchor cases derive from RFC 6901 §5/§6, which we capture directly. Its
property tests are mirrored by `JSONPointerRoundTripTests.swift`.

The crate's tree-navigation surface (`resolve`, `assign`, `delete`) is out of
scope for swift-jsonpointer v0.1; tests for those features have no Swift
counterpart. Documented in CHANGELOG.

## Source: `json-pointer` (Rust crate)

Smaller crate; its parse/format tests are a subset of what we cover via the
RFC tables and the round-trip property test.

## Refresh

When upstream releases new versions, re-read inline tests and add Swift
equivalents for any new cases. Record source commits here when refreshing:

- `jsonptr`: tracked at upstream commit (record at next refresh)
- `json-pointer`: tracked at upstream commit (record at next refresh)
