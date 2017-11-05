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
		let temp = elem.value
		let tstr = temp.ExponentialString(base: 10, fix: 10)
		print("sto:",key,tstr)
	}
	
	func Recall(key: String) -> StackElem {
	
		if let elem = dict[key] {
			let temp = elem.value
			let tstr = temp.ExponentialString(base: 10, fix: 10)
			print("rcl:",key,tstr)
			return elem
		}
		return StackElem()
	}
	
	private init() {
	}
}

/*
class ForthExecuter {

	var rpn : RPNCalc!
	init(rpn : RPNCalc) {
		self.rpn = rpn
	}
	
	func Execute(prog : ProgLine)
	{
		var lasttype = ProgInputType.enter
		
		var input = StackInput()
		for c in prog.cmdstack {
			switch c.type {
				
			case .rpn:
				Calculation(type: c.rpncmd!)
			case .digit:
				if c.type != lasttype { input = NumberInput() }
				input.SendCmd(cmd: c.numcmd)
			case .char:
				<#code#>
			case .enter:
				<#code#>
			case .ifcond:
				<#code#>
			case .thencond:
				<#code#>
			case .elsecond:
				<#code#>
			}
			
		}
	}
}
*/
