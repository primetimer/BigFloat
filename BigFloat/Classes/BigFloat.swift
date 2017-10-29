//
//  pobigfloat.swift
//  test
//
//  Created by Dan Kogai on 2/17/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//
import Foundation
import BigInt

public struct BigFloat : ExpressibleByFloatLiteral {
	//public var sign : Int = 1
    public var significand:BigInt = 0
    public var exponent:Int = 0
    public static let maxExponent = Int.max
    public init(significand:BigInt, exponent:Int) {
        self.significand = significand
        self.exponent = exponent
    }
	
	private mutating func normalize() {
		var (s, e) = (significand, exponent)
		while s != 0 && s & 1 == 0 {
			s >>= 1
			e += 1
		}
		self.significand = s
		exponent = e
	}
	
    public init(_ bi:BigInt) {
		significand = bi
		exponent = 0
    }
    public init(_ r:BigFloat) {
        significand = r.significand
        exponent = r.exponent
    }
	
    public init(_ i:Int) {
		significand = BigInt(i)
		exponent = 0
	   normalize()
    }
    public init(_ d:Double) {
		if d == 0.0 {
            exponent = 0
            significand = 0
			return
        }
		var m = (d > 0.0 ) ? d.significand : (-d).significand
		var e = (d > 0.0 ) ? d.exponent : (-d).exponent
		let w = (d > 0.0 ) ? d.significandWidth : (-d).significandWidth
		let sign = (d > 0.0) ? 1.0 : -1.0
		for _ in 0..<w {
				m = m * 2
				e = e - 1
		}
		self.significand = BigInt(sign*m)
		self.exponent = e
    }
	
	public mutating func truncate(bits:Int)->BigFloat {
		if significand == 0 { return self }
		let shift = self.precision - bits
		if shift <= 0 { return self }
		let ex = self.exponent + (self.significand.bitWidth)
		self.significand >>= BigInt(shift)
		self.exponent = ex - self.significand.bitWidth
		while self.significand != 0 && self.significand & 1 == 0 {
			self.significand >>= 1
			self.exponent    += 1
		}
		return self
	}
	
    // IntegerLiteralConvertible
    public typealias IntegerLiteralType = Int.IntegerLiteralType
    public init(integerLiteral:IntegerLiteralType) {
        self.init(integerLiteral)
    }
    // FloatLiteralConvertible
    public typealias FloatLiteralType = Double.FloatLiteralType
    public init(floatLiteral:FloatLiteralType) {
        self.init(floatLiteral)
    }
    public var precision:Int {
        return significand.bitWidth + 1
    }
    public static let maxprecision = 1024
	
    public func toDouble()->Double {
		var t = self
		t = t.truncate(bits: t.precision)
		let d = Double(t.significand) * pow(2.0,Double(t.exponent))
        return d
    }
		
	public func divide(by:BigFloat, precision:Int=0)->BigFloat {
		let px = (precision > 0) ? precision : BigFloat.maxprecision
		let r = by.reciprocal(precision: px)
		var prod = (self * r)
		_ = prod.truncate(bits: px)
		
		do {
			let sd = self.toDouble()
			let rd = r.toDouble()
			let prodd = prod.toDouble()
			print("Divisionmul",sd,rd,prodd)
		}
		return prod
    }
	
    public func reciprocal(precision:Int=0)->BigFloat {
		if self.significand == 0 { return self }
		if self.significand == 1 {
            return BigFloat(significand:1, exponent:-self.exponent)
        }
       // let ex = self.exponent + significand.bitWidth
		var px = BigFloat.maxprecision
		//let px = max(self.precision, precision)
        let n = BigInt(1) << BigInt(px*2 + significand.bitWidth)
		//print("n",self.exponent,q,
        let q = n / self.significand
        return BigFloat(significand:q, exponent:(-self.exponent - 2*px-significand.bitWidth))
    }
	
    public func frexp()->(BigFloat, Int)   {
        return (
            BigFloat(significand:self.significand, exponent:-(self.significand.bitWidth+1)),
            self.exponent + self.significand.bitWidth + 1
        )
    }
    public static func frexp(r:BigFloat)->(BigFloat, Int) {
        return r.frexp()
    }
    public func ldexp(ex:Int)->BigFloat {
		let nex = self.exponent + ex
        return BigFloat(significand:self.significand, exponent:nex)
    }
    public static func ldexp(r:BigFloat, _ ex:Int)->BigFloat {
		return r.ldexp(ex: ex)
    }
}

public func ==(lhs:BigFloat, rhs:BigFloat)->Bool {
    return lhs.significand == rhs.significand && lhs.exponent == rhs.exponent
}

public func <(lhs:BigFloat, rhs:BigFloat)->Bool {
	let d = lhs - rhs
	let s = d.significand.sign
	return (s == .minus)
}

public func *(lhs:BigFloat, rhs:BigFloat)->BigFloat {
	let s = lhs.significand * rhs .significand
	let e = lhs.exponent + rhs.exponent
	var ans = BigFloat(significand : s, exponent : e)
	_ = ans.truncate(bits: ans.precision)
	return ans
}
public func /(lhs:BigFloat, rhs:BigFloat)->BigFloat {
	return lhs.divide(by: rhs)
}

public prefix func -(bf:BigFloat)->BigFloat {
    return BigFloat(significand:-bf.significand, exponent:bf.exponent)
}
public func +(lhs:BigFloat, rhs:BigFloat)->BigFloat {
    var (ls, rs) = (lhs.significand, rhs.significand)
    let dx = lhs.exponent - rhs.exponent
    if dx < 0  {
        rs <<= BigInt(-dx)
    } else if dx > 0  {
        ls <<= BigInt(+dx)
    }
    let ex = max(lhs.exponent, rhs.exponent)
    let sig = ls + rs
    return BigFloat(significand:sig, exponent:ex - Swift.abs(dx))
}
public func -(lhs:BigFloat, rhs:BigFloat)->BigFloat {
	let subtrahend = -rhs
    return lhs + subtrahend
}

//

 extension BigFloat : CustomStringConvertible {
	public var description: String {
		let ans = self.toString(base: 10, fix: 0)
		//let sstr = String(significand)
		//let estr = String(exponent)
		//let ans = sstr + " E:" + estr
		return ans
	}
}

public extension BigInt {
	public init(_ bf:BigFloat) {
		if 0 <= bf.exponent {
			self.init(bf.significand << BigInt(bf.exponent))
		}
		else if -bf.exponent <= bf.significand.bitWidth {
				self.init(bf.significand >> BigInt(-bf.exponent))
			} else {
				self.init(0)
			}
		}
}
public extension BigFloat {
	
	public func SplitIntFract()->(BigInt, BigFloat) {
		let i = BigInt(self)
		return (i, self - BigFloat(i))
	}
	
	public func isZero() ->Bool {
		return significand == 0
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
			while 0 < ndigits {
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
	}




