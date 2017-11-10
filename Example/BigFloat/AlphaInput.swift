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


enum AlphaInputType {
	case alpha
}

class AlphaInputCmd : InputCmd {
	private (set) var type :  AlphaInputType
	private (set) var key : Int = 0
	
	init(key : Int) {
		self.type = .alpha
		self.key = key
		super.init(inputtype: .alpha)

	}
	init (type : AlphaInputType) {
		self.type = type
		super.init(inputtype: .alpha)

	}
	
	override var description : String {
		switch type {
		
		case .alpha:
			let c = Character(UnicodeScalar(self.key)!)
			return String(c)
		}
	}
}

class AlphaInput : StackInputProt {
	

	var cmdstack : [AlphaInputCmd] = []
	
	func GetStackElem() -> StackElem {
		return StackElem(alpha: GetInputValue())
	}
	func GetInputString() -> String {
		return "'" + GetInputValue() + "'"
	}
	
	private func GetInputValue() -> String {
		var ans = ""
		for c in cmdstack {
			switch c.type {
			case .alpha:
				let char = Character(UnicodeScalar(c.key)!)
				ans = ans + String(char)
			}
		}
		return ans
	}
	
	func SendCmd(cmd: InputCmd) {
		if let acmd = cmd as? AlphaInputCmd {
			cmdstack.append(acmd)
		} else {
			assert(false)
		}
	}
	
	func Send(cmd: AlphaInputCmd) {
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




