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
	var type : StackType
	
	private var _num : BigInt? = nil
	private var _value : BigFloat? = nil
	
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
	
	enum StackType {
		case BigInt, BigFloat, Unknown
	}
	
	func FormatStr(maxrows: Int, rowlen: Int) -> (String,rows: Int) {
		let s = String(describing: self)
		return (s,1)
	}
	
	
}

extension StackElem : CustomStringConvertible {
	public var description: String {
		switch type {
		case .BigInt:
			return String(num)
		case .BigFloat:
			return String(describing: value)
		case .Unknown:
			return "Unknown"
		}
	}
}



