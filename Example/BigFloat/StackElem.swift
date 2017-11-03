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

struct StackElem  {
	var fix : Int = 6 //Anzahl Nachkommastellen
	var type : StackType
	
	private var _num : BigInt? = nil
	private var _value : BigFloat? = nil
	private var _alpha : String? = nil
	
	var num : BigInt {
		set { _num = newValue; type = .BigInt }
		get { if _num == nil { return BigInt(0) }
			return _num!
		}
	}
	var value : BigFloat {
		set { _value = newValue; type = .BigFloat }
		get { if _value == nil { return BigFloat(0) }
			return _value!
		}
	}
	
	var alpha : String {
		set { _alpha = newValue; type = .Alpha }
		get { if _alpha == nil { return ""}
			return _alpha!
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
	
	enum StackType {
		case BigInt, BigFloat, Unknown, Alpha
	}
	
	func FormatStr(maxrows: Int, rowlen: Int) -> (String,rows: Int) {
		switch type {
		case .Alpha:
			return (alpha,1)
		case .BigFloat:
			return (value.ExponentialString(base: 10, fix: self.fix),1)
		case .BigInt:
			return (String(num),1)
		case .Unknown:
			return ("- / -",1)
		}
	}
}

extension StackElem : CustomStringConvertible {
	public var description: String {
		switch type {
		case .BigInt:
			return String(num)
		case .BigFloat:
			return String(describing: value)
		case .Alpha:
			return alpha
		case .Unknown:
			return "Unknown"
		}
	}
}



