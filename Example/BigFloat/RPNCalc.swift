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

class RPNCalc : CalcCancellable, CustomStringConvertible {
	var description: String {
		get {
			var ans = "StackDump:\n"
			for s in stack {
				ans = ans + s.description + "\n"
			}
			return ans
		}
	}
	
	
	private var storeage : ForthStorage
	override public init() {
		storeage = ForthStorage.shared
		super.init()
		pcalc.canceldelegate = self
	}
	
	func Copy() -> RPNCalc {
		let copy = RPNCalc()
		copy.stackstate = self.stackstate
		for val in stack {
			copy.stack.append(val)
		}
		return copy
	}
	
	private let pcalc = ExtendedPrimeCalculator()
	private var bitMax = 1024
	var stackstate = StackState.valid
	var stack : [StackElem] = []
	var lastx = StackElem()
	
	func push(x: StackElem) {
		stack.insert(x, at: 0)
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
		if x.value == BigFloat(0) && y.value == BigFloat(0) {
			stackstate = .error
			return
		}
		let z = BigFloat.pow(x: y.value,y: x.value)
		popx()
		pop()
		push(val: z)
		stackstate = .valid
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
		let ten = BigFloat(10)
		let ans = BigFloat.pow(x: ten, y: x.value)
		popx()
		push(val: ans)
		stackstate = .valid
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
		if x.type == .Alpha {
			if y.type == .Alpha {
				let sum : String = x.alpha + y.alpha
				popx()
				pop()
				let sumelem = StackElem(alpha: sum)
				push(x: sumelem)
			}
		}
		if x.type == .ProgLine {
			if y.type == .ProgLine {
				var sum = ProgLine()
				sum.append(add: x.prog)
				sum.append(add: y.prog)
				let sumelem = StackElem(progline: sum)
				popx()
				pop()
				push(x: sumelem)
			}
		}
		if x.type == .BigFloat {
			if y.type == .BigFloat {
				let sum = x.value + y.value
				popx()
				pop()
				push(val: sum)
				stackstate = .valid
			}
		}
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
	
	private func negate() {
		let neg = -self.x.value
		pop()
		push(val: neg)
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
	}
	
	private func sin() {
		let r = BigFloat.sin(x: x.value)
		popx()
		push(x: StackElem(val: r))
		stackstate = .valid
	}
	private func cos() {
		let r = BigFloat.cos(x: x.value)
		popx()
		push(x: StackElem(val: r))
		stackstate = .valid
	}
	
	private func tan() {
		let r = BigFloat.tan(x: x.value)
		popx()
		push(x: StackElem(val: r))
		stackstate = .valid
	}
	
	private func atan() {
		let r = BigFloat.atan(x: x.value)
		popx()
		push(x: StackElem(val: r))
		stackstate = .valid
	}
	private func acos() {
		if BigFloat.abs(x.value) > BigFloat(1) {
			stackstate = .error
		} else {
			let r = BigFloat.acos(x: x.value)
			popx()
			push(x: StackElem(val: r))
		}
		stackstate = .valid
	}
	private func asin() {
		if BigFloat.abs(x.value) > BigFloat(1) {
			stackstate = .error
		} else {
			let r = BigFloat.asin(x: x.value)
			popx()
			push(x: StackElem(val: r))
		}
		stackstate = .valid
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
	
	private func invers() {
		if x.value == BigFloat(0) {
			stackstate = .error
		} else {
			let xinv = BigFloat(1) / x.value
			pop()
			push(x: StackElem(val: xinv))
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
	
	
	private func rnd() {
		stackstate = .unimplemented
	}
	
	private func unimplemented() {
		stackstate = .unimplemented
	}
	
	private func lastX() {
		push(x: lastx)
	}
	
	private func store() {
		if x.type != .Alpha {
			stackstate = .error
			return
		}
		storeage.Store(key: x.alpha, elem: y)
		pop()
		pop()
		stackstate = .stored
	}
	
	private func rcl() {
		if x.type != .Alpha {
			stackstate = .error
			return
		}
		let elem = storeage.Recall(key: x.alpha)
		pop()
		push(x: elem)
		stackstate = .valid
	}
	
	private func equal() {
		var compared = false
		if x.type == .Alpha { compared = x.alpha == y.alpha }
		if x.type == .BigFloat { compared = x.value == y.value }
		stackstate = .valid
		pop()
		pop()
		let result = compared ? BigFloat(1) : BigFloat(0)
		push(x: StackElem(val: result))
	}
	
	private func unequal() {
		var compared = false
		if x.type == .Alpha { compared = x.alpha != y.alpha }
		if x.type == .BigFloat { compared = !(x.value == y.value) }
		stackstate = .valid
		pop()
		pop()
		let result = compared ? BigFloat(1) : BigFloat(0)
		push(x: StackElem(val: result))
	}
	
	private func greater() {
		var compared = false
		if x.type == .Alpha { compared = x.alpha > y.alpha }
		if x.type == .BigFloat { compared = x.value > y.value }
		stackstate = .valid
		pop()
		pop()
		let result = compared ? BigFloat(1) : BigFloat(0)
		push(x: StackElem(val: result))
	}
	
	private func lower() {
		var compared = false
		if x.type == .Alpha { compared = x.alpha < y.alpha }
		if x.type == .BigFloat { compared = x.value < y.value }
		stackstate = .valid
		pop()
		pop()
		let result = compared ? BigFloat(1) : BigFloat(0)
		push(x: StackElem(val: result))
	}
	
	private func greaterequal() {
		var compared = false
		if x.type == .Alpha { compared = x.alpha >= y.alpha }
		if x.type == .BigFloat { compared = x.value >= y.value }
		stackstate = .valid
		pop()
		pop()
		let result = compared ? BigFloat(1) : BigFloat(0)
		push(x: StackElem(val: result))
	}
	
	private func lowerequal() {
		var compared = false
		if x.type == .Alpha { compared = x.alpha <= y.alpha }
		if x.type == .BigFloat { compared = x.value <= y.value }
		stackstate = .valid
		pop()
		pop()
		let result = compared ? BigFloat(1) : BigFloat(0)
		push(x: StackElem(val: result))
	}
	
	private func cmdc() {
		let pasteboard = RPNCalcPasteBoard(rpncalc: self)
		pasteboard.cmdc()
	}
	
	private func cmdv() {
		let pasteboard = RPNCalcPasteBoard(rpncalc: self)
		pasteboard.cmdv()
	}
	
	func Calculation(type : RPNCalcCmd)
	{
		switch type {
		case .negate: 	negate()
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
		case .Sto1:		store()
		case .Rcl1:		rcl()
		case .Sin:		sin()
		case .Cos:		cos()
		case .Tan:		tan()
		case .aSin:		asin()
		case .aCos:		acos()
		case .aTan:		atan()
		case .log:
			unimplemented()
		case .Inv:
			invers()
		case .lower:
			lower()
		case .greater:
			greater()
		case .equal:
			equal()
		case .unequal:
			unequal()
		case .lowerequal:
			lowerequal()
		case .greaterequal:
			greaterequal()
		}
	}
	
}

class RPNCalcPasteBoard : StackInputDelegate {
	
	var rpn : RPNCalc!
	let input = StackInput()
	init (rpncalc : RPNCalc) {
		self.rpn = rpncalc
		input.inputdelegate = self
	}
	func cmdc() {
		let pasteBoard = UIPasteboard.general
		pasteBoard.string = rpn.x.description
		rpn.stackstate = .copied
	}
	
	private func wordtype(s: String) -> StackType {
		
		if let _ = RPNCalcDict.shared.dict[s] {
			return StackType.ProgCmd
		}
		if let c = s.first {
			switch c {
			case ":": return StackType.ProgLine
			case ".","0","1","2","3","4","5","6","7","8","9":
				return StackType.BigFloat
			default:
				return StackType.Alpha
			}
		}
		return .Unknown
	}
	
	private func parseword(w: String, type: StackType) -> [InputCmd] {
		
		var ret : [InputCmd] = []
		let scalars = w.unicodeScalars
		if scalars.isEmpty { return ret }
		
		switch type {
		case .ProgCmd:
			if let cmd = RPNCalcDict.shared.dict[w] {
				rpn.Calculation(type: cmd)
				//ret.append(ProgInputCmd(rpncmd: cmd))
			}
		case .BigFloat:
			for c in scalars {
				switch c {
				case "0":
					ret.append(NumInputCmd(digit: 0))
				case "1":
					ret.append(NumInputCmd(digit: 1))
				case "2":
					ret.append(NumInputCmd(digit: 2))
				case "3":
					ret.append(NumInputCmd(digit: 3))
				case "4":
					ret.append(NumInputCmd(digit: 4))
				case "5":
					ret.append(NumInputCmd(digit: 5))
				case "6":
					ret.append(NumInputCmd(digit: 6))
				case "7":
					ret.append(NumInputCmd(digit: 7))
				case "8":
					ret.append(NumInputCmd(digit: 8))
				case "9":
					ret.append(NumInputCmd(digit: 9))
				case ".":
					ret.append(NumInputCmd(type: .punct))
				case "E":
					ret.append(NumInputCmd(type: .ee))
				case "-":
					ret.append(NumInputCmd(type: .chs))
				default:
					return ret
				}
			}
		case .Alpha:
			for c in scalars {
				ret.append(AlphaInputCmd(key: Int(c.value)))
			}
		case .BigInt:
			break
		case .ProgLine:
			break
		case .Unknown:
			break
		}
		return ret
	}
	
	func cmdv() {
		let pasteBoard = UIPasteboard.general
		guard let str = pasteBoard.string else { return }
		let words = str.components(separatedBy: " ")
		
		for w in words {
			let type = wordtype(s: w)
			let cmds = parseword(w: w,type: type)
			for cmd in cmds {
				input.SendCmd(cmd: cmd)
			}
			input.Finish()
		}
	}
	
	func InputHasFinished() {
		//print("Has Finished")
		let inputelem = input.GetStackElem()
		if inputelem.type == .ProgCmd {
			rpn.Calculation(type: inputelem.rpncmd)
		} else {
			rpn.x = inputelem
		}
		//rpn.push(x: inputelem)
		//ShowStack()
	}
	
	func InputHasStarted() {
		//print("Has Started")
		rpn.push()
	}
	
}

