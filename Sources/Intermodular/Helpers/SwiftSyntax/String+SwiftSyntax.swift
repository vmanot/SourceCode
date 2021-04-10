//
// Copyright (c) Vatsal Manot
//

#if canImport(SwiftSyntax)

import FoundationX
import Swallow
import Swift
import SwiftSyntax

extension String {
    public subscript(_ range: PartialRangeUpTo<SourceLocation>) -> Substring {
        self[startIndex..<String.Index(utf8Offset: range.upperBound.offset, in: self)]
    }
    
    public subscript(_ range: Range<AbsolutePosition>) -> Substring {
        self[String.Index(utf8Offset: range.lowerBound.utf8Offset, in: self)..<String.Index(utf8Offset: range.upperBound.utf8Offset, in: self)]
    }
    
    public subscript(_ range: SourceRange) -> Substring {
        self[String.Index(utf8Offset: range.start.offset, in: self)..<String.Index(utf8Offset: range.end.offset, in: self)]
    }
}

#endif
