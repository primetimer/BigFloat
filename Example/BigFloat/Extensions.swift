//
//  Extensions.swift
//  PFactors_Example
//
//  Created by Stephan Jancar on 20.10.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import BigInt

extension Int {
	func toUint() -> UInt64 {
		if self >= 0  { return UInt64(self) }
		let u = UInt64(self - Int.min) + UInt64(Int.max) + 1
		return u
	}
}

extension BigUInt {
	
	func Build3Blocks() -> [String] {
		var arr : [String] = []
		let valstr = String(self)
		var (str3,pos) = ("",0)
		for c in valstr.characters.reversed() {
			(str3,pos) = (String(c) + str3,pos+1)
			if pos % 3 == 0 {
				arr.append(str3)
				(str3,pos) = ("",0)
			}
		}
		if str3 != "" { arr.append(str3) }
		return arr
	}
	
	func FormatStr(maxrows : Int, rowlen : Int = 18) -> (String,rows: Int) {
		if self == 0 { return ("0.",rows :1) }
		let blocks = self.Build3Blocks()
		var (outstr,len) = ("",0)
		let blocksperrow = rowlen / 3
		var rows = 1 + (blocks.count-1) / blocksperrow
		var maxindex = maxrows * blocksperrow
		if rows > maxrows {
			rows = maxrows
			maxindex = maxindex - 3 //Get place for ### Info
		}
		
		for i in 0..<rows {
			for j in 0..<blocksperrow {
				let index = i * blocksperrow + j
				if  index >= blocks.count { break }
				if index >= maxindex {
					var startstr = blocks[blocks.count-1]
					if index < blocks.count - 2 {
						startstr = startstr + "." + blocks[blocks.count-2]
					}
					outstr = startstr + ".###." + outstr
					return (outstr,i)
				}
				let blockstr = blocks[index]
				(outstr,len) = ( blockstr + "." + outstr,len+blockstr.count)
			}
			if i<rows-1 { outstr = "\n" + outstr }
		}
		return (outstr,rows)
	}
}

extension String {
	func asBigUInt() -> BigUInt {
		var ret = BigUInt(0)
		let chars = Array(self)
		for c in chars {
			switch c {
			case "0", "1", "2", "3", "4" , "5", "6", "7", "8", "9":
				let digit = BigUInt(String(c)) ?? 0
				ret = ret * 10 + BigUInt(digit)
			default:
				break
			}
		}
		return ret
	}
}

