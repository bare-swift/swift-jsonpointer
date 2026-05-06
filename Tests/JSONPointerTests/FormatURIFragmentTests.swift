// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Testing
@testable import JSONPointer

@Suite("JSONPointer format — URI Fragment form")
struct FormatURIFragmentTests {
    @Test("empty pointer formats to '#'")
    func empty() {
        let p = JSONPointer(tokens: [])
        #expect(p.uriFragment == "#")
    }

    @Test("RFC 6901 §6 round-trip via tokens")
    func roundTripFromTokens() {
        let rows: [([String], String)] = [
            (["foo"],         "#/foo"),
            (["foo", "0"],    "#/foo/0"),
            ([""],            "#/"),
            (["a/b"],         "#/a~1b"),
            (["c%d"],         "#/c%25d"),
            (["e^f"],         "#/e%5Ef"),
            (["g|h"],         "#/g%7Ch"),
            (["i\\j"],        "#/i%5Cj"),
            (["k\"l"],        "#/k%22l"),
            ([" "],           "#/%20"),
            (["m~n"],         "#/m~0n"),
        ]
        for (vals, expected) in rows {
            let p = JSONPointer(tokens: vals.map { JSONPointer.Token($0) })
            #expect(p.uriFragment == expected, "tokens=\(vals) got=\(p.uriFragment)")
        }
    }

    @Test("multi-byte UTF-8 percent-encodes uppercase")
    func utf8() {
        let p = JSONPointer(tokens: [JSONPointer.Token("世")])
        #expect(p.uriFragment == "#/%E4%B8%96")
    }

    @Test("Standard form parse → URI format is the canonical lift")
    func standardToURI() throws {
        let p = try JSONPointer("/m~0n/c%d")
        #expect(p.uriFragment == "#/m~0n/c%25d")
    }

    @Test("URI parse → URI format round-trip")
    func uriRoundTrip() throws {
        let inputs = [
            "#", "#/foo", "#/foo/0", "#/", "#/a~1b", "#/c%25d",
            "#/m~0n", "#/%E4%B8%96",
        ]
        for input in inputs {
            let p = try JSONPointer(uriFragment: input)
            #expect(p.uriFragment == input, "input=\(input)")
        }
    }
}
