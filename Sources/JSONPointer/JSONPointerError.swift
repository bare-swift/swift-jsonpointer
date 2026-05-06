// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Copyright (c) 2026 The bare-swift Project Authors.

/// Errors thrown by ``JSONPointer`` parsing initializers.
public enum JSONPointerError: Error, Equatable, Sendable {
    /// A non-empty pointer that does not start with `/`.
    case missingLeadingSlash

    /// A `~` was not followed by `0` or `1`. The associated value is the
    /// 0-based UTF-8 byte offset of the offending escape's *second* byte
    /// (the byte that should have been `0` or `1`) within the input string.
    case invalidEscape(at: Int)

    /// A URI Fragment pointer that does not start with `#`.
    case missingFragmentMarker

    /// A `%` percent-encoding sequence that is not `%HH` (two hex digits).
    /// The associated value is the 0-based UTF-8 byte offset of the `%`.
    case invalidPercentEncoding(at: Int)
}
