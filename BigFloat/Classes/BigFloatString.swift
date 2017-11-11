//
//  BigFloatString.swift
//  BigFloat
//
//  Created by Stephan Jancar on 30.10.17.
//

import Foundation
import BigInt

extension Int {
	public var AsciiCode : String {
		switch self {
		case 0:	return "0"
		case 1:	return "1"
		case 2:	return "2"
		case 3:	return "3"
		case 4:	return "4"
		case 5:	return "5"
		case 6:	return "6"
		case 7:	return "7"
		case 8:	return "8"
		case 9:	return "9"
		case 10:	return "A"
		case 11:	return "B"
		case 12:	return "C"
		case 13:	return "D"
		case 14:	return "E"
		case 15:	return "F"
		default:	return "X"
		}
	}
}

extension BigFloat : CustomStringConvertible {
	public var description: String {
		let ans = self.autoString()
		return ans
	}
}

public extension BigFloat {
	public func SplitIntFract()->(BigInt, BigFloat) {
		let i = BigInt(self)
		return (i, self - BigFloat(i))
	}
	
	public func autoString(_ base : Int = 10 , fix : Int = 8) -> String {
		var maxval = 1.0
		for _ in 0...fix/2 {
			maxval = maxval * Double(base)
		}
		if self > BigFloat(maxval) {
			return expString(base, fix : fix)
		}
		if self <= BigFloat(1.0 / maxval) {
			return expString(base, fix : fix)
		}
		return asString(base,fix: fix)
		
	}
	
	public func asString(_ base : Int = 10 , fix : Int = 8) -> String {
		
		if self.significand == 0 { return "0" }
		if self.significand < 0 {
			let neg = -self
			return "-" + neg.asString(base,fix: fix)
		}
		
		let bfbase = BigFloat(base)
		var (int, fract) = SplitIntFract()
		var fracdigits : [Int] = []
		var ndigits = Darwin.abs(Int32(fix))
		var started = false
		while ndigits > 0 {
			var r:BigInt
			fract = fract * bfbase
			(r, fract) = fract.SplitIntFract()
			if r != 0 { started = true }
			let digit = Int(r)
			fracdigits.append(digit)
			if fract.significand == 0 { break }
			if started { ndigits = ndigits - 1 }
		}

		var carry = false
		if fract * BigFloat(2) >= BigFloat(1) {   // round up!
			carry = true
			var idx = fracdigits.count
			while idx > 0 {
				if fracdigits[idx - 1] < base - 1 {
					fracdigits[idx - 1] += 1
					carry = false
					break
				}
				fracdigits[idx - 1] = 0
				idx -= 1
			}
		}
		
		if carry {
			int = int + 1
		}
		
		var intdigits : [Int] = []
		if int == 0 { intdigits.append(0) }
		while int > 0 {
			let r = Int(int % BigInt(base))
			intdigits.insert(Int(r), at: 0)
			int = int / BigInt(base)
		}
		
		var ans = ""
		for i in 0..<intdigits.count {
			ans = ans + intdigits[i].AsciiCode
		}
		ans = ans + "."
		let fracfix = fix > 0 ? fix : fracdigits.count
		for i in 0..<fracfix {
			let d = i >= fracdigits.count ? 0 : fracdigits[i]
			ans = ans + d.AsciiCode
		}
		return ans
	}
	
	func expString(_ base : Int = 10 , fix : Int) -> String {
		if self.significand < 0 {
			let neg = -self
			return "-" + neg.expString(base,fix: fix)
		}
		if self.significand == 0 {
			return "0"
		}
		
		let bfbase = BigFloat(base)
		var (int, fract) = SplitIntFract()
		var ex = 0
		while int == 0 {	//Mutilply until greater 1
			(int,fract) = (fract*bfbase).SplitIntFract()
			ex = ex - 1
		}
		
		var fracdigits : [Int] = []
		var ndigits = fix
		var started = false
		while ndigits > 0 {
			var r:BigInt
			fract = fract * bfbase
			(r, fract) = fract.SplitIntFract()
			if r != 0 { started = true }
			let digit = Int(r)
			fracdigits.append(digit)
			if fract.significand == 0 { break }
			if started { ndigits = ndigits - 1 }
		}
		
		var carry = false
		if fract * BigFloat(2) >= BigFloat(1) {   // round up!
			var idx = fracdigits.count
			carry = true
			while idx > 0 {
				if fracdigits[idx - 1] < base - 1 {
					fracdigits[idx - 1] += 1
					carry = false
					break
				}
				
				fracdigits[idx - 1] = 0
				idx -= 1
			}
		}
		
		if carry { int = int + 1 }
		var intdigits : [Int] = []
		while int > 0 {
			let r = int % BigInt(base)
			intdigits.insert(Int(r), at: 0)
			int = int / BigInt(base)
		}
		ex = ex + intdigits.count - 1
		
		var ans = ""
		var digitcount = 0
		for i in 0..<intdigits.count  {
			ans = ans + intdigits[i].AsciiCode
			if i == 0 {
				ans = ans + "."
			}
			digitcount = digitcount + 1
			if digitcount >= fix { break }
		}
		for i in 0..<fracdigits.count {
			if digitcount > fix { break }
			ans = ans + fracdigits[i].AsciiCode
			digitcount = digitcount + 1
			
		}
		
		ans = ans + "E" + String(ex)
		return ans
	}
}




