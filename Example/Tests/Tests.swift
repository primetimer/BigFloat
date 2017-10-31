import UIKit
import XCTest
import BigInt
import BigFloat

class Tests: XCTestCase {
	
	let epsilon : BigFloat = BigFloat(Double(1E-100))
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBasic() {
        // This is an example of a functional test case.
		var k = BigFloat(1)
		for _ in 1...10 {
			k = k + BigFloat(1)
			let kinv = BigFloat(3) / k
			let kstr = kinv.ExponentialString(base: 10, fix: 10)
			print(kstr)
		}
		let x = BigFloat(1.23456)
		let ten = BigFloat(10.0)
		let y = x / ten
		let z = y * ten
		let d = x > z ? x - z : z - x
		XCTAssert(d < epsilon,"Ask")

    }
	
	private func printNum(_ val: BigFloat, _ info: String = "") {
		let s = val.ExponentialString(base: 10, fix: 20)
		print(info, ":", s)
	}

	func testRandom() {
		for _ in 1...100 {
		let x = arc4random()
		let bx = BigFloat(-Double(x))*BigFloat(Double(x))*BigFloat(Double(x))
		//printNum(bx,"bx")
		let bxinv = BigFloat(1) / bx
		//printNum(bxinv,"bxinv")
		let bbx = BigFloat(1) / bxinv
		//printNum(bbx,"bbx")
			let d = BigFloat.abs(bbx - BigFloat(bx))
		//printNum(d,"d")

		XCTAssert(d >= BigFloat(0))
		XCTAssert(d <= epsilon)
		}
	}
	
	func testSqrt() {
		let sqrt2 = BigFloat.sqrt(x: BigFloat(2))
		let s = sqrt2.ExponentialString(base: 10, fix: 40)
		let scomp = "1.4142135623730950488016887242096980785697E0"
		XCTAssert(s == scomp)
		var k = BigFloat(3)
		for _ in 1...10 {
			k = k * BigFloat(100000000) + BigFloat(3)
			let r = BigFloat.sqrt(x: k)
			let r2 = r * r
			let d = BigFloat.abs(k - r2)
			//let strk = k.ExponentialString(base: 10,fix: 10)
			//let strd = d.ExponentialString(base: 10, fix: 10)
			//print ("Sqrt:", strk, " ", strd)
			XCTAssert(d < epsilon)
		}
	}
	
	func testExp() {
		let bige = BigFloat.exp(x: BigFloat(1))
		let s = bige.ExponentialString(base: 10, fix: 40)
		let scomp = "2.7182818284590452353602874713526624977572E0"
		XCTAssert(s == scomp)
		var epow = bige
		
		for i in 2...20 {
			epow = epow * bige
			let ecomp = BigFloat.exp(x: BigFloat(i))
			let d = BigFloat.abs(ecomp - epow)
			let stre = ecomp.ExponentialString(base: 10, fix: 40)
			let strd = d.ExponentialString(base: 10, fix: 40)
			print (i," ", stre, " ", strd)
			XCTAssert(d < epsilon )
		}
		
		epow = BigFloat(1)
		for i in 1...20 {
			epow = epow / bige
			let ecomp = BigFloat.exp(x: BigFloat(-i))
			let d = BigFloat.abs(ecomp - epow)
			let stre = ecomp.ExponentialString(base: 10, fix: 40)
			let strd = d.ExponentialString(base: 10, fix: 40)
			print (i," ", stre, " ", strd)
			XCTAssert(d < epsilon, "error : Exp" + String(-i) )
		}
				//print(s)
	}

    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
