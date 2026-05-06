// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Testing
@testable import JSONPointer

@Suite("JSONPointer parse — standard form (RFC 6901 §5)")
struct ParseStandardTests {
    @Test("empty pointer parses to empty tokens (root)")
    func empty() throws {
        let p = try JSONPointer("")
        #expect(p.tokens.isEmpty)
    }

    @Test("RFC 6901 §5 table — exact tokenization")
    func referenceTable() throws {
        let rows: [(String, [String])] = [
            ("/foo",   ["foo"]),
            ("/foo/0", ["foo", "0"]),
            ("/",      [""]),
            ("/a~1b",  ["a/b"]),
            ("/c%d",   ["c%d"]),
            ("/e^f",   ["e^f"]),
            ("/g|h",   ["g|h"]),
            ("/i\\j",  ["i\\j"]),
            ("/k\"l",  ["k\"l"]),
            ("/ ",     [" "]),
            ("/m~0n",  ["m~n"]),
        ]
        for (input, expected) in rows {
            let p = try JSONPointer(input)
            let got = p.tokens.map(\.value)
            #expect(got == expected, "input=\(input.debugDescription) got=\(got)")
        }
    }

    @Test("escape ordering: ~01 decodes to ~1, not /")
    func escapeOrdering() throws {
        let p = try JSONPointer("/~01")
        #expect(p.tokens.map(\.value) == ["~1"])
    }

    @Test("multi-segment pointer with mixed escapes")
    func multiSegment() throws {
        let p = try JSONPointer("/a~0b/c~1d/e")
        #expect(p.tokens.map(\.value) == ["a~b", "c/d", "e"])
    }

    @Test("trailing slash creates an empty final token")
    func trailingSlash() throws {
        let p = try JSONPointer("/foo/")
        #expect(p.tokens.map(\.value) == ["foo", ""])
    }

    @Test("Unicode passthrough")
    func unicode() throws {
        let p = try JSONPointer("/héllo/世界")
        #expect(p.tokens.map(\.value) == ["héllo", "世界"])
    }
}
