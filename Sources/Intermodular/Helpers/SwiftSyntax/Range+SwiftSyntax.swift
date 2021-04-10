//
// Copyright (c) Vatsal Manot
//

#if canImport(SwiftSyntax)

import FoundationX
import Swallow
import Swift
import SwiftSyntax

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
