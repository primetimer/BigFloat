//
//  UIExtensions.swift
//  PFactors_Example
//
//  Created by Stephan Jancar on 23.10.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import UIKit



extension UIView {
	var x : CGFloat {
		get { return self.frame.origin.x}
	}
	var y : CGFloat {
		get { return self.frame.origin.y}
	}
	var w : CGFloat {
		get { return self.frame.width}
	}
	var h : CGFloat {
		get { return self.frame.height}
	}
}

class AlphaButton : UIButton {
	
	private (set) var alphacmd : AlphaInputCmd
	var keystr : String {
		get {
			let c = Character(UnicodeScalar(alphacmd.key)!)
			return String(c)
		}
	}
	var key : Int {
		get {
			return alphacmd.key
		}
	}
	convenience init (key : Int) {
		self.init()
		self.alphacmd = AlphaInputCmd(key: key)
		self.setTitle(self.keystr, for: .normal)
		self.titleLabel?.font = self.titleLabel?.font.withSize(14)
	}
	init () {
		self.alphacmd = AlphaInputCmd(key: 0)
		super.init(frame : .zero)
		setTitleColor(.cyan, for: .normal)
	}
	
	required init?(coder aDecoder: NSCoder) {		fatalError("init(coder:) has not been implemented") }
}
class CalcButton : UIButton {
	var type : RPNCalcCmd = .Undefined
	var shiftbutton : CalcButton? = nil	//If there is a second action when Shift ist pressed
	var unshiftbutton : CalcButton? = nil
	convenience init (type : RPNCalcCmd) {
		self.init()
		self.type = type
		switch  type {
		case .Plus,.Minus,.Divide,.Prod: break //Fontsize keeps default
		default: self.titleLabel?.font = self.titleLabel?.font.withSize(14)
		}
	}
	
	init() {
		super.init(frame : .zero)
		setTitleColor(.white, for: .normal)
		self.setTitleColor(.blue, for: .highlighted)
		self.titleLabel?.font = self.titleLabel?.font.withSize(14)
	}
	required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class ProgButton : CalcButton {
	private (set) var stmt : ProgInputCmd? = nil
	init (stmt : ProgInputCmd) {
		super.init()
		self.stmt = stmt
		self.type = .Undefined
		setTitle(stmt.description, for: .normal)
	}
	
	required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}


class InputCmdButton : CalcButton {
	private (set) var cmd : NumInputCmd
	init (cmd : NumInputCmd) {
		self.cmd = cmd
		super.init()
		self.titleLabel?.font = self.titleLabel?.font.withSize(14)
	}
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

class SpecialButton : CalcButton {	
	private (set) var cmd : SpecialInputCmd
	init (cmd : SpecialInputCmd) {
		self.cmd = cmd
		super.init()
		self.setTitle(cmd.cmd.description, for: .normal)
		self.titleLabel?.font = self.titleLabel?.font.withSize(14)
	}
	convenience init (key: KeyBoardSpecialCmd) {
		let cmd = SpecialInputCmd(cmd: key)
		self.init(cmd : cmd)
	}
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
