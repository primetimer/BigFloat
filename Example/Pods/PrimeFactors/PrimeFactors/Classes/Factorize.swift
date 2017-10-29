//
//  Factorize.swift
//  PFactors
//
//  Created by Stephan Jancar on 18.10.17.
//

import Foundation
import BigInt

public class Factorize {
	
	private var method : PFactor
	public init(method : PFactor) {
		self.method = method
	}
	
	public func Factorize(n: BigUInt) -> [BigUInt] {
		
		var nn = n
		var factors : [BigUInt] = []
		while nn > 1 {
			if nn.isPrime() {
				factors.append(nn)
				return factors
			}
			let factor = method.GetFactor(n: nn)
			if factor.isPrime() {
				factors.append(factor)
			}
			else {
				let subfactors = Factorize(n: factor)
				for s in subfactors { factors.append(s) }
			}
			nn = nn / factor
		}
		return factors
	}
	
	public func Factorize(s: String) -> String {
		var ans = ""
		guard let n = BigUInt(s) else { return "" }
		let factors = Factorize(n: n)
		var start = true
		for f in factors {
			if !start { ans = ans + "*" }
			ans.append(String(f))
			start = false
		}
		return ans
	}
}
