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

    /// Decode `%HH` percent-encoded bytes; reinterpret the resulting byte
    /// stream as UTF-8.
    ///
    /// `byteOffsetStart` is the offset of `s` within the original URI
    /// fragment string (used for error position reporting).
    static func percentDecode(_ s: Substring, byteOffsetStart: Int) throws(JSONPointerError) -> String {
        var bytes: [UInt8] = []
        bytes.reserveCapacity(s.utf8.count)
        let utf8 = Array(s.utf8)
        var i = 0
        while i < utf8.count {
            let b = utf8[i]
            if b == 0x25 {  // '%'
                let pctOffset = byteOffsetStart + i
                guard i + 2 < utf8.count else {
                    throw .invalidPercentEncoding(at: pctOffset)
                }
                let hi = hexDigit(utf8[i + 1])
                let lo = hexDigit(utf8[i + 2])
                guard let h = hi, let l = lo else {
                    throw .invalidPercentEncoding(at: pctOffset)
                }
                bytes.append(UInt8(h * 16 + l))
                i += 3
            } else {
                bytes.append(b)
                i += 1
            }
        }
        return String(decoding: bytes, as: UTF8.self)
    }

    /// Encode a string as URI percent-encoded bytes, preserving the
    /// unreserved set per RFC 3986 §2.3 (ALPHA / DIGIT / `-` / `.` / `_` / `~`).
    static func percentEncode(_ value: String) -> String {
        var out = ""
        out.reserveCapacity(value.utf8.count)
        for b in value.utf8 {
            if isURIUnreserved(b) {
                out.append(Character(UnicodeScalar(b)))
            } else {
                out.append("%")
                out.append(hexNibble(b >> 4))
                out.append(hexNibble(b & 0x0F))
            }
        }
        return out
    }

    @inlinable
    static func hexDigit(_ b: UInt8) -> Int? {
        switch b {
        case 0x30...0x39: return Int(b - 0x30)
        case 0x41...0x46: return Int(b - 0x41 + 10)
        case 0x61...0x66: return Int(b - 0x61 + 10)
        default: return nil
        }
    }

    @inlinable
    static func hexNibble(_ n: UInt8) -> Character {
        switch n {
        case 0...9:    return Character(UnicodeScalar(0x30 + n))
        case 10...15:  return Character(UnicodeScalar(0x41 + (n - 10)))
        default:       return "0"
        }
    }

    @inlinable
    static func isURIUnreserved(_ b: UInt8) -> Bool {
        switch b {
        case 0x30...0x39: return true
        case 0x41...0x5A: return true
        case 0x61...0x7A: return true
        case 0x2D, 0x2E, 0x5F, 0x7E: return true
        default: return false
        }
    }
}
