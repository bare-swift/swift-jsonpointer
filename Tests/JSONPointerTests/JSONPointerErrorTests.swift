// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Testing
@testable import JSONPointer

@Suite("JSONPointerError")
struct JSONPointerErrorTests {
    @Test("JSONPointerError is Sendable, Equatable, Error")
    func conformances() {
        let a: JSONPointerError = .missingLeadingSlash
        let b: JSONPointerError = .missingLeadingSlash
        let c: JSONPointerError = .invalidEscape(at: 5)
        let d: JSONPointerError = .invalidEscape(at: 5)
        let e: JSONPointerError = .invalidEscape(at: 6)
        #expect(a == b)
        #expect(a != c)
        #expect(c == d)
        #expect(c != e)
        let _: any Error = a
        let _: any Sendable = a
    }

    @Test("All four cases are distinguishable")
    func cases() {
        let xs: [JSONPointerError] = [
            .missingLeadingSlash,
            .invalidEscape(at: 0),
            .missingFragmentMarker,
            .invalidPercentEncoding(at: 0),
        ]
        for i in 0..<xs.count {
            for j in 0..<xs.count where i != j {
                #expect(xs[i] != xs[j])
            }
        }
    }
}
