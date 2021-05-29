//
//  Test.swift
//  RSKExample
//
//  Created by bob on 2021/5/29.
//  Copyright © 2021 rangers. All rights reserved.
//

import Foundation
import FuckKit
import SwiftFuckKit

@objc(FKLogService)
class LogService: NSObject, FKLogService {
    
    private static var shared: LogService = {
           let log = LogService()
           return log
    }()
    
    func verbose(_ log: String) {
        print(log)
    }
    
    func debug(_ log: String) {
        print(log)
    }
    
    func info(_ log: String) {
        print(log)
    }
    
    func warn(_ log: String) {
        print(log)
    }
    
    func error(_ log: String) {
        print(log)
    }
    
    static func sharedInstance() -> Self {
        return shared as! Self
    }
    
    @_silgen_name("FuckKit.InjectContext.LogService")
    public static func loadService () {
        print("bind logger")
        FKInjectContainer.bind(FKLogService.self, to: LogService.self)
    }
}

