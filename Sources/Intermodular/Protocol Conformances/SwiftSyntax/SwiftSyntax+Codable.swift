//
// Copyright (c) Vatsal Manot
//

#if canImport(SwiftSyntax) 

import Swift
import SwiftSyntax

extension AbsolutePosition: Codable {
    public func encode(to encoder: Encoder) throws {
        try encoder.encode(single: utf8Offset)
    }
    
    public init(from decoder: Decoder) throws {
        self.init(utf8Offset: try decoder.decode(single: Int.self))
    }
}

#endif
