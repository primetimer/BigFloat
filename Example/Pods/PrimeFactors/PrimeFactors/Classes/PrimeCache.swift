//
//  PrimeCache.swift
//  PFactors
//
//  Created by Stephan Jancar on 20.10.17.
//

import Foundation
import BigInt

public class PrimeCache {
		
	private var pcache = NSCache<NSString, NSNumber>()
	static public var shared = PrimeCache()
	private init() {
		
	}
	
	
	
	public func IsPrime(p: BigUInt) -> Bool {
		let nsstr = NSString(string: String(p.hashValue))
		let cachep = pcache.object(forKey: nsstr)
		if cachep != nil {
			let isprime = cachep!.boolValue
			return isprime
		}
		
		let isprime = p.isPrime()
		let nsnum = NSNumber(value: isprime)
		pcache.setObject(nsnum, forKey: nsstr)
		return isprime
	}
}

public class PrimeCalculator : CalcCancellable, PrimeEnumerator {
	
	internal let pfirst : [UInt64] = [2,3,5,7,11,13,17,19,23,29,31,37,41,43]
	internal var mk : UInt64 = 1		//Primorial up to limit2
	internal var wk : [UInt16] = []
	internal var sieve : PrimeSieve!
	
	public override init() {
		super.init()
		sieve = PSieve.shared
		InitWheel()
	}
	public init(sieve : PrimeSieve) {
		super.init()
		self.sieve = sieve
		InitWheel()
	}
	
	private func InitPrimorial() {
		mk = 1
		let limit2 = sieve.limit.squareRoot()
		for k in 0..<pfirst.count {
			if mk * pfirst[k] > limit2 {
				break
			}
			mk = mk * pfirst[k]
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
	
	public func IsPrime(n: BigUInt) -> Bool {
		if n < BigUInt(sieve.limit) {
			return sieve.IsPrime(n: UInt64(n))
		}
		return PrimeCache.shared.IsPrime(p: n)
	}
	
	public func NextPrime(n: BigUInt) -> BigUInt {
		if n < BigUInt(sieve.LastPrime()) {
			var n64 = UInt64(n) + 1
			if n64 <= 2 { return 2 }
			if n64 % 2 == 0 { n64 = n64 + 1 }
			while !sieve.IsPrime(n: n64) {
				n64 = n64 + 2
			}
			return BigUInt(n64)
		}
		var p = n
		var spoke : Int = Int(p % BigUInt(self.mk))
		var dif : Int = 0
		while wk[spoke % Int(mk)] == 0 {
			spoke = spoke + 1
			dif = dif + 1
		}
		if dif == 0 {
			dif = Int(wk[spoke % Int(mk)])
			spoke = spoke + dif
		}
		p = p + BigUInt(dif)
		while true {			
			if PrimeCache.shared.IsPrime(p: p) {
				return p
			}
			let offset = Int(wk[spoke % Int(mk)])
			p = p + BigUInt(offset)
			spoke = spoke + offset
		}
	}
	
	public func PrevPrime(n: BigUInt) -> BigUInt {
		if n < BigUInt(sieve.limit) {
			var n64 = UInt64(n)
			if n64 <= 2 { return 0 }
			if n64 == 3 { return 2 }
			n64 = n64 - 1 - (n64 % 2)
			while !sieve.IsPrime(n: n64) {
				n64 = n64 - 2
			}
				return BigUInt(n64)
		}
		var p = n
		var spoke : Int = Int(p % BigUInt(self.mk))
		var dif : Int = 1
		while true {
			//Positioniere auf einer der potentiellen Speichen des Rades
			while spoke - dif < 0 { spoke = spoke + Int(mk) }
			while wk[(spoke-dif) % Int(mk)] == 0 {
				dif = dif + 1
				while spoke - dif < 0 { spoke = spoke + Int(mk) }
			}
			p = n - BigUInt(dif)
			if PrimeCache.shared.IsPrime(p: p) {
				return p
			}
			dif = dif + 1
		}
	}
}

public class ExtendedPrimeCalculator : PrimeCalculator {

	//This routine sounds complexer than neccessary
	//It is optimized with a wheel, so the amount of testes Numbers is reduced

	public func NextTwin(n: BigUInt) -> BigUInt {
		
		var p = NextPrime(n: n)
		if p < BigUInt(sieve.LastPrime()) {
			while !IsCancelled() {
				let twin = NextPrime(n: p)
				if twin - p == 2 {
					return p
				}
				p = twin
			}
		}
		
		var spoke : Int = Int(p % BigUInt(self.mk))
		var dif : Int = 0
		while wk[spoke % Int(mk)] != 2 {
			spoke = spoke + 1
			dif = dif + 1
		}
		p = p + BigUInt(dif)
		while !IsCancelled() {
			if PrimeCache.shared.IsPrime(p: p) {
				let twin = p + 2
				if PrimeCache.shared.IsPrime(p: twin) {
					return p
				}
			}
			dif = 0
			repeat {
				spoke = (spoke + Int(wk[spoke])) % Int(mk)
				dif = dif + Int(wk[spoke])
			} while wk[spoke] != 2
				
			p = p + BigUInt(dif)
		}
		//Never come here
		return p
	}
	
	public func NextSoG(n: BigUInt) -> BigUInt {
		
		var p = NextPrime(n: n)
		if p < BigUInt(sieve.LastPrime()) {
			while !IsCancelled() {
				let sog = 2 * p + 1
				if sog.isPrime() {
					return p
				}
				p = NextPrime(n: p)
			}
		}
		
		var spoke : Int = Int(p % BigUInt(self.mk))
		var spoke2 : Int = Int((2*spoke+1) % Int(mk))
		var dif : Int = 0
		
		while wk[spoke] == 0 || wk[spoke2] == 0 {
			spoke = (spoke + 1) % Int(self.mk)
			spoke2 = Int(2*spoke+1) % Int(mk)
			dif = dif + 1
			
		}
		p = p + BigUInt(dif)
		while !IsCancelled() {
			if PrimeCache.shared.IsPrime(p: p) {
				let sog = 2 * p + 1
				if PrimeCache.shared.IsPrime(p: sog) {
					return p
				}
			}
			dif = 0
			
			repeat {
				spoke = (spoke + Int(wk[spoke])) % Int(mk)
				dif = dif + Int(wk[spoke])
				spoke2 = Int(2*spoke+1) % Int(mk)
			} while wk[spoke2] == 0
			p = p + BigUInt(dif)
		}
		//Never come here
		return p
	}
}


