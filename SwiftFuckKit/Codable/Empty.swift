//
//  Empty.swift
//  SwiftFuckKit
//
//  Created by bob on 2021/5/28.
//

import Foundation

/**
 e.g.
 
 public struct ResponsePayload: Codable {
     @Default<EmptyValue>
     public var xxx: EmptyDefault
     @Default<Int64>
     public var zzz: Int64
     @Default<Empty>
     public var www: String
 }
 */

public struct EmptyDefault : Codable, Equatable, DefaultValue {
    
    public init() {}
    
    public init(from decoder: Decoder) throws {}

    public func encode(to encoder: Encoder) throws {}
    
    /// always return true to ignore this value
    public static func == (left: Self, right: Self) -> Bool {
        return true
    }
}
