//
//  OKSwiftLog.swift
//  SwiftOneKit
//
//  Created by bob on 2021/1/15.
//

import Foundation
@_implementationOnly import FuckKit

public final class FKSwiftLog {
    public static func verbose(_ tag: String,
                               _ log: String,
                               file:String = #file,
                               line:Int = #line) {
        if let service = FKServiceCenter.sharedInstance().service(for: FKLogService.self) as? FKLogService {
            let fileName = (file as NSString).lastPathComponent
            service.verbose("[\(fileName):\(line)][\(tag)]" + log)
        }
    }
    
    public static func debug(_ tag: String,
                             _ log: String,
                             file:String = #file,
                             line:Int = #line) {
        if let service = FKServiceCenter.sharedInstance().service(for: FKLogService.self) as? FKLogService {
            let fileName = (file as NSString).lastPathComponent
            service.debug("[\(fileName):\(line)][\(tag)]" + log)
        }
    }
    
    public static func info(_ tag: String,
                            _ log: String,
                            file:String = #file,
                            line:Int = #line) {
        if let service = FKServiceCenter.sharedInstance().service(for: FKLogService.self) as? FKLogService {
            let fileName = (file as NSString).lastPathComponent
            service.info("[\(fileName):\(line)][\(tag)]" + log)
        }
    }
    
    public static func warn(_ tag: String,
                            _ log: String,
                            file:String = #file,
                            line:Int = #line) {
        if let service = FKServiceCenter.sharedInstance().service(for: FKLogService.self) as? FKLogService {
            let fileName = (file as NSString).lastPathComponent
            service.warn("[\(fileName):\(line)][\(tag)]" + log)
        }
    }
    
    public static func error(__ tag: String,
                             _ log: String,
                             file:String = #file,
                             line:Int = #line) {
        if let service = FKServiceCenter.sharedInstance().service(for: FKLogService.self) as? FKLogService {
            let fileName = (file as NSString).lastPathComponent
            service.error("[\(fileName):\(line)][\(tag)]" + log)
        }
    }
}
