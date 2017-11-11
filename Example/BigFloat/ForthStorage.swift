//
//  ForthStorage.swift
//  BigFloat_Example
//
//  Created by Stephan Jancar on 03.11.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation

class ForthStorage {
	
	static var shared = ForthStorage()
	
	var dict : Dictionary<String,StackElem> = [:]
	
	func Store(key : String, elem: StackElem) {
		dict[key] = elem
	}
	
	func Recall(key: String) -> StackElem {
		
		if let elem = dict[key] {
			return elem
		}
		return StackElem()
	}
	
	private init() {
	}
}

class ForthExecuter : StackInputDelegate {
	
	var rpn : RPNCalc!
	var input = StackInput()
	
	func InputHasStarted() {
		//print("Has Started")
		rpn.push()
		print(rpn)
	}
	
	func InputHasFinished() {
		//print("prog input Has Finished")
		let inputelem = input.GetStackElem()
		rpn.x = inputelem
		print(rpn)
	}
	
	init(rpn : RPNCalc) {
		self.rpn = rpn
		input.inputdelegate = self
	}
	
	func Execute()
	{
		let cmdstack = rpn.x.prog.cmdstack
		let lastx = rpn.x
		print("Execute", rpn.description)
		input.Finish()
		rpn.pop()
		print("Popo", rpn.description)
		
		if cmdstack.isEmpty { return }
		for c in cmdstack {
			print("Cmd:" + c.description + rpn.description)
			switch c.type {
			case .rpn:
				print("Prefinish", rpn.description)
				input.Finish()
				print("RpnCmd:", rpn.description)
				rpn.Calculation(type: c.rpncmd!)
			case .digit:
				input.SendCmd(cmd: c.numcmd!)
			case .char:
				input.SendCmd(cmd: c.alpcmd!)
			case .enter:
				if input.IsFinished() {
					rpn.push()
				}
				input.Finish()
			case .ifcond:
				print("Unimplemented")
				
			case .thencond:
				print("Unimplemented")
			case .elsecond:
				print("Unimplemented")
				
			}
		}
		rpn.lastx = lastx
	}
}


