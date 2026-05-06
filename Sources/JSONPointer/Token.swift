// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Copyright (c) 2026 The bare-swift Project Authors.

extension JSONPointer {
    /// A single decoded reference token.
    ///
    /// `value` is the decoded UTF-8 string with no `~0`/`~1` or percent-
    /// encoding applied — it may contain `/` or `~` freely. The pointer
    /// formatters re-apply the appropriate escaping at format time.
    public struct Token: Sendable, Hashable, CustomStringConvertible,
                         ExpressibleByStringLiteral, ExpressibleByIntegerLiteral {
        public let value: String

        public init(_ value: String) {
            self.value = value
        }

        public init(stringLiteral: String) {
            self.value = stringLiteral
        }

        public init(integerLiteral: Int) {
            self.value = String(integerLiteral)
        }

        /// Non-negative decimal interpretation per RFC 6901 §4.
        ///
        /// Returns `nil` for the empty string, `"-"`, leading-zero forms
        /// (`"01"`, `"00"`), negatives, and any token containing a non-digit.
        public var arrayIndex: Int? {
            let s = value
            guard !s.isEmpty else { return nil }
            for scalar in s.unicodeScalars {
                guard scalar.value >= 0x30 && scalar.value <= 0x39 else { return nil }
            }
            if s.count > 1 && s.first == "0" { return nil }
            return Int(s)
        }

        /// `true` iff the token is the literal `"-"` (RFC 6901 §4 next-element sentinel).
        public var isNextElement: Bool { value == "-" }

        public var description: String { value }
    }
}
