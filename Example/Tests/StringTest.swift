//
//  StringTest.swift
//  BigFloat_Tests
//
//  Created by Stephan Jancar on 11.11.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
import BigFloat


class StringTests: XCTestCase {
	
	override func setUp() {
		super.setUp()
	}
	
	override func tearDown() {
		super.tearDown()
	}
	
	func testString() {

		do {
			let x = BigFloat(16)
			let xstr = x.asString(10, fix: 5)
			XCTAssert(xstr == "16.00000")
		}
		do {
			let x = BigFloat(Double(16000))
			let xstr = x.asString(10, fix: 5)
			XCTAssert(xstr == "16000.00000")
		}
		do {
			let d = Double(0.001234)
			let x = BigFloat(d)
			let dstr = String(d)
			let xstr = x.asString(10, fix: 5)
			XCTAssert(xstr == "0.00123")
			
		}
		do {
			let d = Double(0.0000000000000001234)
			let x = BigFloat(d)
			//let dstr = String(d)
			let xstr = x.asString(10, fix: -5)
			XCTAssert(xstr == "0.00000000000000012340")
			
		}
	}
	
	func testExpString() {
		
		do {
			let x = BigFloat(16)
			let xstr = x.expString(fix: 3)
			XCTAssert(xstr == "1.60E1")
		}
		do {
			let x = BigFloat(Double(16000))
			let xstr = x.expString(fix: 5)
			XCTAssert(xstr == "1.6000E4")
		}
		do {
			let d = Double(0.001234)
			let x = BigFloat(d)
			let dstr = String(d)
			let xstr = x.expString(fix: 5)
			XCTAssert(xstr == "1.2340E-3")
			
		}
		do {
			let d = Double(0.0000000000000001234)
			let x = BigFloat(d)
			//let dstr = String(d)
			let xstr =  x.expString(fix: 5)
			XCTAssert(xstr == "1.2340E-16")
			
		}
		do {
			let d = Double(1234000000000001)
			let x = BigFloat(d)
			//let dstr = String(d)
			let xstr =  x.expString(fix: 5)
			XCTAssert(xstr == "1.2340E15")
			
		}
		do {
			let d = Double(0.000000000000000123499999999)
			let x = BigFloat(d)
			//let dstr = String(d)
			let xstr =  x.expString(fix: 5)
			XCTAssert(xstr == "1.2350E-16")
			
		}
	}
}
