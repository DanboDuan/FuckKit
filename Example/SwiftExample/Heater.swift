//
//  Heater.swift
//  SwiftExample
//
//  Created by bob on 2021/5/29.
//  Copyright © 2021 rangers. All rights reserved.
//

import Foundation
import SwiftFuckKit

public protocol Heater {
    func heat() -> Void
}

public struct ElectricHeater: Heater {
    public func heat() -> Void {
        print("Electric Heater")
    }
    
    @_silgen_name("FuckKit.InjectContext.Heater")
    public static func loadService () {
        print("register Heater")
        FKInjectContainer.register(Heater.self, ElectricHeater())
    }
}
