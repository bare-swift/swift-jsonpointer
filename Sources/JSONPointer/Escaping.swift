// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Copyright (c) 2026 The bare-swift Project Authors.

/// Internal namespace for RFC 6901 escape and URI percent-encoding helpers.
enum Escaping {
    /// Decode `~0` → `~` and `~1` → `/` in a token. Per RFC 6901 §4 the two
    /// substitutions are applied as a single left-to-right pass; this matches
    /// either ordering of the prescribed substitutions for non-overlapping
    /// inputs and pins the behaviour for overlapping inputs like `~01` → `~1`.
    ///
    /// `byteOffsetStart` is the offset of the *token's* first byte within the
    /// containing pointer string; it's added to the local error position so
    /// callers report errors against the original input.
    static func decodeStandardToken(_ s: Substring, byteOffsetStart: Int) throws(JSONPointerError) -> String {
        var out = ""
        out.reserveCapacity(s.utf8.count)
        var iter = s.unicodeScalars.makeIterator()
        var byte = byteOffsetStart
        while let scalar = iter.next() {
            if scalar == "~" {
                let tildeByteOffset = byte
                byte += 1
                guard let next = iter.next() else {
                    throw .invalidEscape(at: tildeByteOffset + 1)
                }
                switch next {
                case "0": out.append("~")
                case "1": out.append("/")
                default:  throw .invalidEscape(at: tildeByteOffset + 1)
                }
                byte += String(next).utf8.count
            } else {
                out.unicodeScalars.append(scalar)
                byte += String(scalar).utf8.count
            }
        }
        return out
    }

    /// Encode `~` → `~0` and `/` → `~1` for the standard pointer form.
    static func encodeStandardToken(_ value: String) -> String {
        var out = ""
        out.reserveCapacity(value.utf8.count + 2)
        for scalar in value.unicodeScalars {
            switch scalar {
            case "~": out.append("~0")
            case "/": out.append("~1")
            default:  out.unicodeScalars.append(scalar)
            }
        }
        return out
    }
}
