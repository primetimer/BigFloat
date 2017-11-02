//
//  BigFloatFunc.swift
//  BigFloat
//
//  Created by Stephan Jancar on 31.10.17.
//

import Foundation
import Darwin
import BigInt

//

public class BigFloatConstant {
	
	static private var _pi : BigFloat? = nil
	static public  var pi : BigFloat {
		get {
			if _pi != nil { return _pi! }
			let epsilon = BigFloat(significand:1, exponent:-BigFloat.maxprecision / 2)
			let half = BigFloat(1) / BigFloat(2)
			var a = BigFloat(1)
			var b = BigFloat.sqrt(x: half)
			var t = half*half
			var p = BigFloat(0)
			var twopow = BigFloat(1)
			//var partstr = ""
			while true {
				let a1 = (a+b)*half
				let b1 = BigFloat.sqrt(x: a*b)
				//let astr = a1.ExponentialString(base: 10, fix: 40)
				//let bstr = b1.ExponentialString(base: 10, fix: 40)
				let d = (a-a1)*(a-a1)*twopow
				t = t - d
				//let tstr = t.ExponentialString(base: 10, fix: 40)
				let p1 = (a1+b1)*(a1+b1) / BigFloat(4) / t
				let dif = BigFloat.abs(p1-p)
				if dif < epsilon { return p1 }
				
				twopow = twopow * BigFloat(2)
				a = a1
				b = b1
				p = p1
				//partstr = p.ExponentialString(base: 10, fix: 40)
				//print(astr, bstr, tstr,partstr)
			}
		}
	}
	
}
extension BigFloat {
	public static func exp(x:BigFloat, precision px:Int = 64)->BigFloat {
		if x.isZero() {
			return BigFloat(1)
		}
		
		let epsilon = BigFloat(significand:1, exponent:-BigFloat.maxprecision / 2)
		var ans = BigFloat(1)
		var summand = BigFloat(1)
		var k = BigFloat(1)
		while BigFloat.abs(summand) > epsilon {
			//let temp = BigFloat(1) / BigFloat(2)
			summand = summand * x
			summand = summand / k
			k = k + BigFloat(1)
			ans = ans + summand
			//let k = String(k.toDouble())
			//let s = summand.ExponentialString(base: 10, fix: 20)
			//print(k,s)
		}
		return ans
	}
	
	public static func sqrt(x:BigFloat, precision px:Int = 64)->BigFloat {
		let half = BigFloat(1) / BigFloat(2)
		var y0 = BigFloat(2)
		let epsilon = BigFloat(significand:1, exponent:-BigFloat.maxprecision / 2)
		var d : BigFloat
		repeat {
			var y1 = ( y0 + x / y0)
			y1 = y1 * half
			d = BigFloat.abs(y1 - y0)
			if x > BigFloat(1) { d = d / y1 }
			y0 = y1
		} while d > epsilon
		return y0
	}
	
	public static func hypot(x:BigFloat, _ y:BigFloat, precision px:Int=64)->BigFloat {
		//if let dx = x as? Double { return Self(Double.hypot(dx, y as! Double)) }
		var (r, l) = (x < BigFloat(0) ? -x : x, y < BigFloat(0) ? -y : y)
		if r < l { (r, l) = (l, r) }
		if l.isZero() { return r }
		let epsilon = BigFloat(significand:1, exponent: -BigFloat.maxprecision / 2)
		while epsilon < l {
			var t = l / r
			t = t * t
			t = t / (BigFloat(4) + t)
			r = r + BigFloat(2) * r * t
			l = l * t
			_ = r.truncate(bits: BigFloat.maxprecision)
			_ = l.truncate(bits: BigFloat.maxprecision)
			// print("r=\(r.toDouble()), l=\(l.toDouble()), epsilon=\(epsilon.toDouble())")
		}
		return r.truncate(bits: BigFloat.maxprecision)
	}
	
