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

class CalcButton : UIButton {
	private (set) var type : CalcType = .Undefined
	var shiftbutton : CalcButton? = nil	//If there is a second action when Shift ist pressed
	convenience init (type : CalcType) {
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
	}
	required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
