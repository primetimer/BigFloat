//
//  RPNBig.swift
//  PFactors_Example
//
//  Created by Stephan Jancar on 19.10.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import BigInt
import PrimeFactors
import BigFloat

enum StackState : Int {
	case valid = 0, stored, cancelled, error, overflow, busy , prime, unimplemented, factorized, copied
}

enum CalcType : Int {
	case Undefined,Plus,Minus,Prod,Divide, LastX, Mersenne, Square, Cube, TenPow
	case PNext, PPrev //, Sexy, Cousin, Twin, SoG, Rho, Squfof, Lehman, Factor, Factors
	case Swap, Pop, Pow, PowMod, exp, ln, pi
	case Mod, gcd, sqrt, crt, Hash,Rnd
	case Sto1,Sto2,Sto3, Rcl1,Rcl2,Rcl3, CmdC, CmdV
}

class RPNCalc : CalcCancellable {
	
	override public init() {
		super.init()
		pcalc.canceldelegate = self
	}
	
	func Copy() -> RPNCalc {
		let copy = RPNCalc()
		copy.stackstate = self.stackstate
		for val in stack {
			copy.stack.append(val)
		}
		copy.sto = self.sto
		return copy
	}
	
	private let pcalc = ExtendedPrimeCalculator()
	private var bitMax = 1024
	var stackstate = StackState.valid
	var stack : [StackElem] = []
	private var sto : [StackElem] = [StackElem(),StackElem(),StackElem()]
	private var lastx = StackElem()
	
	func push(x: StackElem) {
		stack.insert(x, at: 0)
		/*
		if x.bitWidth > bitMax {
			self.stackstate = .overflow
		} else {
			self.stackstate = .valid
		}
		*/
	}
	
	func push(num: BigInt) {
		stack.insert(StackElem(num: num), at: 0)
		if num.bitWidth > bitMax {
		self.stackstate = .overflow
		} else {
		self.stackstate = .valid
		}
	}
	func push(val: BigFloat) {
		stack.insert(StackElem(val: val), at: 0)
	}
	func push() {
		let x = self.x
		stack.insert(x, at: 0)
	}
	
	private func popx() {
		lastx = x
		pop()
	}
	func pop() {
		if stack.count > 0 {
			stack.remove(at: 0)
		}
		stackstate = .valid
	}
	
	func Clear() {
		lastx = StackElem()
		stack.removeAll()
		stackstate = .valid
	}
	
	public subscript(index: Int) -> StackElem {
		if index >= stack.count {
			return StackElem()
		}
		return stack[index]
	}

	var x : StackElem {
		get {
			if stack.count > 0 { return stack[0] } else { return StackElem() }
		}
		set {
			if stack.count > 0 { stack[0] = newValue } else { push(x: newValue)	}
		}
	}
	
	var y : StackElem {
		get {
			if stack.count > 1 { return stack[1] } else { return StackElem() }
		}
		set {
			if stack.count > 1 { stack[1] = newValue } else { push(x: newValue)	}
		}
	}
	
	var z : StackElem {
		get {
			if stack.count > 2 { return stack[2] } else { return StackElem() }
		}
	}
	
	private func mod() {
		
		let ans = y.num % x.num
		popx()
		pop()
		push(x: StackElem(num: ans))
		stackstate = .valid
	}
	
	private func powmod() {
		let ans = z.num.power(y.num, modulus: x.num)
		popx()
		pop()
		pop()
		push(x: StackElem(num:ans))
		stackstate = .valid
	}
	
	private func PNext() {
		if x.num < 0 { stackstate = .error; return	}
		let ans = pcalc.NextPrime(n: BigUInt(x.num))
		popx()
		push(num: BigInt(ans))
		stackstate = .prime
	}
	
	private func PPrev() {
		if x.num <= 2 { stackstate = .error; return	}
		let ans = pcalc.PrevPrime(n: BigUInt(x.num))
		popx()
		push(num: BigInt(ans))
		stackstate = .prime
	}

	private func pow() {
		stackstate = .unimplemented
		/*
		if x > bitMax && (y>1) {
			stackstate = .overflow; return
		}
		if x == BigUInt(0) && y == BigUInt(0) {
			stackstate = .error
			return
		}
		if (x * BigUInt(y.bitWidth) > 2*bitMax) && (y>1)  {
			stackstate = .overflow
			return
		}
		
		let z = y.power(Int(x))
		popx()
		pop()
		push(x:z)
		stackstate = .valid
		*/
	}
	
