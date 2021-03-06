import UIKit
import XCTest
import BigInt
import BigFloat

class Tests: XCTestCase {
	
	let epsilon : BigFloat = BigFloat(Double(1E-100))
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
	
	func testLn() {
		
		do {
			let x = BigFloat(2)
			let ln2 = BigFloat.ln(x: x)
			let ln2str = ln2.expString(fix: 40)
			print("ln2:",ln2str)
			let ref = "6.9314718055994530941723212145817656807550E-1"
			XCTAssert(ln2str == ref,"ln : Pass ln2")
		}
		
		do {
			let e = BigFloat.exp(x: BigFloat(1))
			var x = BigFloat(1)
			for k in 0...32 {
				let lnx = BigFloat.ln(x: x)
				//let lnxstr = lnx.expString( 10, fix: 40)
				//print(String(k), "ln(e^k):",lnxstr)
				x = x * e
				let ref = BigFloat(k)
				let d = BigFloat.abs(lnx-ref)
				XCTAssert(d < epsilon)
			}
			
			x = BigFloat(1)
			for k in 0...40 {
				let lnx = BigFloat.ln(x: x)
				//let lnxstr = lnx.expString( 10, fix: 40)
				//print(String(k), "ln(e^-k):",lnxstr)
				x = x / e
				let ref = BigFloat(-k)
				let d = BigFloat.abs(lnx-ref)
				XCTAssert(d < epsilon)
			}
		}
	}
	
	func testHypot() {
		let x = BigFloat(1)
		let y = BigFloat(1)
		let h = BigFloat.hypot(x: x, y)
		//let hstr = h.expString( 10, fix: 40)
		let r2 = BigFloat.sqrt(x: BigFloat(2))
		let d = BigFloat.abs(h - r2)
		XCTAssert(d < epsilon)
		let dstr = d.expString( 10, fix: 40)
		print(dstr)
	}
	
	func testPiAGMSalaminBrent() {
		let half = BigFloat(1) / BigFloat(2)
		var a = BigFloat(1)
		var b = BigFloat.sqrt(x: half)
		var t = half*half
		var p = BigFloat(0)
		var twopow = BigFloat(1)
		var partstr = ""
		for k in 0...5 {
			let a1 = (a+b)*half
			let b1 = BigFloat.sqrt(x: a*b)
			let astr = a1.expString( 10, fix: 40)
			let bstr = b1.expString( 10, fix: 40)
			
			let d = (a-a1)*(a-a1)*twopow
			t = t - d
			let tstr = t.expString( 10, fix: 40)
			p = (a1+b1)*(a1+b1) / BigFloat(4) / t
			partstr = p.expString( 10, fix: 40)
			twopow = twopow * BigFloat(2)
			a = a1
			b = b1
			print(String(k), ":", astr, bstr, tstr,partstr)
		}
		XCTAssert(partstr == "3.1415926535897932384626433832795028841972E0")
		
		let pireal = BigFloatConstant.pi
		let prealstr = pireal.expString( 10, fix: 40)
		XCTAssert(partstr == prealstr)
		
		do {
			let piatan = BigFloat(4)*BigFloat.atan(x: BigFloat(1))
			let piatanstr = piatan.expString( 10, fix: 40)
			XCTAssert(partstr == piatanstr)
		}
		do {
			let piatan2 = BigFloat(4)*BigFloat.atan(x: BigFloat(0.5))
			let piatan3 = BigFloat(4)*BigFloat.atan(x: BigFloat(1) / BigFloat(3))
			let piatan = piatan2 + piatan3
			let piatanstr = piatan.expString( 10, fix: 40)
			XCTAssert(partstr == piatanstr)
		}
	}
    
    func testBasic() {
		let x = BigFloat(1.23456)
		let ten = BigFloat(10.0)
		let y = x / ten
		let z = y * ten
		let d = x > z ? x - z : z - x
		XCTAssert(d < epsilon,"Ask")

    }
	
	private func printNum(_ val: BigFloat, _ info: String = "") {
		let s = val.expString( 10, fix: 20)
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
		let s = sqrt2.expString( 10, fix: 40)
		let scomp = "1.4142135623730950488016887242096980785697E0"
		XCTAssert(s == scomp)
		var k = BigFloat(3)
		for _ in 1...10 {
			k = k * BigFloat(100000000) + BigFloat(3)
			let r = BigFloat.sqrt(x: k)
			let r2 = r * r
			let d = BigFloat.abs(k - r2)
			XCTAssert(d < epsilon)
		}
	}
	
	func testExp2() {
		let bige = BigFloat.exp(x: BigFloat(1))
		var epow = BigFloat(1)
		for i in 1...20 {
			epow = epow / bige
			let ecomp = BigFloat.exp(x: BigFloat(-i))
			let d = BigFloat.abs(ecomp - epow)
			let stre = ecomp.expString(10, fix: 40)
			let strd = d.expString(10, fix: 40)
			print (i," ", stre, " ", strd)
			XCTAssert(d < epsilon, "error : Exp" + String(-i) )
		}
	}
	
	func testExp1() {
		let bige = BigFloat.exp(x: BigFloat(1))
		let s = bige.expString( 10, fix: 40)
		let scomp = "2.7182818284590452353602874713526624977572E0"
		XCTAssert(s == scomp)
		var epow = bige
		
		for i in 2...20 {
			epow = epow * bige
			let ecomp = BigFloat.exp(x: BigFloat(i))
			let d = BigFloat.abs(ecomp - epow)
			let stre = ecomp.expString( 10, fix: 40)
			let strd = d.expString( 10, fix: 40)
			print (i," ", stre, " ", strd)
			XCTAssert(d < epsilon )
		}
	}
	
	func testPow10() {
		let ten = BigFloat(10)
		var tenpow = ten
		
		for i in 2...20 {
			tenpow = tenpow * ten
			let tpow = BigFloat.pow(x: ten,y :BigFloat(i))
			let d = BigFloat.abs(tenpow - tpow)
			let str1 = tpow.expString( 10, fix: 40)
			let strd = d.expString( 10, fix: 40)
			print (i," ", str1, " ", strd)
			XCTAssert(d < epsilon )
		}
	}
	
	
}
