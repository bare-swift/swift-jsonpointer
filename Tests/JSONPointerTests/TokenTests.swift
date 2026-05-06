// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Testing
@testable import JSONPointer

@Suite("JSONPointer.Token")
struct TokenTests {
    @Test("Token stores its decoded value verbatim")
    func value() {
        let t = JSONPointer.Token("foo/bar~baz")
        #expect(t.value == "foo/bar~baz")
        #expect(t.description == "foo/bar~baz")
    }

    @Test("ExpressibleByStringLiteral and ExpressibleByIntegerLiteral")
    func literals() {
        let s: JSONPointer.Token = "foo"
        let i: JSONPointer.Token = 42
        #expect(s.value == "foo")
        #expect(i.value == "42")
    }

    @Test("Equatable + Hashable")
    func conformances() {
        let a: JSONPointer.Token = "x"
        let b: JSONPointer.Token = "x"
        let c: JSONPointer.Token = "y"
        #expect(a == b)
        #expect(a != c)
        var set: Set<JSONPointer.Token> = []
        set.insert(a)
        #expect(set.contains(b))
    }

    @Test("arrayIndex parses non-negative decimal")
    func arrayIndexHappy() {
        #expect(JSONPointer.Token("0").arrayIndex == 0)
        #expect(JSONPointer.Token("1").arrayIndex == 1)
        #expect(JSONPointer.Token("42").arrayIndex == 42)
        #expect(JSONPointer.Token("12345").arrayIndex == 12345)
    }

    @Test("arrayIndex rejects RFC 6901 §4 invalid forms")
    func arrayIndexInvalid() {
        #expect(JSONPointer.Token("").arrayIndex == nil)
        #expect(JSONPointer.Token("-").arrayIndex == nil)
        #expect(JSONPointer.Token("01").arrayIndex == nil)
        #expect(JSONPointer.Token("00").arrayIndex == nil)
        #expect(JSONPointer.Token("-1").arrayIndex == nil)
        #expect(JSONPointer.Token("42abc").arrayIndex == nil)
        #expect(JSONPointer.Token("abc").arrayIndex == nil)
        #expect(JSONPointer.Token(" 1").arrayIndex == nil)
    }

    @Test("isNextElement matches only '-'")
    func nextElement() {
        #expect(JSONPointer.Token("-").isNextElement == true)
        #expect(JSONPointer.Token("").isNextElement == false)
        #expect(JSONPointer.Token("0").isNextElement == false)
        #expect(JSONPointer.Token("--").isNextElement == false)
    }

    @Test("Token is Sendable")
    func sendable() {
        let _: any Sendable = JSONPointer.Token("x")
    }
}
