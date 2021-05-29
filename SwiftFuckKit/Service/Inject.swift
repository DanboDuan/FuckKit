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
private func FKNSProtocolFromSwiftProtocol(_ type: Any.Type) -> Protocol? {
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
public struct Inject<T> {
    public var wrappedValue: T? {
        return FKInjectContainer.resolve()
    }
    
    public init() {
        let _ = FKInjectContainer.setup
    }
}

public final class FKInjectContainer {
    
    private var dependencies: [String: AnyObject] = [:]
    
    private func register<T>(_ dependency: T) {
        let key = String(describing: T.self)
        dependencies[key] = dependency as AnyObject
    }
    
    private func register<T>(_ type: T.Type,_ dependency: T) {
        let key = String(describing: T.self)
        dependencies[key] = dependency as AnyObject
    }

    private func resolve<T>() -> T? {
        let key = String(describing:T.self)
        let dependency = dependencies[key] as? T

        precondition(dependency != nil, "No service found for \(key)! must bind a service before resolve.")

        return dependency
    }
    
    /// Setup once
    internal static let setup:Void = {
        FKServiceCenter.sharedInstance()
    }()
    
    private init() {}
    
    private static let sharedValue: FKInjectContainer = {
       let context = FKInjectContainer()
       return context
    }()
    
    public static func register<T>(_ dependency: T) {
        FKInjectContainer.sharedValue.register(dependency)
    }
    
    public static func register<T>(_ type: T.Type,_ dependency: T) {
        FKInjectContainer.sharedValue.register(type, dependency)
    }
    
    public static func bind<T>(_ type: T.Type, to cls: AnyClass) {
        if let ocProtocol = FKNSProtocolFromSwiftProtocol(type) {
            FKServiceCenter.sharedInstance().bindClass(cls, for: ocProtocol)
            return
        }
        assertionFailure("can not bind swift protocol or type use bind api, please use register api")
    }
    
    public static func resolve<T>() -> T? {
        if let ocProtocol = FKNSProtocolFromSwiftProtocol(T.self),
           let service = FKServiceCenter.sharedInstance().service(for: ocProtocol)as? T {
            return service
        }
        
        return FKInjectContainer.sharedValue.resolve()
    }
}


