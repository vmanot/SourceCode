//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftSyntax

extension SourceLocation: Comparable {
    public static func < (lhs: SourceLocation, rhs: SourceLocation) -> Bool {
        lhs.file ?? "" < rhs.file ?? "" || (lhs.file == rhs.file && lhs.offset < rhs.offset)
    }
}
