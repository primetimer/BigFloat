//
//  NumberInput.swift
//  BigFloat_Example
//
//  Created by Stephan Jancar on 04.11.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import BigInt
import BigFloat

enum KeyBoardSpecialCmd {
	case none, alpha, prog, shift, undo, back, enter, esc, preview, clx, info, hex
	
	var description : String {
		switch self {
		case .none:		return "none"
		case .alpha:	return "α"
		case .prog:		return "Prg"
		case .shift: 	return "⇧"
		case .undo:		return "Undo"
		case .back:		return "⌫"
		case .enter:	return "ENTER"
		case .esc:		return "ESC"
		case .preview:	return "≈"
		case .clx:		return "CLR"
		case .info:		return "ℹ︎"
		case .hex:		return "hex"
		}
	}
}

class SpecialInputCmd : InputCmd {
	private (set) var cmd :  KeyBoardSpecialCmd
	init(cmd : KeyBoardSpecialCmd) {
		self.cmd = cmd
		super.init(inputtype: .none)

	}
}




