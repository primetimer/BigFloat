//
//  RPNCalcCmd.swift
//  BigFloat_Example
//
//  Created by Stephan Jancar on 08.11.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation


class RPNCalcDict {
	
	static let shared = RPNCalcDict()
	
	var dict : Dictionary<String,RPNCalcCmd> = [:]
	
	private init() {
		dict["Undefined"] = .Undefined
		dict["π"] = .pi
		dict["+"] = .Plus
		dict["-"] = .Minus
		dict["*"] = .Prod
		dict["/"] = .Divide
		dict["%"] = .Mod
		dict["LastX"] = .LastX
		dict["x^2"] = .Square
		dict["x²"] = .Square
		dict["x^3"] = .Cube
		dict["x³"] = .Cube
		dict["10^x"] = .TenPow
		dict["1/x"] = .Inv
		dict["sin"] = .Sin
		dict["2^x-1"] = .Mersenne
		dict["cos"] = .Cos
		dict["tan"] = .Tan
		dict["asin"] = .aSin
		dict["acos"] = .aCos
		dict["atan"] = .aTan
		dict["x<>y"] = .Swap
		dict["↓"] = .Pop
		dict["y^x"] = .Pow
		dict["exp"] = .exp
		dict["ln"] = .ln
		dict["log"] = .log
		dict["√"] = .sqrt
		dict["∛"] = .crt
		dict["STO"] = .Sto1
		dict["!"] = .Sto1
		dict["RCL"] = .Rcl1
		dict["?"] = .Rcl1
		dict["⌘C"] = .CmdC
		dict["⌘V"] = .CmdV
		dict["<"] = .lower
		dict["<="] = .lowerequal
		dict[">"] = .greater
		dict[">="] = .greaterequal
		dict["="] = .equal
		dict["!="] = .unequal
	}
	
	func String(cmd: RPNCalcCmd) -> String {
		for key in dict {
			if key.value == cmd {
				return key.key
			}
		}
		assert(false)
		return ""
	}
}


enum RPNCalcCmd : Int, CustomStringConvertible {
	case Undefined,Plus,Minus,Prod,Divide, LastX, Mersenne, Square, Cube, TenPow, Inv, negate
	case Sin, Cos, Tan, aSin, aCos, aTan
	case PNext, PPrev
	case Swap, Pop, Pow, PowMod, exp, ln, pi, log
	case Mod, gcd, sqrt, crt, Hash,Rnd
	case Sto1, Rcl1, CmdC, CmdV
	case lower,greater,equal,unequal,lowerequal,greaterequal
	
	var description : String {
		return RPNCalcDict.shared.String(cmd: self)
	}
}

