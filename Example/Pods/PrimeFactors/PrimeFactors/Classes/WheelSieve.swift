//
//  WheelSieve.swift
//  PFactors
//
//  Created by Stephan Jancar on 18.10.17.
//

import Foundation

class WheelSieve {
	
	private (set) var limit : UInt64 = 0
	private var limit2 : UInt64 = 0
	private var sieve : WheelArray!
	
	init(limit : UInt64) {
		self.limit = limit
		self.limit2 = limit.squareRoot()
		sieve = WheelArray(count: limit+1)
		InitPrimorial()
		InitWheel()
		InitSieve()
		Sieve()
	}
	
	private let tinyprimes : [UInt64] = [2,3,5,7,11,13,17,19,23,29,31,37,41,43]
	private var mk : UInt64 = 1		//Primorial up to limit2
	private var wk : [UInt16] = []
	private var lastp : UInt64 = 2 //Last prime number used in wheel
	
	private func InitPrimorial() {
		mk = 1
		for k in 0..<tinyprimes.count {
			if mk * tinyprimes[k] > limit2 {
				break
			}
			mk = mk * tinyprimes[k]
			lastp = tinyprimes[k]
		}
	}
	
	private func InitWheel() {
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
	
	private func InitSieve() {
		
		var d : UInt64 = 1
		while d <= limit {
			
			sieve[Int(d)] = true
			let dif = UInt64(wk[Int(d % mk)])
			d = d + dif
		}
	}
	
	private func Sieve() {
		
		var p : UInt64 = 1 + UInt64(wk[Int(1 % mk)])
		while p <= limit2 {
			var q = p
			var x = p * q
			while x <= limit {
				while x <= limit {
					//Remove powers of p
					sieve[Int(x)] = false
					x = p * x
				}
				q = q + UInt64(wk[Int(q % mk)])
				while sieve[Int(q)] == false {  q = q + UInt64(wk[Int(q % mk)]) }
				x = p * q
			}
			
			p = p + UInt64(wk[Int(p % mk)])
			while sieve[Int(p)] == false {
				p = p + UInt64(wk[Int(p % mk)])
			}
		}
		
		for k in 0..<tinyprimes.count {
			let p = tinyprimes[k]
			sieve[Int(p)] = true
		}
		sieve[0] = false
		sieve[1] = false
	}
	
	func IsPrime(n: UInt64) -> Bool {
		
		if n <= lastp {
			return tinyprimes.contains(n)
		}
		
		return sieve[Int(n)]
	}
}

