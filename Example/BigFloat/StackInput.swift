//
//  StackInput.swift
//  BigFloat_Example
//
//  Created by Stephan Jancar on 28.10.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import BigInt
import BigFloat

enum EnterMode : Int {	case Begin, Enter, Finished, Punct, EE , Alpha }
enum StackInputCmd : Int {
	case n0
	case n1, n2, n3, n4, n5, n6, n7, n8, n9
	case punct
	case ee
	case chs
	case unknown
	case enter
	case back
	case alpha
}

extension StackInputCmd {
static func ByDigit(dig : Int) -> StackInputCmd {
	switch dig {
	case 0: return StackInputCmd.n0
	case 1: return StackInputCmd.n1
	case 2: return StackInputCmd.n2
	case 3: return StackInputCmd.n3
	case 4: return StackInputCmd.n4
	case 5: return StackInputCmd.n5
	case 6: return StackInputCmd.n6
	case 7: return StackInputCmd.n7
	case 8: return StackInputCmd.n8
	case 9: return StackInputCmd.n9
	default: return StackInputCmd.unknown
	}
	}
}

class StackInput {
	var radix = 10
	var cmdstack : [StackInputCmd] = []
	private var mode = EnterMode.Begin
	private var pos = 0
	
	var inputelem : StackElem {
		get {
			if mode == .Alpha {
				return StackElem(alpha: _alphastring)
			}
			return StackElem(val: inputvalue)
		}
	}
	
	var inputvalue : BigFloat {
		get {
			var radixpow = BigFloat(radix)
			var temp = BigFloat(0)
			var ee : Int = 0
			var sign : Int = 1
			var eesign : Int = 1
			var state = EnterMode.Begin
			for cmd in cmdstack {
				switch cmd {
				case .enter, .alpha:
					return temp
				case .chs:
					if state != EnterMode.EE {
						sign = -sign
					} else {
						eesign = -eesign
					}
				case .punct:
					state = EnterMode.Punct
				case .n0, .n1, .n2, .n3, .n4 ,.n5, .n6 ,.n7, .n8 ,.n9:
					switch state {
					case .Punct:
						temp = temp + BigFloat(cmd.rawValue) / radixpow
						radixpow = radixpow * BigFloat(radix)
					case .EE:
						ee = ee * radix + cmd.rawValue
					case .Begin, .Enter, .Finished:
						temp = temp * BigFloat(radix) + BigFloat(cmd.rawValue)
					case .Alpha:	//never come here
						break
					}
				case .ee:
					state = EnterMode.EE
				case .unknown:
					break
				case .back:
					break
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
	}
	
	private var _alphastring = ""
	var inputstring : String {
		get {
			if mode == .Alpha { return "'" + _alphastring + "'" }
			var str = ""
			var eestr = ""
			var ee : Int = 0
			var sign = 1
			var eesign = 1
			var state = EnterMode.Begin
			for cmd in cmdstack {
				switch cmd {
				case .enter, .back, .alpha : break
				case .chs:
					if state == .EE {
						eesign = -eesign
					} else {
						sign = -sign
					}
				case .punct:
					state = EnterMode.Punct
					str = str + "."
				case .n0, .n1, .n2, .n3, .n4 ,.n5, .n6 ,.n7, .n8 ,.n9:
					if state == .EE {
						ee = ee * radix + cmd.rawValue
					} else {
						str = str + String(cmd.rawValue)
					}
				case .ee:
					state = EnterMode.EE
					str = str + "E"
				case .unknown:
					break
				}
			}
			if ee != 0 {
				eestr = String(ee*eesign)
			}
			if sign < 0 { str = "-" + str }
			let ans = str + eestr
			if ans == "" { return "0" }
			return ans
		}
	}

	func IsFinished() -> Bool {
		return mode == .Finished
	}
	func Finish() {
		mode = .Finished
	}

	func AppendAlpha(keystr: String) {
		if mode == .Finished { _alphastring = "" }
		mode = .Alpha
		_alphastring = _alphastring + String(keystr)
	}
	
	func AppendCmd(cmd: StackInputCmd) {
		if mode == .Finished { cmdstack.removeAll() }
		switch cmd {
		case .punct:
			if !cmdstack.contains(.punct) { cmdstack.append(.punct) }
			mode = .Punct
		case .enter, .alpha:
			mode = .Finished
		case .back:
			Back()
		case .chs:
			cmdstack.append(cmd)
		case .ee:
			cmdstack.append(cmd)
			mode = .EE
		case .n0, .n1, .n2, .n3, .n4, .n5, .n6,. n7, .n8, .n9:
			cmdstack.append(cmd)
			mode = .Enter
		case .unknown:
			break
		}
	}
	
	func Begin() {
		mode = .Begin
		cmdstack.removeAll()
		_alphastring = ""
	}
	
	private func Back() {
		if mode == .Alpha {
			if _alphastring.count > 0 {
				_alphastring.removeLast()
			}
			return
		}
		if cmdstack.count > 0 {
			cmdstack.removeLast()
		}
	}
}

