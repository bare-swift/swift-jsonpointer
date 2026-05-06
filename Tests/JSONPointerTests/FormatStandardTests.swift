// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Testing
@testable import JSONPointer

@Suite("JSONPointer format — standard form")
struct FormatStandardTests {
    @Test("empty pointer formats to empty string")
    func empty() {
        let p = JSONPointer(tokens: [])
        #expect(p.description == "")
    }

    @Test("simple single-token pointer")
    func single() {
        let p = JSONPointer(tokens: ["foo"])
        #expect(p.description == "/foo")
    }

    @Test("multi-token pointer")
    func multi() {
        let p = JSONPointer(tokens: ["foo", "0"])
        #expect(p.description == "/foo/0")
    }

    @Test("token containing '/' encodes as '~1'")
    func slashEncode() {
        let p = JSONPointer(tokens: ["a/b"])
        #expect(p.description == "/a~1b")
    }

    @Test("token containing '~' encodes as '~0'")
    func tildeEncode() {
        let p = JSONPointer(tokens: ["m~n"])
        #expect(p.description == "/m~0n")
    }

    @Test("token containing both '/' and '~'")
    func bothEncode() {
        let p = JSONPointer(tokens: ["~/~"])
        #expect(p.description == "/~0~1~0")
    }

    @Test("empty token formats as '/'")
    func emptyToken() {
        let p = JSONPointer(tokens: [""])
        #expect(p.description == "/")
    }

    @Test("trailing empty token preserves trailing slash")
    func trailingEmpty() {
        let p = JSONPointer(tokens: ["foo", ""])
        #expect(p.description == "/foo/")
    }

    @Test("RFC 6901 §5 round-trip: parse → format == identity")
    func roundTripRFCExamples() throws {
        let inputs = [
            "", "/foo", "/foo/0", "/", "/a~1b", "/c%d", "/e^f",
            "/g|h", "/i\\j", "/k\"l", "/ ", "/m~0n",
        ]
        for input in inputs {
            let p = try JSONPointer(input)
            #expect(p.description == input, "input=\(input.debugDescription)")
        }
    }
}
