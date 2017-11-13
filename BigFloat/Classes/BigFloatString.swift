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
	
	public func String(withbase : Int) -> String {
		if self == 0 { return "0" }
		var num = abs(self)
		var ans = ""
		while num > 0 {
			let digit = num % withbase
			ans = digit.AsciiCode + ans
			num = num / withbase
		}
		if self < 0 {
			ans = "-" + ans
		}
		return ans
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
		let bfmax = BigFloat(maxval)
		if BigFloat.abs(self) > bfmax {
			return expString(base, fix : fix)
		}
		if BigFloat.abs(self) < BigFloat(1) / bfmax  {
			return expString(base, fix : fix)
		}
		return asString(base,fix: fix)
		
	}
	
	public func asString(_ base : Int = 10 , maxlen: Int = 18, fix : Int = 8) -> String {
		
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
		
		var len = 0
		var ans = ""
		for i in 0..<intdigits.count {
			ans = ans + intdigits[i].AsciiCode
			len = len + 1
			if len >= maxlen && maxlen > 0 {
				return expString(base, fix: Swift.abs(fix))
			}
		}
		ans = ans + "."
		let fracfix = fix > 0 ? fix : fracdigits.count
		for i in 0..<fracfix {
			let d = i >= fracdigits.count ? 0 : fracdigits[i]
			ans = ans + d.AsciiCode
			len = len + 1
			if len >= maxlen && maxlen > 0 { break }
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
		
		var digits : [Int] = []
		while int > 0 {
			let r = int % BigInt(base)
			digits.insert(Int(r), at: 0)
			int = int / BigInt(base)
		}
		ex = ex + digits.count - 1

		var ndigits = fix - digits.count
		var started = false
		while ndigits >= 0 {
			var r:BigInt
			fract = fract * bfbase
			(r, fract) = fract.SplitIntFract()
			if r != 0 { started = true }
			let digit = Int(r)
			digits.append(digit)
			if fract.significand == 0 { break }
			if started { ndigits = ndigits - 1 }
		}
		
		//Letzte Ziffer + 1
		while digits.count <= fix {
			digits.append(0)
		}
		var pos = fix
		let d = digits[pos]
		if d >= base / 2 {
			var carry = true
			while pos > 0 && carry == true{
				pos = pos - 1
				if digits[pos] < base - 1 {
					digits[pos] = digits[pos] + 1
					carry = false
				} else {
					digits[pos] = 0
				}
			}
			if carry {
				digits.insert(1, at: 0)
				ex = ex + 1
			}
		}
		
		var ans = ""
		var digitcount = 0
		for i in 0..<digits.count  {
			ans = ans + digits[i].AsciiCode
			if i == 0 {
				ans = ans + "."
			}
			digitcount = digitcount + 1
			if digitcount >= fix { break }
		}
		let estr = base == 10 ? " e" : " x"
		ans = ans + estr + ex.String(withbase: base)
		return ans
	}
}




