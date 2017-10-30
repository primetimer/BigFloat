	
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
	
	public func isZero() ->Bool {
		return significand == 0
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
		self.significand >>= BigInt(shift-1)
		let carry = significand & 1
		if carry>0 {
			self.significand += 1
		}
		self.significand >>= 1
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
		let px = min(t.precision, BigFloat.maxprecision)
		t = t.truncate(bits: px)
		
		var s = self.significand
		var ex = self.exponent
		var sgn = FloatingPointSign.plus
		if s.sign == .minus {
			sgn = FloatingPointSign.minus
			s = -s
		}
		while s.bitWidth > 64 {
			s >>= 1
			ex = ex + 1
		}
		let d = Double(sign: sgn, exponent: ex, significand: Double(s))
		return d
	}
	
	public func divide(by:BigFloat, precision:Int=0)->BigFloat {
		let px = (precision > 0) ? precision : BigFloat.maxprecision
		let r = by.reciprocal(precision: px)
		var prod = (self * r)
		_ = prod.truncate(bits: px)
		
		/*
		do {
			let sd = self.toDouble()
			let rd = r.toDouble()
			let prodd = prod.toDouble()
			print("Divisionmul",sd,rd,prodd)
		}
		*/
		return prod
	}
	
	public func reciprocal(precision:Int=32)->BigFloat {
		if self.significand == 0 {
			return self
		}
		if self.significand == 1 {
			return BigFloat(significand:1, exponent:-self.exponent)
		}
		
		let ex = self.exponent + significand.bitWidth + 1
		//let px = max(self.precision, precision)
		let px = 256
		
		let n = BigInt(1) << BigInt(px*2+2*significand.bitWidth)
		
		let q = n / self.significand
		print(self.significand,significand.bitWidth,self.exponent)
		print(n)
		print(q,q.bitWidth)
		var ans = BigFloat(significand:q, exponent:-ex-q.bitWidth+4)
		ans.normalize()
		return ans
	}
	
	/*
	public func reciprocal(precision:Int=0)->BigFloat {
		if self.significand == 0 { return self }
		if self.significand == 1 {
			return BigFloat(significand:1, exponent:-self.exponent)
		}
		// let ex = self.exponent + significand.bitWidth
		let px = BigFloat.maxprecision
		//let px = max(self.precision, precision)
		let n = BigInt(1) << BigInt(px*2 + significand.bitWidth)
		//print("n",self.exponent,q,
		let q = n / self.significand
		var ans = BigFloat(significand:q, exponent:(-self.exponent - 2*px-significand.bitWidth))
		ans.normalize()
		ans.truncate(bits: px)

		return ans
	}
	*/
	
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

public func >(lhs:BigFloat, rhs:BigFloat)->Bool {
	let d = lhs - rhs
	let s = d.significand.sign
	return (s == .plus)
}

public func <=(lhs:BigFloat, rhs:BigFloat)->Bool {
	if lhs == rhs { return true }
	return lhs < rhs
}

public func >=(lhs:BigFloat, rhs:BigFloat)->Bool {
	if lhs == rhs { return true }
	return lhs > rhs
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


