//
//  MillerRabin.swift
//  PFactors
//
//  Created by Stephan Jancar on 18.10.17.
//

import Foundation

class MillerRabin {
	
	public static func TestMRT(p : UInt64) -> Bool {
		if p<2 { return false }
		if p==2 { return true }
		if p==3 { return true }
		if p % 2 == 0 { return false }
		if  !mrt( n: p, a: 2) { return false }
		if  !mrt( n: p, a: 3) { return false }
		if (p < 1373653)    { return true }
		if  !mrt( n: p, a: 5) { return false }
		if  !mrt( n: p, a: 7) { return false }
		if  !mrt( n: p, a: 11) { return false }
		return true; //Ausreichend für p <10^14
	}
	
	static func mrt (n : UInt64, a : UInt64) -> Bool {
		var n1 : UInt64 = n - 1
		while (n1 % 2 == 0) {
			n1 = n1 >> 1
		}
		var temp : UInt64 = n1
		var mod : UInt64 = a.ModPow(exponent: temp, mod: n)
		while (temp != n - 1 && mod != 1 && mod != n - 1) {
			mod = mod.ModMul(by: mod, mod: n)
			temp = temp << 1
		}
		if (mod != n - 1 && temp % 2 == 0) {
			return false;
		}
		return true
	}
}

extension UInt64 {
	
	public func isPrime() -> Bool {
		return MillerRabin.TestMRT(p: self)
	}
	public func ModMul(by: UInt64, mod : UInt64) -> UInt64 {
		var b : UInt64 = by
		var x : UInt64 = 0
		var y : UInt64 = self % mod
		while (b > 0) {
			if (b % 2 == 1) {
				x = (x + y) % mod
			}
			y = (y * 2) % mod
			b = b >> 1
		}
		return x % mod;
	}
	
	public func ModPow(exponent : UInt64, mod : UInt64) -> UInt64 {
		var ex : UInt64 = exponent
		var x : UInt64 = 1
		var y : UInt64 = self
		while (ex > 0) {
			if (ex % 2 == 1) {
				x = x.ModMul(by: y, mod: mod)
			}
			y = y.ModMul(by: y,mod: mod)
			ex = ex >> 1
		}
		return x % mod
	}
}

