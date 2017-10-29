//
//  FactorStrategy.swift
//  PFactors
//
//  Created by Stephan Jancar on 18.10.17.
//

import Foundation
import BigInt

public class PrimeFactorStrategy {
	
	var verbose = true
	private let first : [UInt64] = [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,5359,61,71,73,79,83,89,97]
	private var rho : PrimeFaktorRho!
	private var shanks : PrimeFactorShanks!
	private var lehman : PrimeFactorLehman!
	
	public init() {
		self.rho = PrimeFaktorRho()
		self.shanks = PrimeFactorShanks()
		self.lehman = PrimeFactorLehman()
	}
	
	private func QuickTrial(ninput: BigUInt) -> (rest : BigUInt, factors : [BigUInt]) {
		if verbose { print ("QuickTrial") }
		var factors : [BigUInt] = []
		var nn = ninput
		for p in first {
			let bigp = BigUInt(p)
			if bigp * bigp > nn { break }
			while nn % bigp == 0 {
				nn = nn / bigp
				factors.append(bigp)
				if verbose { print("Factor:",bigp) }
			}
		}
		return (rest: nn, factors: factors)
	}
	
	public func Factorize(ninput: BigUInt) -> [BigUInt] {
		
		//1. Probedivision fuer sehr kleine Faktoren
		var (nn,factors) = QuickTrial(ninput: ninput)
		if nn == 1 { return factors }
		
		//2. Pollards-Rho Methode fuer kleine Zahlen zur Abspaltung von Faktoren bis zur vierten Wurzel
		let rhoupto = ninput.squareRoot().squareRoot()
		while nn > rhoupto { //Heuristik
			if verbose { print ("Rho") }
			//Rest schon prim, dann fertig
			if nn.isPrime() {
				factors.append(nn)
				if verbose { print("Factor:",nn) }
				return factors
			}
			
			//Suche mit Pollards-Methode
			let factor = rho.GetFactor(n: nn)
			
			//Nichts gefunden, dann weiter mit der nächsten Methode
			if factor == 0 { break }
			
			//Ist der gefunden Faktor prim
			if !factor.isPrime() {
				//Der gefundene Faktor war nicht prim, dann zerlegen
				let subfactors = self.Factorize(ninput: factor)
				for s in subfactors {
					factors.append(s);
					if verbose { print("Factor:",s) }
					nn = nn / s }
			} else {
				//Primfaktor abspalten
				factors.append(factor)
				if verbose { print("Factor:",factor) }
				nn = nn / factor
			}
		}
		
		//Wechsle zu Shanks
		while nn > 1 {
			if verbose { print("Shanks") }
			//Rest schon prim, dann fertig
			if nn.isPrime() {
				factors.append(nn)
				if verbose { print("Factor:",nn) }
				return factors
			}
			
			//Shanks anwenden
			let factor = shanks.GetFactor(n: nn)
			if factor == 0 { break }
			
			//Ist der gefunden Faktor prim
			if !factor.isPrime() {
				//Der gefundene Faktor war nicht prim, dann zerlegen (unwahrscheinlich)
				let subfactors = self.Factorize(ninput: factor)
				for s in subfactors {
					factors.append(s);
					if verbose { print("Factor:",s) }
					nn = nn / s }
			} else {
				//Primfaktor abspalten
				factors.append(factor)
				if verbose { print("Factor:",factor) }
				nn = nn / factor
			}
		}
		
		//3. Letzte Retturn Fermattest
		while nn > 1 {
						if verbose { print("Fermat") }
			if nn.isPrime() {
				factors.append(nn)
				if verbose { print("Factor:",nn) }
				return factors
			}
			
			let factor = lehman.GetFactor(n: nn)
			if factor.isPrime() {
				factors.append(factor)
			}
			else {
				let subfactors = Factorize(ninput: factor)
				for s in subfactors {
					factors.append(s)
					if verbose { print("Factor:",s) }
				}
			}
			nn = nn / factor
		}
		return factors
	}
	
	public func Factorize(s: String) -> String {
		var ans = ""
		guard let n = BigUInt(s) else { return "" }
		let factors = Factorize(ninput: n)
		var start = true
		for f in factors {
			if !start { ans = ans + "*" }
			ans.append(String(f))
			start = false
		}
		return ans
	}
}

