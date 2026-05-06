// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Testing
@testable import JSONPointer

@Suite("JSONPointer.appending")
struct AppendingTests {
    @Test("appending Token to root")
    func appendToRoot() {
        let p = JSONPointer(tokens: []).appending(JSONPointer.Token("foo"))
        #expect(p.tokens.map(\.value) == ["foo"])
        #expect(p.description == "/foo")
    }

    @Test("appending String literal token")
    func appendString() {
        let p = JSONPointer(tokens: []).appending("foo")
        #expect(p.tokens.map(\.value) == ["foo"])
    }

    @Test("appending integer literal builds decimal token")
    func appendInteger() {
        let p = JSONPointer(tokens: ["foo"]).appending(JSONPointer.Token(0))
        #expect(p.tokens.map(\.value) == ["foo", "0"])
        #expect(p.description == "/foo/0")
    }

    @Test("chained appends")
    func chained() {
        let p = JSONPointer(tokens: [])
            .appending("a")
            .appending("b")
            .appending(JSONPointer.Token(7))
        #expect(p.description == "/a/b/7")
    }

    @Test("appending preserves the original (value semantics)")
    func valueSemantics() {
        let original = JSONPointer(tokens: ["foo"])
        let extended = original.appending("bar")
        #expect(original.tokens.map(\.value) == ["foo"])
        #expect(extended.tokens.map(\.value) == ["foo", "bar"])
    }

    @Test("appending a token containing '/' formats with '~1'")
    func appendWithEscape() {
        let p = JSONPointer(tokens: []).appending("a/b")
        #expect(p.tokens.first?.value == "a/b")
        #expect(p.description == "/a~1b")
    }
}
