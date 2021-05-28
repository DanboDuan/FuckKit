//
//  Inject.swift
//  SwiftFuckKit
//
//  Created by bob on 2021/5/28.
//

import Foundation
import FuckKit

/*
 e.g.
 
 @_sil_name("FuckKit.InjectContext.AccountService")
 static public func bindService() {
    InjectContext.bind(AccountServiceProtocol.self, AccountService.self) // 绑定服务
 }
 
 @Inject<AccountServiceProtocol> var account
 */

/// Convert Swift Protocol to OC Runtime `Protocol` type. These are different.
/// - Parameter type: Swift Protocol type, like `UITableViewDelegate.self`
/// - Returns: The OC Runtime `Protocol` type
private func NSProtocolFromSwiftProtocol(_ type: NSObjectProtocol.Type) -> Protocol? {
    var protocolString = String(reflecting: type)
    // For protocol comes from Objc, compiler will treat as Cxx symbol, like "__C.Protocol"
    if protocolString.hasPrefix("__C.") {
        protocolString = String(protocolString.dropFirst("__C.".count))
    }
    
    guard let ocProtocol = NSProtocolFromString(protocolString) else {
        return nil
    }
    
    return ocProtocol
}

/// Protocol used for service impl to provide shared instance.
@objc public protocol ServiceSharedScope : FKService {}

@propertyWrapper
public struct Inject<T> where T : NSObjectProtocol {
    public init() {
        let _ = InjectContext.setup
    }
    
    public var wrappedValue: T? {
        return InjectContext.get(T.self)
    }
}

public struct InjectContext {
    
    /// Setup once with Gaia
    internal static let setup: Void = {
        SwiftSectionFunction.start(key: "InjectContext")
    }()
    
    public static func bind<T: NSObjectProtocol>(_ type: T.Type, to cls: AnyClass) {
        guard let ocProtocol = NSProtocolFromSwiftProtocol(type) else {
            return
        }
        FKServiceCenter.sharedInstance().bindClass(cls, for: ocProtocol)
    }
    
    public static func get<T: NSObjectProtocol>(_ type: T.Type) -> T? {
        guard let ocProtocol = NSProtocolFromSwiftProtocol(type) else {
            return nil
        }
        
        if let service = FKServiceCenter.sharedInstance().service(for: ocProtocol)as? T {
            return service
        }
        
        return nil
    }
}


