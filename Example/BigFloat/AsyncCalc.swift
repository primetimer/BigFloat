//
//  AsyncCalc.swift
//  PFactors_Example
//
//  Created by Stephan Jancar on 22.10.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import BigInt
import PrimeFactors
import BigFloat

protocol ProtShowResult {
	func ShowCalcResult()
}

class AsyncCalc: Operation, CalcCancelProt {
	func IsCancelled() -> Bool {
		return isCancelled
	}
	
	private var type : CalcType!
	private var rpn : RPNCalc!
	var resultdelegate : ProtShowResult? = nil
	
	override var isAsynchronous: Bool {
		get{
			return true
		}
	}
	private var _executing: Bool = false
	override var isExecuting:Bool {
		get { return _executing }
		set {
			willChangeValue(forKey: "isExecuting")
			_executing = newValue
			didChangeValue(forKey: "isExecuting")
			if _cancelled == true {
				self.isFinished = true
			}
		}
	}
	private var _finished: Bool = false
	override var isFinished:Bool {
		get { return _finished }
		set {
			willChangeValue(forKey: "isFinished")
			_finished = newValue
			didChangeValue(forKey: "isFinished")
		}
	}
	
	private var _cancelled: Bool = false
	override var isCancelled: Bool {
		get { return _cancelled }
		set {
			willChangeValue(forKey: "isCancelled")
			_cancelled = newValue
			didChangeValue(forKey: "isCancelled")
		}
	}
	
	init(rpn: RPNCalc, type : CalcType) {
		self.rpn = rpn
		self.type = type
	}
	
	override func start() {
		super.start()
		self.isExecuting = true
		rpn.canceldelegate = self
		rpn.Calculation(type: self.type)
		if !isCancelled {
			OperationQueue.main.addOperation {
				self.resultdelegate?.ShowCalcResult()
			}
		} else {
			print("was cancelled")
		}
	
	}
	
	override func cancel() {
		super.cancel()
		isCancelled = true
		if isExecuting {
			isExecuting = false
			isFinished = true
		}
	}
	
	override func main() {
		if isCancelled {
			self.isExecuting = false
			self.isFinished = true
			return
		}
	}
}
