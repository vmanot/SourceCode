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

extension Range where Bound == AbsolutePosition {
    public init?(_ range: Range<String.Index>, in string: String) {
        guard let utf8Range = NSRange(utf8Range: range, in: string) else {
            return nil
        }
        
        self.init(
            lowerBound: .init(utf8Offset: utf8Range.lowerBound),
            upperBound: .init(utf8Offset: utf8Range.upperBound)
        )
    }
}

extension Range where Bound == String.Index {
    public init?(_ range: Range<AbsolutePosition>, in string: String) {
        self.init(
            NSRange(
                lowerBound: range.lowerBound.utf8Offset,
                upperBound: range.upperBound.utf8Offset
            ),
            in: string
        )
    }
}

#endif
