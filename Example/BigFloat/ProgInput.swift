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


enum ProgInputType {
	case rpn
	case digit
	case char
	case enter
	case ifcond
	case thencond
	case elsecond
	
	var description : String {
		switch self {
		case .rpn: 		return "rpn"
		case .ifcond:	return "if"
		case .thencond:		return "then"
		case .elsecond: 	return "else"
		case .digit:		return "digit"
		case .char:			return "alpha"
		case .enter:		return "enter"
		}
	}
}

typealias ProgLine = ProgInput

class ProgInputCmd : InputCmd {
	private (set) var type :  ProgInputType
	private (set) var rpncmd :  RPNCalcCmd? = nil
	private (set) var numcmd : NumInputCmd? = nil
	private (set) var alpcmd : AlphaInputCmd? = nil
	init(type : ProgInputType) {
		self.type = type
		super.init(inputtype: .prog)
	}
	init(rpncmd : RPNCalcCmd) {
		self.type = .rpn
		self.rpncmd = rpncmd
		super.init(inputtype: .prog)
	}
	init(numcmd : NumInputCmd) {
		self.type = .digit
		self.numcmd = numcmd
		super.init(inputtype: .prog)
	}
	init(alpcmd : AlphaInputCmd) {
		self.type = .char
		self.alpcmd = alpcmd
		super.init(inputtype: .prog)
	}
	
	init() {
		self.type = .rpn
		super.init(inputtype: .prog)
	}
	
	var description : String {
		switch self.type {
		case .rpn:
				return rpncmd!.description
		case .ifcond, .thencond, .elsecond :
				return self.type.description
		case .digit:
				return self.numcmd!.description
		case .char:
				return self.alpcmd!.description
		case .enter:
				return "⏎"
		}
	}
}

class ProgInput : StackInputProt {
	var cmdstack : [ProgInputCmd] = []
	
	func GetStackElem() -> StackElem {
		return StackElem(alpha: GetInputValue())
	}
	func GetInputString() -> String {
		return "'" + GetInputValue() + "'"
	}
	
	private func GetInputValue() -> String {
		var ans = ""
		var lasttype = ProgInputType.enter
		for c in cmdstack {
			if c.type != lasttype { ans = ans + " " }
			ans = ans + c.description
			lasttype = c.type
		}
		return ans
	}
	
	func SendCmd(cmd: InputCmd) {
		if let acmd = cmd as? ProgInputCmd {
			cmdstack.append(acmd)
		} else {
			assert(false)
		}
	}
	
	func Send(cmd: ProgInputCmd) {
		cmdstack.append(cmd)
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




