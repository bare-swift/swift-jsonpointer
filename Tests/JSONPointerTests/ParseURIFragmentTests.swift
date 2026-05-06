// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Testing
@testable import JSONPointer

@Suite("JSONPointer parse — URI Fragment (RFC 6901 §6)")
struct ParseURIFragmentTests {
    @Test("'#' alone is the root pointer")
    func empty() throws {
        let p = try JSONPointer(uriFragment: "#")
        #expect(p.tokens.isEmpty)
    }

    @Test("RFC 6901 §6 table — exact tokenization")
    func referenceTable() throws {
        let rows: [(String, [String])] = [
            ("#/foo",     ["foo"]),
            ("#/foo/0",   ["foo", "0"]),
            ("#/",        [""]),
            ("#/a~1b",    ["a/b"]),
            ("#/c%25d",   ["c%d"]),
            ("#/e%5Ef",   ["e^f"]),
            ("#/g%7Ch",   ["g|h"]),
            ("#/i%5Cj",   ["i\\j"]),
            ("#/k%22l",   ["k\"l"]),
            ("#/%20",     [" "]),
            ("#/m~0n",    ["m~n"]),
        ]
        for (input, expected) in rows {
            let p = try JSONPointer(uriFragment: input)
            let got = p.tokens.map(\.value)
            #expect(got == expected, "input=\(input.debugDescription) got=\(got)")
        }
    }

    @Test("lowercase hex is accepted")
    func lowercaseHex() throws {
        let p = try JSONPointer(uriFragment: "#/c%25d")
        #expect(p.tokens.map(\.value) == ["c%d"])
        let q = try JSONPointer(uriFragment: "#/e%5ef")
        #expect(q.tokens.map(\.value) == ["e^f"])
    }

    @Test("multi-byte UTF-8 percent-encoded")
    func multiByteUTF8() throws {
        let p = try JSONPointer(uriFragment: "#/%E4%B8%96")
        #expect(p.tokens.map(\.value) == ["世"])
    }

    @Test("escape + percent combinations")
    func combo() throws {
        let p = try JSONPointer(uriFragment: "#/a~1b/c%25d")
        #expect(p.tokens.map(\.value) == ["a/b", "c%d"])
    }
}