	private func square() {
		let sq = x.value * x.value
		popx()
		push(val: sq)
		stackstate = .valid
	}
	private func cube() {
		let c = x.value * x.value * x.value
		popx()
		push(val: c)
		stackstate = .valid
	}
	private func tenpow() {
		stackstate = .unimplemented
		/*
		if x > bitMax { stackstate = .overflow; return }
		let t = BigUInt(10).power(Int(x))
		popx()
		push(x: t)
		stackstate = .valid
		*/
	}
	
	
	private func mersenne() {
		stackstate = .unimplemented
		/*
		if x < BigUInt(bitMax) {
			let m = BigUInt(2).power(Int(x)) - 1
			popx()
			push(x: m)
			stackstate = .valid
		} else {
			stackstate = .overflow
		}
		*/
	}
	
	private func plus() {
		let sum = x.value + y.value
		popx()
		pop()
		push(val: sum)
		stackstate = .valid
	}
	private func minus() {
		let dif = y.value - x.value
		popx()
		pop()
		push(val: dif)
		stackstate = .valid
	}
	private func prod() {
		let prod = x.value*y.value
		popx()
		pop()
		push(val: prod)
		stackstate = .valid
	}
	private func divide() {
		if x.value == BigFloat(0) {
			stackstate = .error
			return
		}
		let div = y.value / x.value
		popx()
		pop()
		push(val: div)
		stackstate = .valid
	}
	
	private func Rho() {
		stackstate = .unimplemented
		/*
		let rho = PrimeFaktorRho()
		rho.canceldelegate = self
		if !x.isPrime() {
			let factor = rho.GetFactor(n: x)
			if factor < x && factor >= 2 {
				push(x: factor)
				stackstate = .valid
			}
			else {
				stackstate = .error
			}
		} else {
			stackstate = .prime
		}
		*/
	}
	
	private func Squfof() {
		stackstate = .unimplemented
		/*
		let shanks = PrimeFactorShanks()
		shanks.canceldelegate = self
		if !x.isPrime() {
			let factor = shanks.GetFactor(n: x)
			if factor < x && factor >= 2 {
				push(x: factor)
				stackstate = .valid
			}
		} else {
			stackstate = .prime
		}
		*/
	}
	
	private func Lehman() {
		stackstate = .unimplemented
		/*
		let lehman = PrimeFactorLehman()
		lehman.canceldelegate = self
		if !x.isPrime() {
			let factor = lehman.GetFactor(n: x)
			if factor < x && factor >= 2 {
				push(x: factor)
				stackstate = .valid
			}
		} else {
			stackstate = .prime
		}
		*/
	}
	
	private func twin(dif : Int = 2) {
		stackstate = .unimplemented
		/*
		let twin = pcalc.NextTwin(n: x)
		popx()
		push(x: twin+2)
		push(x: twin)
		stackstate = .prime
		*/
	}
	
	private func sexy() {
		stackstate = .unimplemented
		/*
		var p = pcalc.NextPrime(n: x)
		var p6 = p + 6
		while true {
			if pcalc.IsPrime(n: p6) { break }
			p = pcalc.NextPrime(n: p)
			p6 = p + 6
		}
		popx()
		push(x: p6)
		push(x: p)
		stackstate = .prime
		*/
	}
	private func cousin() {
		stackstate = .unimplemented
/*
		var p = pcalc.NextPrime(n: x)
		var p4 = p + 4
		while true {
			if pcalc.IsPrime(n: p4) { break }
			p = pcalc.NextPrime(n: p)
			p4 = p + 4
		}
		popx()
		push(x: p4)
		push(x: p)
		stackstate = .prime
*/
	}
	
	private func sog() {
		stackstate = .unimplemented
/*
		let sog = pcalc.NextSoG(n: x)
		popx()
		push(x: 2*sog+1)
		push(x: sog)
		stackstate = .prime
*/
	}
	
	private func factor() {
		stackstate = .unimplemented
	}
	private func factors() {
		stackstate = .unimplemented
	}
	
	private func swap() {
		let temp = y
		y = x
		x = temp
		stackstate = .valid
	}
	
	private func gcd() {
		let g = x.num.greatestCommonDivisor(with: y.num)
		popx()
		pop()
		push(num: g)
		stackstate = .valid
	}
	
	private func sqrt() {
		if x.value < BigFloat(0) {
			stackstate = .error
			return
		}
		let r = BigFloat.sqrt(x: x.value)
		pop()
		push(x: StackElem(val: r))
		stackstate = .valid
		/*
		let ans = x.squareRoot()
		popx()
		push(x: ans)
				stackstate = .valid
		*/
	}
	
	private func exp() {
		if (x.value > BigFloat(1000)) {
			stackstate = .overflow
		} else {
			let r = BigFloat.exp(x: x.value)
			pop()
			push(x: StackElem(val: r))
			stackstate = .valid
		}
	}
	
