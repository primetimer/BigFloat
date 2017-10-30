//
//  BigFloatString.swift
//  BigFloat
//
//  Created by Stephan Jancar on 30.10.17.
//

import Foundation
import BigInt

extension BigFloat : CustomStringConvertible {
	public var description: String {
		//let ans = self.toString(base: 10, fix: 0)
		let ans = self.ExponentialString(base: 10)
		return ans
	}
}
public extension BigFloat {
	
	public func SplitIntFract()->(BigInt, BigFloat) {
		let i = BigInt(self)
		return (i, self - BigFloat(i))
	}
	
	public func toString(base:Int=10, fix:Int=0)->String {
		if significand == 0 {
			return "0."
		}
		if significand.sign == .minus {
			let str = (-self).toString(base: base, fix: fix)
			return "-" + str
		}
		
		let dfactor = log(2) / log(Double(base))
		var ndigits = fix != 0 ? fix
			: Swift.max(Int(Double(self.precision) * dfactor)+2, 17)
		var (int, fract) = self.SplitIntFract()
		
		var digits : [Int] = []
		var started = false
		while ndigits > 0 {
			var r: BigInt
			fract = fract*BigFloat(base)
			(r, fract) = fract.SplitIntFract()
			if r != 0 { started = true }
			digits.append(Int(r))
			if fract.isZero() { break }
			if started { ndigits -= 1 }
		}
		var str = String(int,radix : base) + "."
		for d in digits {
			str = str + String(d)
		}
		return str
	}
	
	public func ExponentialString(base : Int, fix:Int=0 ) -> String {
		if self.significand < 0 {
			return "-" + (-self).ExponentialString(base: base, fix : fix)
		}
		if self.significand == 0 {
			return "0"
		}
		
		var ex = 0
		var temp = self
		do {
			//Multipliziere so lange bis >= 1.0
			while temp < BigFloat(1) {
				temp = temp * BigFloat(base)
				ex = ex - 1
			}
		}
		
		//Splitte Vor und nachkommateil
		var (int,fract) = temp.SplitIntFract()
		let bbase = BigInt(base)
		
		//Scuhe die letzte potenz mit 10^ex < self
		var div = BigInt(1)
		while int >= div*bbase {
			div = div * bbase
			ex = ex + 1
		}
		
		//Bestimme die Ziffern des Vorkommaanteils
		var intdigits : [Int] = []
		while int > 0 {
			let digit = int / div
			intdigits.append(Int(digit))
			int = int % div
			div = div / bbase
		}
		
		// Bestimme den Nachkommanteil
		//var fracdigits : [Int] = []
		if fract > BigFloat(0) {
			let dfactor = log(2) / log(Double(base))
			var ndigits = fix != 0 ? fix
				: Swift.max(Int(Double(self.precision) * dfactor)+2, 17)
			
			//var fracstarted = false
			while ndigits > 0 {
				var r: BigInt
				fract = fract*BigFloat(base)
				(r, fract) = fract.SplitIntFract()
				//if r != 0 { fracstarted = true }
				intdigits.append(Int(r))
				if fract.isZero() { break }
				ndigits -= 1
				//if fracstarted { ndigits -= 1 }
			}
		}
		
		//Runden
		let lastdigit = intdigits.last!
		if lastdigit >= base / 2 {
			intdigits.removeLast()
			let count = intdigits.count-1
			for i in stride(from: count, through: 0, by: -1)
			{
				intdigits[i] = intdigits[i] + 1
				if intdigits[i] < base { break }
				if i == 0 {
					intdigits[i] = 0
					intdigits.insert(1, at: 0)
					ex = ex + 1
				} else {
					intdigits[i] = 0
				}
			}
		}
		
		var str = ""
		//let fracstr = ""
		var numdigits = 0
		do {
			var started = false
			for d in intdigits {
				if !started {
					str = String(d) + "."
					started = true
				} else {
					str = str + String(d)
					numdigits = numdigits + 1
					if numdigits >= fix && fix > 0 { break }
				}
			}
		}
		/*
		do {
			for d in fracdigits {
				if numdigits >= fix && fix > 0 { break }
				fracstr = fracstr + String(d)
			}
		}
		*/
		return str + "E" + String(ex)
	}
}




