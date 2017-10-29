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

enum EnterMode : Int {	case Begin, Enter, Finished, Punct }

class StackInput {
	
	var value = BigFloat(0)
	var radix = 10
	private var mode = EnterMode.Begin
	private var pos = 0
	
	func IsFinished() -> Bool {
		return mode == .Finished
	}
	
	func AppendDigit(dig : Int) {
		switch mode {
		case .Begin:
			if dig == 0 { return }
			value = BigFloat(dig)
			mode = .Enter
			pos = 0
		case .Enter:
			let valdig = BigFloat(dig)
			value = value * BigFloat(radix) + valdig
		case .Punct:
			let significand = value.significand * BigInt(radix) + BigInt(dig)
			let exponent = value.exponent - 1
			let newval = BigFloat(significand: significand, exponent: exponent)
			value = newval
			pos = pos + 1
		case .Finished:
			value = BigFloat(dig)
			mode = .Enter
		}
	}
	
	func AppendPunct() {
		mode = .Punct
		pos = 1
	}
	
	func Enter() {
		mode = .Finished
	}
	
	func Begin() {
		mode = .Begin
	}
	
	func Back() {
		
		
		switch mode {
		case .Finished:
			value = BigFloat(0)
			mode = .Enter
		case .Enter:
			let significand = value.significand / BigInt(radix)
			let exponent = value.exponent
			let newval = BigFloat(significand: significand, exponent: exponent)
			value = newval
		case .Punct:
			if pos == 1 {
				mode = .Enter
				return
			}
			let significand = value.significand / BigInt(radix)
			let exponent = value.exponent + 1
			let newval = BigFloat(significand: significand, exponent: exponent)
			value = newval
			pos = pos - 1
		case .Begin:
			value = BigFloat(0)
			mode = .Enter
		}
	}
}

