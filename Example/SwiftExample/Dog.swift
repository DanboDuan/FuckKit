//
//  Dog.swift
//  SwiftExample
//
//  Created by bob on 2021/5/29.
//  Copyright © 2021 rangers. All rights reserved.
//

import Foundation
import SwiftFuckKit

public struct Dog {
    public func bark() -> Void {
        print("dog bark")
    }
    
    @_silgen_name("FuckKit.InjectContext.Dog")
    public static func loadService () {
        print("register dog")
        FKInjectContainer.register(Dog())
    }
}
