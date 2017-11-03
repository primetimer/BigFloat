//
//  ForthStorage.swift
//  BigFloat_Example
//
//  Created by Stephan Jancar on 03.11.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation

class ForthStorage {
	
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
	
	init() {
	}
}
