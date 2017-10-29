//
//  PollardRho.swift
//  PrimeBase
//
//  Created by Stephan Jancar on 28.11.16.
//  Copyright © 2016 esjot. All rights reserved.
//

import Foundation
import BigInt


public class PrimeFaktorRho : CalcCancellable, PFactor {
	public func GetFactor(n: BigUInt) -> BigUInt {
		return Rho(n: n)
	}
	
	
	override public init() {}
	
    var verbose = false
	
	//Maximalzahl an Iteration
	private var rhomax : UInt64 = 60000
	
	//Die ersten Primzahlen
	private var pfirst : [UInt64] = [2,3,5,7,11,13,17,19,23,29]
	
	private func NumOfDigits(x : BigUInt) -> UInt64 {
		var test = x
		var count : UInt64 = 0
		while test > 0 {
			count = count + 1
			test = test / 2
		}
		return count
	}
	
	public func Rho(n: BigUInt, iterations: UInt64 = 0, c: UInt64 = 1)-> BigUInt {
		
		//Test gegen die ersten Primzahlen
		for p in pfirst {
			if n % BigUInt(p) == 0 { return BigUInt(p) }
		}
		
		//Initialisieren der Rho-Schleife
		var rhox : BigUInt = 2
		var rhoy : BigUInt = 2
		var d  : BigUInt = 1
		
		let m = 4 * NumOfDigits(x: n) //Jede m-te Iteration wird der gcd.getestet.
		let n0 = n
		var c0 = BigUInt(c)
		let maxi = iterations > 0 ? iterations : rhomax
		
		//Rho-Schleife
		var rhoiter : UInt64 = 0
		while rhoiter < maxi {
			if IsCancelled() { return 0 }
			rhoiter = rhoiter + 1
			rhox = (rhox * rhox + c0) % n0
			rhoy = (rhoy * rhoy + c0) % n0
			rhoy = (rhoy * rhoy + c0) % n0
			
			if rhox > rhoy {
				d = (d * (rhox-rhoy)) % n0
			} else {
				d = (d * (rhoy-rhox)) % n0
			}
			
			if d == 0 {
				//Neuer Versuch mit anderem c-Wert
				c0 = c0 + 1; rhox = 2; 	rhoy = 2; d = 1
				continue
			}
			
			//Groessten gemeinsamen Teiler testen
			if rhoiter % m == 0 {
				let g = d.greatestCommonDivisor(with: n0)
				if verbose { print(rhoiter,g) }
				if g > 1 {
					if g != n0 {
						return g
					}
					
				}
			}
		}
		return 0 //Nothing found
	}
}


