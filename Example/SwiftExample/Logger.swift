//
//  Logger.swift
//  SwiftExample
//
//  Created by bob on 2021/5/28.
//  Copyright © 2021 rangers. All rights reserved.
//

import Foundation
import FuckKit

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
        print("FuckKit AppLoadService")
        FKServiceCenter.sharedInstance().bindClass(LogService.self, for: FKLogService.self)
    }
}

