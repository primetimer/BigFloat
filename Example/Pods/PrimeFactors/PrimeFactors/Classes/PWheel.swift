//
//  PWheel.swift
//  PFactors
//
//  Created by Stephan Jancar on 17.10.17.
//

import Foundation

//
//  WheelArray.swift
//  PrimeBase
//
//  Created by Stephan Jancar on 27.06.17.
//  Copyright © 2017 esjot. All rights reserved.
//

import Foundation


class WheelArray {
	let UIntInBits : UInt64 = UInt64(MemoryLayout<UInt64>.size * 8)
	
	private (set) var count : UInt64 = 0
	private (set) var count2 : UInt64 = 0
	private (set) var countInts : UInt64 = 0
	
	var bitarr : [UInt64] = []
	private let tinyprimes : [UInt64] = [2,3,5,7,11,13,17,19,23,29,31,37,41]
	private var lastp : UInt64 = 2
	private var mk : UInt64 = 1		//Primorial up to limit2
	private var wk : [UInt16] = []
	private var spokes : UInt64 = 0
	init(count:UInt64) {
		
		self.count = count
		self.count2 = count.squareRoot()
		InitPrimorial()
		self.spokes = InitWheel()
		self.countInts = self.count / UIntInBits * spokes / mk + 1
		self.bitarr = [UInt64] (repeating: 0, count: Int(countInts))
	}
	
	private func InitPrimorial() {
		mk = 1
		for k in 0..<tinyprimes.count {
			if mk * tinyprimes[k] > count2 {
				return
			}
			mk = mk * tinyprimes[k]
			lastp = tinyprimes[k]
		}
	}
	
	private func InitWheel() -> UInt64 {	//Returns the number of used spokes
		
		//Speichert den offset in das Array der Ints, die
		wk = [UInt16] (repeating: 0, count: Int(mk))
		var k : UInt64 = 0
		for x in 0...mk-1 {
			if mk.greatestCommonDivisor(with: x) == 1 {
				k = k + 1
				wk[Int(x)] = UInt16(k)
			}
		}
		return k
	}
	
	func Index(bitnr: UInt64) -> (intIndex: UInt64, bitIndex: UInt64) {
		
		let spokeindex = UInt64(wk[Int(bitnr % mk)])
		if spokeindex == 0 {
			return (0,0)
		}
		//let turn = bitnr / mk
		//let intindex = (turn * spokes + spokeindex ) / UIntInBits
		//let bitIndex = (turn * spokes + spokeindex ) % UIntInBits
		let i = bitnr / mk  * spokes + spokeindex
		let intindex = i / UIntInBits
		let bitIndex = i % UIntInBits
		return (intindex, bitIndex)
	}
	
	func getBit(nr : UInt64) -> Bool {
		let (intIndex,bitIndex) = Index(bitnr: nr)
		if (intIndex,bitIndex) == (0,0) { return false }
		let intval = bitarr[Int(intIndex)]
		var mask : UInt64 = UInt64(1) << UInt64(bitIndex)
		mask = mask & intval
		return mask != 0
	}
	func setBit(nr : UInt64, value : Bool) {
		let (intIndex,bitIndex) = Index(bitnr: nr)
		if (intIndex,bitIndex) == (0,0) { return }
		let mask : UInt64 = UInt64(1) << UInt64(bitIndex)
		
		if value {
			bitarr[Int(intIndex)] |= mask
		} else {
			bitarr[Int(intIndex)] &= ~mask
		}
	}
	public subscript(index: Int) -> Bool {
		get {
			return getBit(nr: UInt64(index))
		}
		set {
			setBit(nr: UInt64(index), value : newValue)
		}
	}
	
	func bitCount(start : UInt64, end : UInt64) -> UInt64 {
		
		var bitcount : UInt64 = 0
		
		var p0 = start
		while wk[Int(p0 % mk)] == 0 {
			p0 = p0 + 1
			if p0 > end { return 0 }
		}
		let spokeindex0 = UInt64(wk[Int(p0 % mk)])
		let i0 = (p0 / mk  * spokes + spokeindex0) / UIntInBits
		
		
		var p1 = end
		while wk[Int(p1 % mk)] == 0 {
			p1 = p1 - 1
			if p1 < start { return 0 }
		}
		let spokeindex1 = UInt64(wk[Int(p1 % mk)])
		let i1 = (p1 / mk  * spokes + spokeindex1 ) / UIntInBits
		
		//Count in i0
		var p = p0
		var i = i0
		repeat {
			if getBit(nr: p) {
				bitcount = bitcount  + 1
			}
			
			p = p + 1
			if p > end { return bitcount }
			let spokeindex = UInt64(wk[Int(p % mk)])
			if spokeindex > 0 {
				i = (p / mk * spokes + spokeindex) / UIntInBits
			}
		} while i == i0
		
		
		i = i0 + 1
		while i < i1
		{
			let ival = bitarr[Int(i)]
			let dif = ival.NumBits()
			bitcount = bitcount + dif
			i = i + 1
		}
		//Count in i1
		if i1 > i0 {
			p = p1
			i = i1
			repeat {
				if getBit(nr: p) {
					bitcount = bitcount  + 1
				}
				p = p - 1
				let spokeindex = UInt64(wk[Int(p % mk)])
				if spokeindex > 0 {
					i = (p / mk * spokes + spokeindex) / UIntInBits
				}
			} while i == i1
		}
		
		return bitcount
	}
	
}