	private func pi() {
		let pi = BigFloatConstant.pi
		push(x: StackElem(val :pi))
	}
	
	private func ln() {
		if (x.value <= BigFloat(0)) {
			stackstate = .overflow
			return
		}
		let lnval = BigFloat.ln(x: x.value)
		pop()
		push(x: StackElem(val:lnval))
		stackstate = .valid
	}
	
	private	func crt() {
		stackstate = .unimplemented
		/*
		let ans = x.iroot3()
		popx()
		push(x: ans)
		stackstate = .valid
		*/
	}
	
	private func hash() {
		stackstate = .unimplemented
/*
		let hash = x.hashValue.toUint()
		popx()
		push(x: BigUInt(hash))
*/
	}
	
	private func cmdc() {
		let pasteBoard = UIPasteboard.general
		pasteBoard.string = x.value.ExponentialString(base: 10, fix: 100)
		stackstate = .copied
	}
	private func cmdv() {
		let pasteBoard = UIPasteboard.general
		var numstr = ""
		var fracstr = ""
		var expstr = ""
		var expmode = false
		var fracmode = false
		
		var value = BigFloat(0)
		
		if  let str = pasteBoard.string {
			for c in Array(str) {
				switch c {
				case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
					if expmode {
						expstr = expstr+String(c)
					} else if fracmode {
						fracstr = fracstr + String(c) }
					else {
						numstr = numstr + String(c)
					}
				case ".":
					if !expmode { fracmode = true }
				case "E":
					expmode = true
				default:
					break
				}
			}
				
				if numstr.count > 100 { stackstate = .overflow; return }
				if let i = BigInt(numstr) {
					value = BigFloat(i)
				}
				if let f = BigInt(fracstr) {
					let b = BigFloat(10)
					var bpow = BigFloat(1)
					for _ in 1...fracstr.count {
						bpow = bpow * b
					}
					value = value + BigFloat(f) / bpow
				}
				
				if let e = BigInt(expstr) {
					if e > BigInt(1000)  { stackstate = .overflow; return }
					if e < BigInt(-1000) { stackstate = .overflow; return }
					let eint = Int(e)
					let b = BigFloat(10)
					var bpow = BigFloat(1)
					if eint > 0 {
						for _ in 1...eint { bpow = bpow * b }
						value = value * bpow
					}
					if eint < 0 {
						for _ in 1 ... -eint { bpow = bpow * b }
						value = value / bpow
					}
				}
			}
			push(x: StackElem(val: value))
			stackstate = .copied
		
	}
	
	private func rnd() {
		stackstate = .unimplemented
		/*
		let limit = (x==0) ? 10000000000 : x
		let r = BigUInt.randomInteger(lessThan: limit)
		popx()
		push(x: r)
		*/
	}
	
	private func lastX() {
		push(x: lastx)
	}

	func Calculation(type : CalcType)
	{
		switch type {
		case .LastX:	lastX()
		case .CmdC: 	cmdc()
		case .CmdV:		cmdv()
		case .Plus:		self.plus()
		case .Minus:	self.minus()
		case .Prod:		self.prod()
		case .Divide:	self.divide()
		case .gcd:		self.gcd()
		case .sqrt:		self.sqrt()
		case .crt:		self.crt()
		case .pi:		self.pi()
		case .exp:		self.exp()
		case .ln:		self.ln()
		case .Swap:		self.swap()
		case .Pop:		self.pop()
		case .PNext:	self.PNext()
		case .PPrev:	self.PPrev()
		//case .Sexy:		self.sexy()
		//case .Cousin: 	self.cousin()
		case .Pow:		self.pow()
		case .Mod:		self.mod()
		case .PowMod:	self.powmod()
		//case .Twin:		self.twin()
		//case .SoG:		self.sog()
		//case .Rho:		self.Rho()
		//case .Squfof:	self.Squfof()
		//case .Lehman:	self.Lehman()
		//case .Factor:	self.factor()
		case .Rnd:		self.rnd()
		case .Hash: 	self.hash()
		case .Square: 	self.square()
		case .Cube:		self.cube()
		case .TenPow:	self.tenpow()
		case .Mersenne: self.mersenne()
		case .Undefined:	break
		//case .Factors:	self.factors()
		case .Sto1:		sto[0] = x; stackstate = .stored
		case .Sto2:		sto[1] = x; stackstate = .stored
		case .Sto3:		sto[2] = x;	stackstate = .stored
		case .Rcl1:		push(x: sto[0]); stackstate = .valid
		case .Rcl2:		push(x: sto[1]); stackstate = .valid
		case .Rcl3:		push(x: sto[2]); stackstate = .valid
		}
	}

}
