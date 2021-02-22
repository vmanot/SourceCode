//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftSyntax

extension String {
    public subscript(_ range: SourceRange) -> Substring {
        self[String.Index(utf8Offset: range.start.offset, in: self)..<String.Index(utf8Offset: range.end.offset, in: self)]
    }
}
