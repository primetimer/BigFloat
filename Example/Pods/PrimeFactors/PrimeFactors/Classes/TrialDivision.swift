//
//  TrialDivision.swift
//  PFactors
//
//  Created by Stephan Jancar on 18.10.17.
//

import Foundation
import BigInt

public class TrialDivision : CalcCancellable, PFactor {
	public func GetFactor(n: BigUInt) -> BigUInt {
		let factor = BigTrialDivision(n: n)
		return factor
	}

	private let pfirst : [UInt64] = [2,3,5,7,11,13,17,19,23,29,31,37,41,43]
	private var mk : UInt64 = 1		//Primorial up to limit2
	private var wk : [UInt16] = []
	private var lastp : UInt64 = 2 //Last prime number used in wheel
	
	
	private var sieve : PrimeSieve!
	override public init() {
		super.init()
		sieve = PSieve.shared
		InitWheel()
	}
	public init(sieve : PrimeSieve) {
		super.init()
		self.sieve = sieve
		InitWheel()
	}
	
	public func TrialDivision(n: UInt64, upto: UInt64 = 0) -> UInt64 {
		let limit = (upto > 0) ? upto : n.squareRoot()
		let limitsieve = sieve.limit
		if n < 2 { return 1 }
		for p in pfirst {
			if n % p == 0 { return p }
		}
		var q = pfirst[pfirst.count-1]
		
		while !IsCancelled() {
			let offset = Int(wk[Int(q % mk)])
			q = q + UInt64(offset)
			if q > limit { break }
			if q < limitsieve {
				if sieve.IsPrime(n: q) {
					if n % q == 0 { return q }
				}
			} else {
				if n % q == 0 { return q }
			}
		}
		return 0
	}
	
	public func BigTrialDivision(n: BigUInt, upto: BigUInt = 0, startwith : BigUInt = 0) -> BigUInt {
		
		if n < BigUInt(UINT64_MAX) {
			let divisor64 = TrialDivision(n: UInt64(n), upto: UInt64(upto))
			return BigUInt(divisor64)
		}
		
		let limit = (upto > 0) ? upto : n.squareRoot()
		let limitsieve = sieve.limit
		if n < 2 { return 1 }
		for p in pfirst {
			if n % BigUInt(p) == 0 { return BigUInt(p) }
		}
		var q = UInt64(startwith)
		if q == 0 { q = pfirst[pfirst.count-1] }
		while !IsCancelled() {
			let offset = Int(wk[Int(q % mk)])
			q = q + UInt64(offset)
			if q > limit { break }
			if q < limitsieve {
				if sieve.IsPrime(n: q) {
					if n % BigUInt(q) == 0 { return BigUInt(q) }
				}
			} else {
				if n % BigUInt(q) == 0 { return BigUInt(q) }
			}
		}
		return 0
	}
	
	private func InitPrimorial() {
		mk = 1
		let limit2 = sieve.limit.squareRoot()
		for k in 0..<pfirst.count {
			if mk * pfirst[k] > limit2 {
				break
			}
			mk = mk * pfirst[k]
			lastp = pfirst[k]
		}
	}
	
	private func InitWheel() {
		InitPrimorial()
		wk = [UInt16] (repeating: 0, count: Int(mk))
		wk[Int(mk)-1] = 2
		var y = Int(mk-1)
		for x in stride(from: Int(mk)-2, to: 0, by: -1) {
			if mk.greatestCommonDivisor(with: UInt64(x)) == 1 {
				wk[Int(x)] = UInt16(y - x)
				y = x
			}
		}
	}
}

