//
//  RPNInfo.swift
//  PFactors_Example
//
//  Created by Stephan Jancar on 23.10.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

class InfoView : UITextView {
	
	init() {
		super.init(frame: .zero, textContainer: nil)
		self.font = UIFont(name: "Arial", size: 16)
		self.isUserInteractionEnabled = false
	}
	required init?(coder aDecoder: NSCoder) {	fatalError("init(coder:) has not been implemented") }
	
	//No Editing allowed
	override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
		self.resignFirstResponder()
		return false
	}
	override func shouldChangeText(in range: UITextRange, replacementText text: String) -> Bool {
		self.resignFirstResponder()
		return false
	}
	
	func ShowText(type : RPNCalcCmd) {
		var t = ""
		switch type {
		case .Undefined: ShowNumInfo()
		case .negate:	t = "Change Sign of number"
		case .LastX:	t = "Restore X-Register after operation"
		case .Plus: 	t = "Adds the x and y register."
		case .Minus: 	t = "Subtrats x from y. Negative Numbers are not allowed."
		case .Prod,.Prod2:		t = "Product of x and y. Products greater than 100 digits are not allowed."
		case .Divide,.Divide2:   t = "Divides y by x."
		case .PNext:	t = "Next prime number."
		case .PPrev: 	t = "Previous prime number."
		case .Rnd: 		t = "Random Number up to x. If x is zero a random number up 10^10 is calculated."
		//case .Twin:  	t = "Next twin-prime in x and y register."
		//case .SoG: 		t = "Next sophie germain prime. y-Register is 2p+1."
		//case .Rho: 		t = "Calculates a factor (not neccesarilly a prime factor) of x with Pollards rho methos. Error is displayed if no factor was found. Consider one of the other factorization methods."
		//case .Squfof:	t = "Calculates a factor (not neccesarilly a prime factor) of x with Shanks method of continued fraction. Error is displayed if no factor was found. Consider one of the other factorization methods. You can stop the calculation with the escape button."
		//case .Lehman: 	t = "Calculates a factor of x with Lehmans method. This is the slowest factorization method, but a result is guaranteed. You can stop the calculation it with the escape button."
		//case .Factor, .Factors:	t = "Not yet implemented"
		case .Swap:		t = "Swaps the content of x and y register"
		case .Pop:		t = "Drops the content of x register"
		case .Pow:		t = "Power of y by x. A result in a number essentially greater than a number with one hundred digits result in an overflow message."
		case .PowMod:	t = "Power of z^y modulo x."
		case .Mod:		t = "Remainder of y divided by x."
		case .gcd:		t = "Greatest common divisor of x and y."
		case .sqrt:		t = "Square Root. Greatest number r with r*r <= x."
		case .crt:		t = "Cubic Root. Greatest number r with r^3 <= x."
		case .Sto1: 	t = "Enter a variable name in x and store the current value of y."
		case .Rcl1:		t = "Enter a variable name in x and recall the previous stored value"
		case .CmdC:		t = "Copies the x-Register in the Clipboard for use in other applications."
		case .CmdV:		t = "Pastes the content of the clipboard into the x Register"
		case .Hash:		t = "Hash Value of x"
		case .Mersenne: t = "Mersenne Number 2^x - 1"
		case .Square:   t = "Square of x"
		case .Cube:		t = "Cube of x"
		case .TenPow:	t = "One with x trailing zeros"
		case .Sin:		t = "Sinus (in radian)"
		case .Cos:		t = "Cosinus (in radioan)"
		case .Tan:		t = "Tangens (in radian)"
			
		//case .Sexy:     t = "Sexy Prime ( the next prime p, with p + 6  prime )"
		//case .Cousin:   t = "Cousin Prime ( the next prime p, with p + 4  prime )"
			case .pi:		t = "pi"
			case .ln2:	t = "ln 2"
		case .sqrt2: t = "Square root 2"
		case .exp1:  t = "e"
		case .exp:		t = "Exponential function with base e"
		case .ln:
			t = "Natural logarithm"
		case .aSin:
			t = "Arcus Sinus (in radian)"
		case .aCos:
			t = "Arcus Cosinus (in radian)"
		case .aTan:
			t = "Arcus Tangens (in radian)"
		case .log:
			t = "Logarithmus (base 10)"
		case .Inv:
			t = "Reciproke value"
		case .lower:
			t = "One if  x < y else Zero"
		case .greater:
			t = "One if  x > y else Zero"
		case .equal:
			t = "One if  x equals y else Zero"
		case .unequal,.unequal2:
			t = "One if  x does not equal y else Zero"
		case .lowerequal:
			t = "One if  x loewer equal y else Zero"
		case .greaterequal:
			t = "One if  x greater equal y else Zero"
		}
		self.text = t
	}
	
	func ShiftInfo() {
		let t = "With the Shift button you enable a second keyboard wird more calculation functions."
		self.text = t
	}
	
	func ShowClearInfo() {
		let t1 = "CLR clears all registers"
		self.text = t1
	}
	
	func ShowEscapeInfo() {
		let t1 = "Undo - with Undo you can undo the last operations"
		let t2 = "ESC - During lengthy operations the undo button is replaced by the escape button, which stops the current operation"
		self.text = t1 + "\n" + t2
	}
	
	func ShowNumInfo() {
		let t1 = "Enter the the digits of a number. Seperate each number with the enter-key. After entering the numbers choose the button for the desired calculation."
		self.text = t1
	}
	
	func ShowGeneral() {
		let t1 = "Reverse Polish Calculator for Big Integer Numbers up to a googol (a number with one hundred digits) and beyond up to 2^1024."
		let t2 = "In reverse polish notation you enter the operands seperated by ENTER followed by the operation."
		let t3 = "To get Information about the possible Operations press the corresponding button"
		self.text = t1 + "\n" + t2 + "\n" + t3
	}
	
}
