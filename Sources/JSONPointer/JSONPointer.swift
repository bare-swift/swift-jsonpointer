// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Copyright (c) 2026 The bare-swift Project Authors.

/// Sendable, Foundation-free RFC 6901 JSON Pointer.
///
/// JSON-tree agnostic: parses and formats pointer strings (standard form and
/// URI Fragment form) but does not bundle a JSON value type. Pair with
/// whatever JSON representation you already use; iterate ``tokens`` and walk
/// your tree.
public struct JSONPointer: Sendable, Hashable, CustomStringConvertible {
    /// Decoded reference tokens. Empty array is the root pointer (``"" ``).
    public let tokens: [Token]

    /// Build directly from already-decoded tokens.
    public init(tokens: [Token]) {
        self.tokens = tokens
    }

    /// Parse the standard RFC 6901 pointer string form.
    ///
    /// - The empty string is the root pointer (no tokens).
    /// - Otherwise the string must start with `/`. Each `/`-separated
    ///   segment is one reference token; `~1` decodes to `/` and `~0` to `~`.
    public init(_ string: String) throws(JSONPointerError) {
        if string.isEmpty {
            self.tokens = []
            return
        }
        guard string.utf8.first == 0x2F else {
            throw .missingLeadingSlash
        }
        var tokens: [Token] = []
        let body = string.dropFirst()
        var segmentStart = body.startIndex
        var byteOffsetOfSegment = 1
        var i = body.startIndex
        var byte = 1
        while i < body.endIndex {
            let scalar = body.unicodeScalars[i]
            if scalar == "/" {
                let segment = body[segmentStart..<i]
                let decoded = try Escaping.decodeStandardToken(segment, byteOffsetStart: byteOffsetOfSegment)
                tokens.append(Token(decoded))
                let advance = body.unicodeScalars.index(after: i)
                segmentStart = advance
                byte += String(scalar).utf8.count
                byteOffsetOfSegment = byte
                i = advance
                continue
            }
            byte += String(scalar).utf8.count
            i = body.unicodeScalars.index(after: i)
        }
        let segment = body[segmentStart..<body.endIndex]
        let decoded = try Escaping.decodeStandardToken(segment, byteOffsetStart: byteOffsetOfSegment)
        tokens.append(Token(decoded))
        self.tokens = tokens
    }

    /// Standard RFC 6901 string form.
    public var description: String {
        if tokens.isEmpty { return "" }
        var out = ""
        for t in tokens {
            out.append("/")
            out.append(Escaping.encodeStandardToken(t.value))
        }
        return out
    }
}
