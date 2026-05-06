// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Testing
@testable import JSONPointer

@Suite("JSONPointer round-trip")
struct JSONPointerRoundTripTests {
    static let sampleTokens: [String] = [
        "",
        "0", "1", "42",
        "-",
        "a", "abc", "héllo", "世界", "𝄞",
        "/", "//", "~", "~~",
        "/a", "a/", "a/b/c",
        "~/", "/~", "~0", "~1", "~01",
        "%", "%25", "#", "##",
        "k\"l", "i\\j", "g|h", "e^f", " ",
        "ctrl-\u{0001}-\u{0007}-end",
        "tab\there", "nl\nhere",
    ]

    @Test("standard form: tokens → format → parse round-trips for every sample")
    func standardRoundTrip() throws {
        for v in Self.sampleTokens {
            let p = JSONPointer(tokens: [JSONPointer.Token(v)])
            let formatted = p.description
            let parsed = try JSONPointer(formatted)
            #expect(parsed.tokens.map(\.value) == [v], "value=\(v.debugDescription)")
        }
    }

    @Test("URI fragment form: tokens → format → parse round-trips for every sample")
    func uriRoundTrip() throws {
        for v in Self.sampleTokens {
            let p = JSONPointer(tokens: [JSONPointer.Token(v)])
            let formatted = p.uriFragment
            let parsed = try JSONPointer(uriFragment: formatted)
            #expect(parsed.tokens.map(\.value) == [v], "value=\(v.debugDescription)")
        }
    }

    @Test("multi-token round trip across both forms")
    func multiToken() throws {
        for i in 0..<(Self.sampleTokens.count - 3) {
            let vals = Array(Self.sampleTokens[i..<(i + 4)])
            let p = JSONPointer(tokens: vals.map { JSONPointer.Token($0) })

            let standardParsed = try JSONPointer(p.description)
            #expect(standardParsed.tokens.map(\.value) == vals, "i=\(i) standard")

            let uriParsed = try JSONPointer(uriFragment: p.uriFragment)
            #expect(uriParsed.tokens.map(\.value) == vals, "i=\(i) uri")
        }
    }

    @Test("RFC 6901 §5 + §6 cross-form: parse standard, format URI, parse URI yields same tokens")
    func crossForm() throws {
        let standardInputs = [
            "/foo", "/foo/0", "/", "/a~1b", "/c%d", "/m~0n",
        ]
        for s in standardInputs {
            let p = try JSONPointer(s)
            let uri = p.uriFragment
            let q = try JSONPointer(uriFragment: uri)
            #expect(q.tokens.map(\.value) == p.tokens.map(\.value), "input=\(s)")
        }
    }

    @Test("Pseudo-random bytes round-trip across both forms")
    func random() throws {
        var seed: UInt64 = 0x9E37_79B9_7F4A_7C15
        var samples: [String] = []
        for _ in 0..<50 {
            seed ^= seed << 13
            seed ^= seed >> 7
            seed ^= seed << 17
            let n = 1 + Int(seed % 12)
            var s = ""
            var local = seed
            for _ in 0..<n {
                local ^= local << 7
                local ^= local >> 9
                let b = UInt8((local & 0x7F))
                let printable = max(0x20, min(0x7E, b))
                s.append(Character(UnicodeScalar(printable)))
            }
            samples.append(s)
        }
        for v in samples {
            let p = JSONPointer(tokens: [JSONPointer.Token(v)])
            let std = try JSONPointer(p.description)
            #expect(std.tokens.map(\.value) == [v], "std value=\(v.debugDescription)")
            let uri = try JSONPointer(uriFragment: p.uriFragment)
            #expect(uri.tokens.map(\.value) == [v], "uri value=\(v.debugDescription)")
        }
    }
}
