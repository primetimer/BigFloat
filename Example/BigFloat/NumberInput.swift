//
//  NumberInput.swift
//  BigFloat_Example
//
//  Created by Stephan Jancar on 04.11.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import BigInt
import BigFloat

enum NumInputType {
	case punct
	case ee
	case chs
	case digit
}

class NumInputCmd : InputCmd {
	private (set) var type :  NumInputType
	private (set) var key : Int = 0
	
	init(digit : Int) {
		self.type = .digit
		self.key = digit
		super.init(inputtype: .number)
		
	}
	init (type : NumInputType) {
		self.type = type
		super.init(inputtype: .number)
	}
	
	override var description : String {
		switch type {
		case .punct:
			return "."
		case .ee:
			return "EE"
		case .chs:
			return "+/-"
		case .digit:
			return key.AsciiCode
		}
	}
}


class NumberInput : StackInputProt {
	func SetBase(base: Int) {
		radix = base
	}
	
	
	private var radix = 10
	var cmdstack : [NumInputCmd] = []
	
	init(radix : Int = 10) {
		self.radix = radix
	}
	func GetStackElem() -> StackElem {
		return StackElem(val: InputValue())
	}
	func GetInputString() -> String {
		var (str,ee,isee,sign,eesign) = ("",0,false,1,1)
		for c in cmdstack {
			switch c.type {
			case .chs:
				if isee { eesign = -eesign } else {	sign = -sign }
			case .punct:
				str = str + "."
			case .digit:
				if isee { ee = ee * radix + c.key }
				else { str = str + c.key.AsciiCode }
			case .ee:
				isee = true
				str = str + (radix == 10 ? " e" : " x")
			}
		}
		let eestr = isee ? (ee*eesign).String(withbase: radix) : ""
		if sign < 0 { str = "-" + str }
		let ans = str + eestr
		if ans == "" { return "0" }
		return ans
	}
	
	private func InputValue() -> BigFloat {
		var (radixpow,temp) = (BigFloat(radix), BigFloat(0))
		var (ee,isee,sign,eesign,ispunct) = (0,false,1,1,false)
		for c in cmdstack {
			switch c.type {
			case .chs:
				if isee { eesign = -eesign } else {	sign = -sign }
			case .punct:
				ispunct = true
			case .digit:
				if isee {
					ee = ee * radix + c.key
				} else if ispunct {
					temp = temp + BigFloat(c.key) / radixpow
					radixpow = radixpow * BigFloat(radix)
				} else {
					temp = temp * BigFloat(radix) + BigFloat(c.key)
				}
			case .ee:
				isee = true
			}
		}
		if ee * eesign > 0 {
			radixpow = BigFloat(1)
			for _ in 0 ..< ee {
				radixpow = radixpow * BigFloat(radix)
			}
			temp = temp * radixpow
		}
		if ee*eesign < 0 {
			radixpow = BigFloat(1)
			for _ in 0 ..< ee {
				radixpow = radixpow * BigFloat(radix)
			}
			temp = temp / radixpow
		}
		_ = temp.truncate(bits: temp.precision)
		temp = temp * BigFloat(sign)
		return temp
	}
	
	func SendCmd(cmd: InputCmd) {
		if let numcmd = cmd as? NumInputCmd {
			AppendCmd(cmd: numcmd)
		}
	}
	private func AppendCmd(cmd: NumInputCmd) {
		switch cmd.type {
		case .punct:
			for c in cmdstack {
				if c.type == .punct { return }
			}
			cmdstack.append(cmd)
		case .chs:
			cmdstack.append(cmd)
		case .ee:
			cmdstack.append(cmd)
		case .digit:
			cmdstack.append(cmd)
		}
	}
	
	func Begin() {
		cmdstack.removeAll()
	}
	func Back() {
		if cmdstack.count > 0 {
			cmdstack.removeLast()
		}
	}
}




