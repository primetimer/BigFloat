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
}
