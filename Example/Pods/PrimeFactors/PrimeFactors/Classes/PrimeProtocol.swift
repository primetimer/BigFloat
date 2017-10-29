//
//  PrimeProtocol.swift
//  Nimble
//
//  Created by Stephan Jancar on 15.10.17.
//

import Foundation
import BigInt

public protocol PFactor {
	func GetFactor(n: BigUInt) -> BigUInt
}

public protocol PrimeEnumerator {
	func IsPrime(n: BigUInt) -> Bool
	func NextPrime(n: BigUInt) -> BigUInt
	func PrevPrime(n: BigUInt) -> BigUInt
}

public protocol CalcCancelProt {
	func IsCancelled() -> Bool
}

open class CalcCancellable : CalcCancelProt  {
	public var canceldelegate : CalcCancelProt? = nil
	public func IsCancelled() -> Bool {
		if canceldelegate == nil { return false }
		return canceldelegate!.IsCancelled()
	}
	
	public init() {
		
	}
}



 

