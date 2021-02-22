//
// Copyright (c) Vatsal Manot
//

import SwiftSyntax

extension SourceLocation: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(file)
        hasher.combine(offset)
    }
    
    public static func == (lhs: SourceLocation, rhs: SourceLocation) -> Bool {
        lhs.file == rhs.file && lhs.offset == rhs.offset
    }
}

extension SourceRange: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(start)
        hasher.combine(end)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.start == rhs.start && lhs.end == rhs.end
    }
}