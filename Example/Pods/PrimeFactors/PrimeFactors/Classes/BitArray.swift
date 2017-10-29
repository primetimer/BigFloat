//
//  BitArray.swift
//  PFactors
//
//  Created by Stephan Jancar on 17.10.17.
//

import Foundation

import Foundation

class BitArray {
	
	let UIntInBits : UInt64 = UInt64(MemoryLayout<UInt64>.size * 8)
	
	private (set) var count : UInt64 = 0
	private (set) var countInts : UInt64 = 0
	var bitarr : [UInt64] = []

	init(count:UInt64, initval : Bool = false) {
		
		self.count = count
		self.countInts = self.count / UIntInBits + 1
		
		var mask : UInt64 = 0
		
		if initval {
			mask = ~0
			
		}
		self.bitarr = [UInt64] (repeating: mask, count: Int(countInts))
	}
	
	private func Index(bitnr: UInt64) -> (intIndex: UInt64, bitIndex: UInt64) {
		
		let intindex = bitnr / UIntInBits
		let bitIndex = bitnr % UIntInBits
		return (intindex, bitIndex)
	}
	
	func getBit(nr : UInt64) -> Bool {
		
		let (intIndex,bitIndex) = Index(bitnr: nr)
		let intval = bitarr[Int(intIndex)]
		var mask : UInt64 = UInt64(1) << UInt64(bitIndex)
		mask = mask & intval
		return mask != 0
	}
	func setBit(nr : UInt64, value : Bool) {
		
		let (intIndex,bitIndex) = Index(bitnr: nr)
		let mask : UInt64 = UInt64(1) << UInt64(bitIndex)
		
		if value {
			bitarr[Int(intIndex)] |= mask
		} else {
			bitarr[Int(intIndex)] &= ~mask
		}
	}
	
	/// Provides random access to individual bits using square bracket noation.
	/// The index must be less than the number of items in the bit array.
	/// If you attempt to get or set a bit at a greater
	/// index, you’ll trigger an error.
	public subscript(index: Int) -> Bool {
		get {
			return getBit(nr: UInt64(index))
		}
		set {
			setBit(nr: UInt64(index), value : newValue)
		}
	}
	
}

