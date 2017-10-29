//
//  UInt128Extension.swift
//  PrimeBase
//
//  Created by Stephan Jancar on 29.11.16.
//  Copyright © 2016 esjot. All rights reserved.
//

import Foundation

extension UInt128 {
    
    //Integer Squareroot
    func squareRoot() -> UInt128 {
        if self == 0 { return 0 }
        if self == 1 { return 1 }
        var xk = self
        repeat {
            let xk1 = (xk + self / xk) >> 1 // /2
            if xk1 >= xk { return xk }
            xk = xk1
        } while true
    }
}
