// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Copyright (c) 2026 The bare-swift Project Authors.

/// Sendable, Foundation-free RFC 6901 JSON Pointer.
///
/// JSON-tree agnostic: parses and formats pointer strings (standard form and
/// URI Fragment form) but does not bundle a JSON value type. Pair with
/// whatever JSON representation you already use; iterate ``tokens`` and walk
/// your tree.
public struct JSONPointer: Sendable, CustomStringConvertible {
    /// Decoded reference tokens. Empty array is the root pointer (``"" ``).
    /// Storage placeholder until ``Token`` lands in Task 6; replace with
    /// `[Token]` and reinstate `Hashable` then.
    public let tokens: [String]

    /// Build directly from already-decoded tokens.
    public init(tokens: [String]) {
        self.tokens = tokens
    }

    public var description: String { "" }
}
