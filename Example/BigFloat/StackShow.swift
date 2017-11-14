//
//  StackShow.swift
//  BigFloat_Example
//
//  Created by Stephan Jancar on 14.11.17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import BigInt
import BigFloat

class StackShow {
	
	private var vc : CalcVC!
	private var rpn : RPNCalc!
	private var input : StackInputProt!
	private var view : UIView!
	var visible  = 4
	var base : Int = 10
	
	init(vc : CalcVC, rpn : RPNCalc, input : StackInputProt) {
		self.vc = vc
		self.rpn = rpn
		self.input = input
		self.view = vc.view
		view.addSubview(uistate)
		
		//UI for the RPN-Registers
		for _ in 0...3 {
			let stacklabel = UILabel()
			let stackdesc = UILabel()
			uistack.append(stacklabel)
			uistackdesc.append(stackdesc)
			view.addSubview(stacklabel)
			view.addSubview(stackdesc)
		}
		
		view.addSubview(uiinfotext)
		uiinfotext.isHidden = true
	}
	
	var uistate = UILabel()
	private var uistack : [UILabel] = []
	private var uistackdesc : [UILabel] = []
	private var uiinfotext = InfoView()
	
	func ShowInfoText(type : RPNCalcCmd) {
		uiinfotext.ShowText(type: type)
	}
	
	//Size of the Stackview depending on landscape or portrait mode and device type
	func StackWidth() -> CGFloat {
		let wphone = view.landscape ? view.frame.width / 2 : view.frame.width
		let wpad = view.landscape ? view.frame.width * 3 / 5 : view.frame.width
		switch UIDevice.current.userInterfaceIdiom {
		case .pad:
			return wpad
		case .phone:
			return wphone
		default:
			return wpad
		}
	}
	
	private func StackHeight() -> CGFloat {
		return CGFloat(visible) * RegisterHeight()
	}
	private func RegisterHeight() -> CGFloat {
		let viewh = view.frame.height - 40
		let parts = view.landscape ? 4.0 : 12.0
		let regh = viewh / CGFloat(parts) * 4 / CGFloat(visible)
		return regh
	}
	private func LayoutStack(stackpos: Int, label : UILabel, desc: UILabel) {
		do {
			let frame0 = uistack[0].frame
			let frame1 = CGRect(x: 20, y:frame0.origin.y + frame0.height, width: frame0.width,height: 20.0)
			uistate.frame = frame1
			uistate.textColor = .red
		}
		let w = StackWidth()
		let wpart = (w-40) / 6
		let x = CGFloat(20)
		let y = 20 + CGFloat(visible - stackpos - 1) * RegisterHeight()
		let descrect = CGRect(x: x, y: y, width: wpart, height : RegisterHeight())
		desc.textAlignment = .center
		desc.frame = descrect
		desc.backgroundColor = UIColor.white.withAlphaComponent(0.2)
		desc.textColor = .white
		let rect = CGRect(x: x+wpart, y: y, width: wpart*5, height: RegisterHeight())
		label.backgroundColor = UIColor.white.withAlphaComponent(0.2)
		label.textAlignment = .right;
		label.numberOfLines = 0;
		label.frame = rect
		label.textColor = .green
		label.isHidden = (stackpos >= visible)
		desc.isHidden = (stackpos >= visible)
	}

	func LayoutStack() {
		let frame = CGRect(x: 20, y: 20, width:StackWidth() - 40.0 , height: StackHeight())
		uiinfotext.frame = frame
		for i in 0..<4 {
			LayoutStack(stackpos : i, label: uistack[i], desc: uistackdesc[i])
		}
	}
	
	private func StackName(index : Int) -> String {
		//let len = String(rpn[index]).count
		var str = String(index)
		switch index {
		case 0:		str = "X"
		case 1:		str = "Y"
		case 2:		str = "Z"
		case 3:		str = "T"
		default:	break
		}
		return str
	}
	
	//Shows some infomration about the state of the registers (uistate) is uirelated
	func ShowStackState() {
		
		uistate.textColor = .red
		switch rpn.stackstate {
		case .stored:		uistate.text = "stored"
		case .cancelled:	uistate.text = "cancelled"
		case .factorized:	uistate.text = "factorized"
		case .valid:		uistate.text = ""
		case .busy:			uistate.text = "busy"
		case .error:		uistate.text = "error"
		case .overflow:		uistate.text = "overflow"
		case .prime:		uistate.text = "prime"
		case .unimplemented:uistate.text = "not implemented"
		case .copied: 		uistate.text = "copied"
		}
	}
	
	func ShowStack() {
		ShowStackState()
		//Calculates the maximal len of the registers
		var (registerrows,registerlen) = (1,1)
		let maxrows = 4 * 2 / visible
		for i in 0..<visible {
			if i == 0 && !input.IsFinished() {
				let str = input.GetInputString()
				uistack[i].text = str
			} else {
				let val = rpn[i]
				let (valstr,rows) = val.FormatStr(base: base, maxrows: maxrows, rowlen: 18)
				uistack[i].text = valstr
				registerrows = max(registerrows,rows)
			}
			
			uistackdesc[i].text = StackName(index: i)
			registerlen = max(registerlen,uistack[i].text!.count)
		}
		
		if visible == 1 {
			if input.IsFinished() {
				let val = rpn[0].value
				let str = val.autoString(base, fix: 5*18-6)
				uistack[0].text = str
			}
		}
		
		//Changes font according to the maximal number of rows per register
		var fonth = vc.view.landscape ? RegisterHeight() * 0.45 - 4 : RegisterHeight() * 0.7 - 4
		fonth = fonth / CGFloat(maxrows)
		if registerrows == 1 && registerlen <= 18 { fonth = fonth * 2 }
		for i in 0..<uistack.count {
			if let font = UIFont(name: "digital-7mono", size: fonth) {
				uistack[i].font = font
				uistackdesc[i].font = font
			}
		}
	}

}


