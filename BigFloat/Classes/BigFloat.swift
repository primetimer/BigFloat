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
    public var significand:BigInt = 0
    public var exponent:Int = 0
    public static let maxExponent = Int.max
    public init(significand:BigInt, exponent:Int) {
        self.significand = significand
        self.exponent = exponent
    }
	
    public init(_ bi:BigInt) {
        var (s, e) = (bi, 0)
        while s != 0 && s & 1 == 0 {
            s >>= 1
            e += 1
        }
        significand = s
        exponent = e
    }
    public init(_ r:BigFloat) {
        significand = r.significand
        exponent = r.exponent
    }
	
    public init(_ i:Int) {
        var (s, e) = (i, 0)
        while s != 0 && s & 1 == 0 {
            s >>= 1
            e += 1
        }
        significand = BigInt(s)
        exponent = e
    }
    public init(_ d:Double) {
		if d == 0.0 {
            exponent = 0
            significand = 0
			return
        }
		var m = d.significand
		var e = d.exponent
		let w = d.significandWidth
		for _ in 0..<w {
				m = m * 2
				e = e - 1
		}
		self.significand = BigInt(m)
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
    public static let precision = 1024
	
    public func toDouble()->Double {
		var t = self
		t = t.truncate(bits: t.precision)
		let d = Double(t.significand) * pow(2.0,Double(t.exponent))
        return d
    }
		
    public func divide(by:BigFloat, precision:Int=32)->BigFloat {
		let r = by.reciprocal(precision: precision)
		var prod = (self * r)
		_ = prod.truncate(bits: 2*precision)
		
		do {
			let sd = self.toDouble()
			let rd = r.toDouble()
			let prodd = prod.toDouble()
			print("Divisionmul",sd,rd,prodd)
		}
		return prod
    }
	
    public func reciprocal(precision:Int=32)->BigFloat {
		if self.significand == 0 { return self }
		if self.significand == 1 {
            return BigFloat(significand:1, exponent:-self.exponent)
        }
        let ex = self.exponent + significand.bitWidth
		//print(self.exponent,significand.bitWidth)
		let px = precision //max(self.precision, precision)
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
   // print("\(lhs.toDouble()) + \(rhs.toDouble())")
    var (ls, rs) = (lhs.significand, rhs.significand)
    let dx = lhs.exponent - rhs.exponent
    // print("dx = ", dx)
    if dx < 0  {
        rs <<= BigInt(-dx)
    } else if dx > 0  {
        ls <<= BigInt(+dx)
    }
    let ex = max(lhs.exponent, rhs.exponent)
    let sig = ls + rs
    // if sig.msbAt > ex // { ex -print("sig.msbAt = \(sig.msbAt), ls.msbAt = \(ls.msbAt), rs.msbAt = \(rs.msbAt)")
    return BigFloat(significand:sig, exponent:ex - Swift.abs(dx))
}
public func -(lhs:BigFloat, rhs:BigFloat)->BigFloat {
    return lhs + (-rhs)
}

//

 extension BigFloat : CustomStringConvertible {
	public var description: String {
		let sstr = String(significand)
		let estr = String(exponent)
		let ans = sstr + " E:" + estr
		return ans
	}
}



