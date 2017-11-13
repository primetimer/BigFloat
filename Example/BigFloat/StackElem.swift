//
//  StackElem.swift
//  BigFloat_Example
//
//  Created by Stephan Jancar on 28.10.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import BigInt
import BigFloat

enum StackType {
	case BigInt, BigFloat, Unknown, Alpha, ProgLine, ProgCmd
}

struct StackElem  {
	var fix : Int = 6 //Anzahl Nachkommastellen
	var type : StackType
	
	private var _num : BigInt? = nil
	private var _value : BigFloat? = nil
	private var _alpha : String? = nil
	private var _progline : ProgLine? = nil
	private var _progcmd : RPNCalcCmd? = nil
	
	var num : BigInt {
		set { _num = newValue; type = .BigInt }
		get { if _num == nil { return BigInt(0) }
			return _num!
		}
	}
	var value : BigFloat {
		set { _value = newValue; type = .BigFloat }
		get { if _value == nil {
				if _alpha != nil {
					let storedelem = ForthStorage.shared.Recall(key: _alpha!)
					return storedelem.value
				}
				return BigFloat(0)
			}
			return _value!
		}
	}
	
	var alpha : String {
		set { _alpha = newValue; type = .Alpha }
		get { if _alpha == nil { return ""}
			return _alpha!
		}
	}
	var rpncmd: RPNCalcCmd {
		set { _progcmd = newValue; type = .ProgCmd }
		get {
			if _progcmd == nil { return .Undefined }
			return _progcmd!
		}
	}
	var prog : ProgLine {
		set { _progline = newValue; type = .ProgLine }
		get {
			if _progline == nil {
				return ProgLine()
			}
			return _progline!
		}
	}
	
	init() {
		type = .Unknown
	}
	init(num : BigInt) {
		type = .BigInt
		_num = num
	}
	init(val : BigFloat) {
		type = .BigFloat
		_value = val
	}
	
	init(alpha : String) {
		type = .Alpha
		_alpha = alpha
	}
	
	init(progline : ProgLine) {
		type = .ProgLine
		_progline = progline
	}
	
	
	
	func FormatStr(base: Int ,maxrows: Int, rowlen: Int) -> (String,rows: Int) {
		var ans = ""
		switch type {
		case .ProgCmd:
			ans = RPNCalcDict.shared.String(cmd: rpncmd)
		case .ProgLine:
			ans = ":" + String(describing: prog) + ";"
		case .Alpha:
			ans = alpha
		case .BigFloat:
			ans = value.autoString(base)
		case .BigInt:
			ans = String(num)
		case .Unknown:
			ans = "- / -"
		}
		let rows = ans.count / rowlen
		return (ans,rows)
	}
}

extension StackElem : CustomStringConvertible {
	public var description: String {
		switch type {
		case .ProgCmd:
			return String(describing: rpncmd)
		case .BigInt:
			return String(num)
		case .BigFloat:
			return String(describing: value)
		case .Alpha:
			return alpha
		case .ProgLine:
			return String(describing: prog)
		case .Unknown:
			return "Unknown"
		}
	}
}



