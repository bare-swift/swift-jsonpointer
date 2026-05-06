// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Testing
@testable import JSONPointer

@Suite("JSONPointer parse — error paths")
struct ParseErrorTests {
    @Test("non-empty pointer without leading '/' throws .missingLeadingSlash")
    func standardMissingSlash() {
        #expect(throws: JSONPointerError.missingLeadingSlash) {
            try JSONPointer("foo")
        }
        #expect(throws: JSONPointerError.missingLeadingSlash) {
            try JSONPointer("a/b")
        }
    }

    @Test("'~' at end of token throws .invalidEscape")
    func standardEscapeAtEnd() {
        do {
            _ = try JSONPointer("/~")
            Issue.record("expected throw")
        } catch let e as JSONPointerError {
            #expect(e == .invalidEscape(at: 2))
        } catch {
            Issue.record("wrong error type: \(error)")
        }
    }

    @Test("'~x' (x != '0','1') throws .invalidEscape")
    func standardEscapeBadByte() {
        do {
            _ = try JSONPointer("/~x")
            Issue.record("expected throw")
        } catch let e as JSONPointerError {
            #expect(e == .invalidEscape(at: 2))
        } catch {
            Issue.record("wrong error type: \(error)")
        }
    }

    @Test("URI fragment without '#' throws .missingFragmentMarker")
    func uriMissingHash() {
        #expect(throws: JSONPointerError.missingFragmentMarker) {
            try JSONPointer(uriFragment: "/foo")
        }
        #expect(throws: JSONPointerError.missingFragmentMarker) {
            try JSONPointer(uriFragment: "")
        }
    }

    @Test("'%' followed by less than two bytes throws .invalidPercentEncoding")
    func uriPercentTruncated() {
        do {
            _ = try JSONPointer(uriFragment: "#/%")
            Issue.record("expected throw")
        } catch let e as JSONPointerError {
            #expect(e == .invalidPercentEncoding(at: 2))
        } catch {
            Issue.record("wrong error type: \(error)")
        }
        do {
            _ = try JSONPointer(uriFragment: "#/%2")
            Issue.record("expected throw")
        } catch let e as JSONPointerError {
            #expect(e == .invalidPercentEncoding(at: 2))
        } catch {
            Issue.record("wrong error type: \(error)")
        }
    }

    @Test("'%' followed by non-hex throws .invalidPercentEncoding")
    func uriPercentNonHex() {
        do {
            _ = try JSONPointer(uriFragment: "#/%G0")
            Issue.record("expected throw")
        } catch let e as JSONPointerError {
            #expect(e == .invalidPercentEncoding(at: 2))
        } catch {
            Issue.record("wrong error type: \(error)")
        }
        do {
            _ = try JSONPointer(uriFragment: "#/%0Z")
            Issue.record("expected throw")
        } catch let e as JSONPointerError {
            #expect(e == .invalidPercentEncoding(at: 2))
        } catch {
            Issue.record("wrong error type: \(error)")
        }
    }
}
