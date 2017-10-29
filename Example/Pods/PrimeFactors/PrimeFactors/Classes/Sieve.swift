//
//  Sieve.swift
//  PFactors
//
//  Created by Stephan Jancar on 17.10.17.
//

import Foundation

//
//  AtkinSieve.swift
//  PrimeBase
//
//  Created by Stephan Jancar on 03.12.16.
//  Copyright © 2016 esjot. All rights reserved.
//

import Foundation

//Singleton mit einem Sieb
public class PSieve : PrimeSieve {
	public static var limit : UInt64 = 1000000
	public static let shared = PSieve()
	private init() {
		super.init(limit: PSieve.limit)
	}
}

public class PrimeSieve {
	private (set) var limit : UInt64 = 0
	private var limit2 : UInt64 = 0
	private var sieve : BitArray!
	
	private var lastprime : UInt64 = 0
	public func LastPrime() -> UInt64 {
		if lastprime == 0 {
			lastprime = limit-1
			while !IsPrime(n: lastprime) {
				lastprime = lastprime - 1
			}
		}
		return lastprime
	}

	public init(limit : UInt64) {
		self.limit = limit
		self.limit2 = limit.squareRoot()
		sieve = BitArray(count: limit/2+1, initval: true)
		SieveInit()
	}

	private func SieveInit() {
		sieve[0] = false
		for p in stride(from: 3, through: limit2, by: 2) {
			if sieve[Int(p)/2] {
				var q = p*p
				while q <= limit {
					sieve[Int(q)/2] = false
					q = q + p + p
				}
			}
		}
	}
	
	
	public func IsPrime(n: UInt64) -> Bool {
		if n % 2 == 0 {
			return n==2
		}		
		return sieve[Int(n)/2]
	}
	
}


