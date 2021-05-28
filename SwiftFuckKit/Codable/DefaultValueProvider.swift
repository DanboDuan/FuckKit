//
//  DefaultValueProvider.swift
//  SwiftFuckKit
//
//  Created by bob on 2021/5/28.
//

import Foundation

public protocol DefaultValueProvider {
    associatedtype Value: Equatable & Codable
    static var `default`: Value { get }
}

public protocol DefaultValue {
    init()
}

public enum EmptyValue<A>: DefaultValueProvider where A: Codable, A: Equatable, A: DefaultValue {
    public static var `default`: A { A() }
}

extension Int64: DefaultValueProvider {
    public static let `default` = Int64(-1)
}

extension Bool : DefaultValueProvider {
    public static let `default` = Self.init()
}

public enum Empty<A>: DefaultValueProvider where A: Codable, A: Equatable, A: RangeReplaceableCollection {
    public static var `default`: A { A() }
}

public enum EmptyDictionary<K, V>: DefaultValueProvider where K: Hashable & Codable, V: Equatable & Codable {
    public static var `default`: [K: V] { Dictionary() }
}

extension Double: DefaultValueProvider {
    public static let `default`: Double = Self.init()
}
