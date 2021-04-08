//
// Copyright (c) Vatsal Manot
//

#if canImport(SwiftSyntax)

import Swift
import SwiftSyntax

#if !canImport(SwiftDoc)
extension SourceLocation: Comparable {
    public static func < (lhs: SourceLocation, rhs: SourceLocation) -> Bool {
        lhs.file ?? "" < rhs.file ?? "" || (lhs.file == rhs.file && lhs.offset < rhs.offset)
    }
}
#endif

#endif
