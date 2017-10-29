//
//  Shanks.swift
//  PrimeFactors
//
//  Created by Stephan Jancar on 17.10.17.
//

import Foundation
import BigInt

public class PrimeFactorShanks : CalcCancellable, PFactor {
	public func GetFactor(n: BigUInt) -> BigUInt {
		return Shanks(n:n)
	}
	
	
	
	private let firstp : [UInt64] = [3,5,7,11,13,17,19,23,29]
	private var smallprod : [UInt64] = [1]
	
	private func SmallProducts() {
		for p in firstp {
			for q in smallprod {
				smallprod.append(p * q)
			}
		}
		smallprod.sort()
	}
	
	override public init () {
		super.init()
		SmallProducts()
	}
	
	private func ShanksDivisor(n: BigUInt, k : BigUInt) -> BigUInt {
		let rn = BigInt(n.squareRoot())
		if rn * rn == n { return BigUInt(rn) }
		let kn  = BigInt(k * n)
		let rkn = BigInt(kn.squareRoot())
		var p0 = rkn
		var q0 = BigInt(1)
		var q1 = kn - p0 * p0
		var b0, b1, p1, q2 : BigInt
		let rkn2 = rkn << 1
		let imax = rkn2.squareRoot()
		
		for i in 0..<imax {
			if IsCancelled() { return 0 }
			b1 = (rkn + p0) / q1
			p1 = b1 * q1 - p0
			let pdif : BigInt = BigInt(p0) - BigInt(p1)
			let bpdif = BigInt(b1) * pdif
			q2 = q0 + bpdif
			if i % 2 == 1 {
				let rq = q1.squareRoot()
				if rq * rq == q1 {
					//  Wurzel gefunden
					b0 = (rkn - p0) / rq
					p0 = b0 * rq + p0
					q0 = rq
					q1 = (kn - p0*p0) / q0
					while true {
						if IsCancelled() { return 0 }
						b1 = (rkn + p0) / q1
						p1 = b1 * q1 - p0
						q2 = q0 + b1 * (p0 - p1)
						if p0 == p1 {
							let ret = n.greatestCommonDivisor(with: BigUInt(p1))
							return ret
						}
						p0 = p1; q0 = q1; q1 = q2
					}
				}
			}
			p0 = p1
			q0 = q1
			q1 = q2
		}
		return 1
	}
	
	public func Shanks(n:BigUInt)->BigUInt {
		
		if n % 2 == 0 {	return 2 }
		for p in firstp {
			if n % BigUInt(p) == 0 { return BigUInt(p) }
		}
		
		for k in smallprod {
			if (k > 1) && (n % BigUInt(k) == 0) {
				return BigUInt(k)
			}
			let  g = ShanksDivisor(n: n,k: BigUInt(k))
			if IsCancelled() { return 0 }
			if g != 1 { return g }
		}
		return 0 //Disaster
	}
}