	public static func atan(x:BigFloat, precision bits:Int = 64)->BigFloat {
		
		let px = BigFloat.maxprecision / 2
		let atan1 = BigFloatConstant.pi / BigFloat(4)
		let epsilon = BigFloat(significand:1, exponent:-px)
		#if true    // Euler's formula
			let inner_atan:(BigFloat)->BigFloat = { x in
				let x2 = x*x
				let x2p1 = BigFloat(1) + x2
				var (t, r) = (BigFloat(1), BigFloat(1))
				for i in 1...px*4 {
					t = t * BigFloat(2) * (BigFloat(i) * x2).divide(by: BigFloat(2 * i + 1) * x2p1, precision:px)
					_ = t.truncate(bits: px)
					r = r + t
					_ = r.truncate(bits : px)
					// print("\(Self.self).inner_atan: r=\(r.debugDescription)")
					if t < epsilon { break }
				}
				return r * x / x2p1
			}
		#else   // AGM-like: http://mathworld.wolfram.com/InverseTangent.html
			let inner_atan:(Self)->Self = { x in
				let hypot1_x2 = hypot(1, x, precision:px)
				var a = Self(1).divide(hypot1_x2, precision:px)
				var b = Self(1)
				var b0 = b
				repeat {
					b0 = b
					a = (a + b) / 2
					b = sqrt(a * b, precision:px)
				} while b0 != b
				return x.divide(a * hypot1_x2, precision:px)
			}
		#endif
		let ax = BigFloat.abs(x)
		if ax == BigFloat(1) { return  x.significand < 0 ? -atan1 : atan1 }
		var r = ax < BigFloat(1) ? inner_atan(ax) : BigFloat(2) * atan1 - inner_atan(BigFloat(1)/ax)
		// print("\(Self.self).atan: r=\(r.debugDescription)")
		return x.significand<0 ? -r.truncate(bits:px) : r.truncate(bits:px)
	}
	
	public static func ln(x:BigFloat, precision bits:Int = 64)->BigFloat {
		//if let dx = x as? Double { return Self(Double.log(dx)) }
		let px = BigFloat.maxprecision / 2
		let epsilon = BigFloat(significand:1, exponent:-px)
		#if true    // euler
			let inner_log:(BigFloat, Int)->BigFloat = { x , px in
				var t = (x - BigFloat(1)).divide(by: x + BigFloat(1), precision:px)
				if x < BigFloat(1) { t = -t }
				let t2 = t * t
				var r = t
				for i in 1...px*2 {
					t = t * t2
					_ = t.truncate(bits: px)
					r = r + t / BigFloat(2*i + 1)
					// print("POReal#log: i=\(i), t=~\(t.toDouble()), r=~\(r.toDouble())")
					_ = r.truncate(bits: px)
					if t < epsilon { break }
				}
				return BigFloat(2) * (x < BigFloat(1) ? -r : r)
			}
		#else   // newton-raphson
			let inner_log:(BigFloat, Int)->Self = { x, px in
				var y = Self(1)
				for _ in 0...(x.precision.msbAt + 1) {
					let ex = exp(y, precision:px)
					var t = Self(2) * (x - ex)/(x + ex)
					y += t.truncate(px)
					// print("log: i=\(i), y=\(y.toFPString()), t=\(t.toDouble())")
					if t.abs < epsilon { break }
				}
				return y
			}
		#endif
		let ln2 = inner_log(BigFloat(2),px)
		let xx = x < BigFloat(1) ? BigFloat(1) / x : x
	
		//ln x = m * ln2 + ln(2^-m*x)
		let m = xx.significand.bitWidth + xx.exponent + 1
		let xm = BigFloat(significand: 1, exponent: -m)
		let xf = xm*xx
		//let xfstr = xf.ExponentialString(base: 10, fix: 40)
		//print(xfstr)
		let l = inner_log(xf,px)
		let logi = BigFloat(m)*ln2
		var ans = l + logi
		
		if x < BigFloat(1) {
			ans = -ans
		}
		_ = ans.truncate(bits: px)
		
		return ans
		
	}
	
	// ln(a^b) = b * ln(a) --> a^b = exp(b*ln(a))
	public static func pow(x:BigFloat, _ y:BigFloat,  bits:Int = 64)->BigFloat  {
		let xx = y*BigFloat.ln(x: x)
		let ans = BigFloat.exp(x: xx)
		return ans
	}
}
