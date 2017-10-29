//
//  PUtil.swift
//  PFactors
//
//  Created by Stephan Jancar on 17.10.17.
//

import Foundation
import BigInt

extension BigUInt {
	func issquare() -> Bool {
		let r2 = self.squareRoot()
		if r2 * r2 == self { return true }
		return false
	}
	
	// Cubic Root
	public func iroot3()->BigUInt {
		if self == 0 { return 0 }
		if self < 8 { return 1 }
		
		var x0 = self
		var x1 = self
		repeat {
			x1 = self / x0 / x0
			x1 = x1 + 2 * x0
			x1 = x1 / 3
			
			
			if (x0 == x1) || (x0 == x1+1) || (x1 == x0 + 1) {
				if x1 * x1 * x1 > self {
					return x1 - 1
				}
				return x1
			}
			x0 = x1
		} while true
	}
}


//Quadratwurzel und kubische Wurzel mittels Floating Point Arithmetik
extension UInt64 {
	func squareRoot()->UInt64 {
		var r2 = UInt64(sqrt(Double(self)+0.5))
		while (r2+1) * (r2+1) <= self {
			r2 = r2 + 1
		}
		return r2
	}
	
	func issquare() -> Bool {
		let r2 = self.squareRoot()
		if r2 * r2 == self { return true }
		return false
	}
	
	// Cubic Root
	func iroot3()->UInt64 {
		var r3 = UInt64(pow(Double(self)+0.5, 1.0 / 3.0))
		while (r3+1) * (r3+1) * (r3+1) <= self {
			r3 = r3 + 1
		}
		return r3
	}
	
	func NumBits() -> UInt64 {
		var v = self
		var c : UInt64 = 0
		while v != 0 {
			v = v & (v - 1)  //Brian Kernighan's method
			c = c + 1
		}
		return c
	}
	
	
	public func greatestCommonDivisor(with b: UInt64) -> UInt64 {
		var x = self
		var y = b
		while y > 0 {
			let exc = x
			x = y
			y = exc % y
		}
		return x
	}
}

