
import Foundation
import BigInt

extension BigInt {
	func ExponentialString() {
		
	}
}

//Copied from BigInt library
extension BigUInt {
	
	//MARK: String Conversion
	
	/// Calculates the number of numerals in a given radix that fit inside a single `Word`.
	///
	/// - Returns: (chars, power) where `chars` is highest that satisfy `radix^chars <= 2^Word.bitWidth`. `power` is zero
	///   if radix is a power of two; otherwise `power == radix^chars`.
	fileprivate static func charsPerWord(forRadix radix: Int) -> (chars: Int, power: Word) {
		var power: Word = 1
		var overflow = false
		var count = 0
		while !overflow {
			let (p, o) = power.multipliedReportingOverflow(by: Word(radix))
			overflow = o
			if !o || p == 0 {
				count += 1
				power = p
			}
		}
		return (count, power)
	}
}

/*
extension String {
public init(_ v: BigUInt, radix: Int, exponential : Bool) {

var ex = 0
while true {

}
precondition(radix > 1)
let (charsPerWord, power) = BigUInt.charsPerWord(forRadix: radix)
guard v != 0 else { self = "0"; return }

var parts: [String]
if power == 0 {
parts = v.words.map { String($0, radix: radix, uppercase: true) }
}
else {
parts = []
var rest = v
while rest != 0 {
let mod = rest / BigUInt(power)
parts.append(String(mod, radix: radix, uppercase: true))
}
}
assert(!parts.isEmpty)

self = ""
var first = true
for part in parts.reversed() {
let zeroes = charsPerWord - part.characters.count
assert(zeroes >= 0)
if !first && zeroes > 0 {
// Insert leading zeroes for mid-Words
self += String(repeating: "0", count: zeroes)
}
first = false
self += part
}
}

}
*/

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

extension BigFloat : CustomStringConvertible {
	public var description: String {
		//let ans = self.toString(base: 10, fix: 0)
		let ans = self.ExponentialString(base: 10)
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
		var digits : [Int] = []
		while int > 0 {
			let digit = int / div
			digits.append(Int(digit))
			int = int % div
			div = div / bbase
		}
		
		// Bestimme den Nachkommanteil
		var fracdigits : [Int] = []
		if fract > BigFloat(0) {
			let dfactor = log(2) / log(Double(base))
			var ndigits = fix != 0 ? fix
				: Swift.max(Int(Double(self.precision) * dfactor)+2, 17)
			
			var fracstarted = false
			while ndigits > 0 {
				var r: BigInt
				fract = fract*BigFloat(base)
				(r, fract) = fract.SplitIntFract()
				if r != 0 { fracstarted = true }
				fracdigits.append(Int(r))
				if fract.isZero() { break }
				if fracstarted { ndigits -= 1 }
			}
		}
		
		
		var str = ""
		var fracstr = ""
		do {
			var started = false
			for d in digits {
				if !started {
					str = String(d) + "."
					started = true
				} else {
					str = str + String(d)
				}
			}
		}
		do {
			for d in fracdigits {
				fracstr = fracstr + String(d)
			}
		}
		return str  + fracstr + "E" + String(ex)
	}
	
	
	/*
	public func ExponentailString(base : Int) -> String {
	
	if self.significand == 0 { return "0." }
	let compare = self.toString(base: base, fix: 0)
	
	var temp = self
	var basepow = BigFloat(base)
	var ex = 0
	if self >= BigFloat(base) {
	while temp >= BigFloat(base)
	{
	temp = self / basepow
	basepow = basepow * BigFloat(base)
	ex = ex + 1
	}
	} else {
	while temp < BigFloat(1.0)
	{
	temp = self * basepow
	basepow = basepow * BigFloat(base)
	ex = ex - 1
	}
	}
	
	let str = temp.toString(base: base, fix: 16)
	let exstr = String(ex)
	let ans = str + " E" + exstr
	return ans
	}
	*/
}



