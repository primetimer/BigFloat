//
//  ViewController.swift
//  PFactors
//
//  Created by primetimer on 10/17/2017.
//  Copyright (c) 2017 primetimer. All rights reserved.
//

import UIKit
import BigInt
import PrimeFactors
import BigFloat

class ViewController: UIViewController, ProtShowResult {
	private var input = StackInput()
	private var _shiftmode : Bool = false
	private var shiftmode : Bool {
		set { _shiftmode = newValue; ShowButtons() }
		get { return _shiftmode }
	}
	
	private var _alphamode : Bool = false
	private var alphamode : Bool {
		set { _alphamode = newValue; ShowButtons() }
		get { return _alphamode }
	}
	
	private var rpnlist : [RPNCalc] = [RPNCalc()]
	private var rpn : RPNCalc {
		get { return rpnlist[0] }
	}
	private var p : BigUInt = 1
	//private let rho = PrimeFaktorRho()
	//private let shank = PrimeFactorShanks()
	//private let lehman = PrimeFactorLehman()
	
	private var uistate = UILabel()
	private var uistack : [UILabel] = []
	private var uistackdesc : [UILabel] = []
	private var uiback = InputButton(cmd: .back)
	private var uiclx = CalcButton(type: .Undefined)
	private var uipreview = CalcButton()
	private var uiundo = InputButton(cmd: .unknown)
	private let uishift = InputButton(cmd: .unknown)
	private let uialpha = InputButton(cmd: .alpha)
	private let uiesc = CalcButton(type : .Undefined)
	private let uiinfo = CalcButton(type : .Undefined)
	private var buttonarr : [CalcButton] = []
	private var alphaarr : [AlphaButton] = []
	private var uiinfotext = InfoView()
	
	func CreateInputButton(str: String, cmd : StackInputCmd) {
		let b = InputButton(cmd: cmd)
		buttonarr.append(b)
		view.addSubview(b)
		b.setTitle(str, for: .normal)
		b.addTarget(self, action: #selector(NumberAction), for: .touchUpInside)
	}
	
	//Create Button for Calc Action
	func CreateCalcButton(str: String, type : CalcType) {
		let b = CalcButton(type: type)
		buttonarr.append(b)
		view.addSubview(b)
		b.setTitle(str, for: .normal)
		b.addTarget(self, action: #selector(CalcAction), for: .touchUpInside)
	}
	
	//Create Button when shift is activated
	private func CreateCalcButtonShift(str: String, type : CalcType, unshift: CalcButton) {
		let b = CalcButton(type: type)
		buttonarr.append(b)
		view.addSubview(b)
		b.setTitle(str, for: .normal)
		b.setTitleColor(.yellow, for: .normal)
		b.addTarget(self, action: #selector(CalcAction), for: .touchUpInside)
		b.titleLabel?.font = b.titleLabel?.font.withSize(14)
		unshift.shiftbutton = b
		b.isHidden = true
	}
	private func CreateCalcButtonShift(str: String, type : CalcType, unshift: CalcType) {
		if let prevb = GetButtonByType(type: unshift) {
			CreateCalcButtonShift(str: str, type: type, unshift: prevb)
		}
	}
	
	//Find a button by Calculation Type
	private func GetButtonByType(type: CalcType) -> CalcButton? {
		for b in buttonarr {
			if b.type == type {
				return b
			}
		}
		return nil
	}
	
	private func GetButtonByCmd(cmd: StackInputCmd) -> InputButton? {
		for b in buttonarr {
			if let i = b as? InputButton {
				if i.cmd == cmd {
					return i
				}
			}
		}
		return nil
	}
	
	override func viewWillAppear(_ animated: Bool) {
		ShowStack()
		ShowButtons()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.backgroundColor = UIColor.black
				
		//The Number Pad
		for i in 0...9 {
			CreateInputButton(str: String(i), cmd: StackInputCmd.ByDigit(dig: i))
		}
		
		view.addSubview(uistate)	//State of calculation
		
		//UI for the RPN-Registers
		for _ in 0...3 {
			let stacklabel = UILabel()
			let stackdesc = UILabel()
			uistack.append(stacklabel)
			uistackdesc.append(stackdesc)
			view.addSubview(stacklabel)
			view.addSubview(stackdesc)
		}
		
		//UI for input and utilities
		view.addSubview(uiback)
		uiback.setTitle("⌫", for: .normal)
		uiback.addTarget(self, action: #selector(NumberAction), for: .touchUpInside)
		uiback.shiftbutton = uiclx
		view.addSubview(uiclx)
		uiclx.setTitle("CLR", for: .normal)
		uiclx.addTarget(self, action: #selector(ClearAction), for: .touchUpInside)
		uiclx.isHidden = true
		
		CreateInputButton(str: ".", cmd:  .punct)
		CreateInputButton(str: "EE", cmd:  .ee)
		CreateInputButton(str: "+/-", cmd: .chs)
		CreateInputButton(str: "ENTER", cmd: .enter)
		
		view.addSubview(uipreview)
		view.addSubview(uishift)
		view.addSubview(uialpha)
		view.addSubview(uiesc)
		view.addSubview(uiundo)
		view.addSubview(uiinfo)
		view.addSubview(uiinfotext)
		uiinfotext.isHidden = true
		
		uiundo.setTitle("Undo", for: .normal)
		uiundo.addTarget(self, action: #selector(NumberAction), for: .touchUpInside)
		uipreview.setTitle("View #", for: .normal)
		uipreview.addTarget(self, action: #selector(PreviewAction), for: .touchUpInside)
		uishift.setTitle(("⇧"), for: .normal)
		uishift.addTarget(self, action: #selector(NumberAction), for: .touchUpInside)
		uialpha.setTitle(("α"), for: .normal)
		uialpha.addTarget(self, action: #selector(NumberAction), for: .touchUpInside)
		uiesc.setTitle(("ESC"), for: .normal)
		uiesc.addTarget(self, action: #selector(EscapeAction), for: .touchUpInside)
		uiinfo.setTitle("ℹ︎", for: .normal)
		uiinfo.addTarget(self, action: #selector(InfoAction), for: .touchUpInside)
		
		//UI for Functions
		CreateCalcButton(str: "LastX", type: .LastX)
		CreateCalcButton(str: "+", type: .Plus)
		CreateCalcButton(str: "-", type: .Minus)
		CreateCalcButton(str: "*", type: .Prod)
		CreateCalcButton(str: "/", type: .Divide)
		CreateCalcButton(str: "sin", type: .Sin)
		CreateCalcButton(str: "cos", type: .Cos)
		CreateCalcButton(str: "tan", type: .Tan)
		CreateCalcButtonShift(str: "asin", type: .aSin,unshift: .Sin)
		CreateCalcButtonShift(str: "acos", type: .aCos,unshift: .Cos)
		CreateCalcButtonShift(str: "atan", type: .aTan,unshift: .Tan)
		CreateCalcButton(str: "1/x", type: .Inv)
		
		
		//CreateCalcButton(str: "→π", type: .PNext)
		//CreateCalcButtonShift(str: "→ππ", type: .Twin,unshift : .PNext)
		//CreateCalcButton(str: "π←", type: .PPrev)
		//CreateCalcButtonShift(str: "→2π+1", type: .SoG,unshift : .PPrev)
		//CreateCalcButton(str: "x*()", type: .Factor)
		//CreateCalcButtonShift(str: "p*q", type: .Factors,unshift : .Factor)
		//CreateCalcButton(str: "squfof", type: .Squfof)
		CreateCalcButton(str: "STO", type: .Sto1)
		CreateCalcButton(str: "RCL", type: .Rcl1)
		//CreateCalcButton(str: "ρ", type: .Rho)
		//CreateCalcButton(str: "a²-b²", type: .Lehman)
		CreateCalcButton(str: "x<>y", type: .Swap)
		CreateCalcButton(str: "↓", type: .Pop)
		CreateCalcButton(str: "%", type: .Mod)
		//CreateCalcButton(str: "gcd", type: .gcd)
		CreateCalcButton(str: "y^x", type: .Pow)
		//CreateCalcButtonShift(str: "z^y%x", type: .PowMod, unshift: .Pow)
		//CreateCalcButton(str: "#", type : .Hash)
		//CreateCalcButtonShift(str: "Rnd #", type: .Rnd, unshift: .Hash)
		CreateCalcButton(str: "√", type: .sqrt)
		CreateCalcButtonShift(str: "∛", type: .crt, unshift: .sqrt)
		CreateCalcButton(str: "exp", type: .exp)
		CreateCalcButtonShift(str: "ln", type: .ln, unshift: .exp)
		CreateCalcButton(str: "π", type: .pi)
		
		CreateCalcButton(str: "⌘C", type: .CmdC)
		CreateCalcButtonShift(str: "⌘V", type: .CmdV, unshift : .CmdC)
		//CreateCalcButton(str: "Sexy", type: .Sexy)
		//CreateCalcButton(str: "Cousin", type: .Cousin)
		CreateCalcButton(str: "10^x", type: .TenPow)
		CreateCalcButton(str: "x² ", type: .Square)
		CreateCalcButton(str: "x³", type: .Cube)
		CreateCalcButton(str: "M(x)", type: .Mersenne)
		GetButtonByCmd(cmd: .n3)!.shiftbutton = GetButtonByType(type: .pi)
		GetButtonByCmd(cmd: .ee)!.shiftbutton = uipreview
		GetButtonByCmd(cmd: .enter)!.shiftbutton = GetButtonByType(type: .LastX)
		Layout()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	//Digit Buttons
	//private var ui_num : [InputButton] = []
	
	//Size of the Stackview depending on landscape or portrait mode and device type
	private func StackWidth() -> CGFloat {
		let wphone = landscape ? view.frame.width / 2 : view.frame.width
		let wpad = landscape ? view.frame.width * 3 / 5 : view.frame.width
		switch UIDevice.current.userInterfaceIdiom {
		case .pad:
			return wpad
		case .phone:
			return wphone
		default:
			return wpad
		}
	}
	
	//Size of the Number and Action depending on landscape or portrait mode and device type
	private func GetNumpadFrameWidth() -> CGFloat
	{
		if !landscape { return StackWidth() }
		return self.view.frame.width - StackWidth()
	}
	
	private func LayoutButtonRaster(row : Int, col : Int, button: UIButton, numcols : Int = 1) {
		let w = GetNumpadFrameWidth()
		let h = view.frame.height
		let x0 = landscape ? StackWidth() + 20 : 20
		let row0 = landscape ? 4 : 0
		let parts = landscape ? 7 : 11
		let wpart = (w-40) / 6
		let hpart = (h-40) / CGFloat(parts)
		let x = x0 + CGFloat(col) * wpart
		let y = 20 + CGFloat(row-row0) * hpart
		let rect = CGRect(x: x, y: y, width: wpart*CGFloat(numcols), height: hpart)
		button.frame = rect
	}
	
	private var landscape : Bool {
		get { return UIDevice.current.orientation.isLandscape }
	}
	
	private func StackHeight() -> CGFloat {
		return CGFloat(visiblestackelems) * RegisterHeight()
	}
	private func RegisterHeight() -> CGFloat {
		let viewh = view.frame.height - 40
		let parts = landscape ? 4.0 : 11.0
		let regh = viewh / CGFloat(parts) * 4 / CGFloat(visiblestackelems)
		return regh
	}
	private func LayoutStack(stackpos: Int, label : UILabel, desc: UILabel) {
		let w = StackWidth()
		let wpart = (w-40) / 6
		let x = CGFloat(20)
		let y = 20 + CGFloat(visiblestackelems - stackpos - 1) * RegisterHeight()
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
		label.isHidden = (stackpos >= visiblestackelems)
		desc.isHidden = (stackpos >= visiblestackelems)
	}
	
	private var visiblestackelems = 4
	private func LayoutStack() {
		let frame = CGRect(x: 20, y: 20, width:StackWidth() - 40.0 , height: StackHeight())
		uiinfotext.frame = frame
		for i in 0..<4 {
			LayoutStack(stackpos : i, label: uistack[i], desc: uistackdesc[i])
		}
	}
	
	//All UI-Elements are manual layouted, not via storyboard
	private func Layout() {
		LayoutStack()
		do {
			let frame0 = uistack[0].frame
			let frame1 = CGRect(x: 20, y:frame0.origin.y + frame0.height, width: frame0.width,height: 20.0)
			uistate.frame = frame1
			uistate.textColor = .red
		}
		for i in 1...9 {
			let col = 1 + (i-1) % 3
			let row = 3 - (i-1) / 3 + uistack.count
			let b = GetButtonByCmd(cmd: StackInputCmd.ByDigit(dig: i))
			LayoutButtonRaster(row:row, col: col, button: b!)
		}
		
		var row = 10
		LayoutButtonRaster(row:row, col: 0, button: uialpha)
		
		LayoutButtonRaster(row:row, col: 0, button: uiclx)
		LayoutButtonRaster(row:row, col: 1, button: GetButtonByCmd(cmd: .enter)!,numcols: 2)
		LayoutButtonRaster(row:row, col: 3, button: GetButtonByCmd(cmd: .ee)!)
		LayoutButtonRaster(row:row, col: 4, button: GetButtonByType(type: .CmdC)!)
		LayoutButtonRaster(row:row, col: 5, button: uiinfo)
		row = row - 1
		LayoutButtonRaster(row:row, col: 0, button: uiback)

		LayoutButtonRaster(row:row, col: 1, button: GetButtonByCmd(cmd: .n0)!)
		LayoutButtonRaster(row:row, col: 2, button: GetButtonByCmd(cmd: .punct)!)
		LayoutButtonRaster(row:row, col: 3, button: GetButtonByCmd(cmd: .chs)!)
		LayoutButtonRaster(row:row, col: 4, button: GetButtonByType(type: .Plus)!)
		LayoutButtonRaster(row:row, col: 5, button: GetButtonByType(type: .Sto1)!)
		
		row = row - 1
				LayoutButtonRaster(row:row, col: 0, button: uishift)
		LayoutButtonRaster(row:row, col: 1, button: GetButtonByCmd(cmd: .n1)!)
		LayoutButtonRaster(row:row, col: 2, button: GetButtonByCmd(cmd: .n2)!)
		LayoutButtonRaster(row:row, col: 3, button: GetButtonByCmd(cmd: .n3)!)
		LayoutButtonRaster(row:row, col: 4, button: GetButtonByType(type: .Minus)!)
		LayoutButtonRaster(row:row, col: 5, button: GetButtonByType(type: .Rcl1)!)
		
		row = row - 1
		LayoutButtonRaster(row:row, col: 0, button: GetButtonByType(type: .Swap)!)
		LayoutButtonRaster(row:row, col: 1, button: GetButtonByCmd(cmd: .n4)!)
		LayoutButtonRaster(row:row, col: 2, button: GetButtonByCmd(cmd: .n5)!)
		LayoutButtonRaster(row:row, col: 3, button: GetButtonByCmd(cmd: .n6)!)
		LayoutButtonRaster(row:row, col: 4, button: GetButtonByType(type: .Prod)!)
		
		row = row - 1
		LayoutButtonRaster(row:row, col: 0, button: GetButtonByType(type: .Pop)!)
		LayoutButtonRaster(row:row, col: 1, button: GetButtonByCmd(cmd: .n7)!)
		LayoutButtonRaster(row:row, col: 2, button: GetButtonByCmd(cmd: .n8)!)
		LayoutButtonRaster(row:row, col: 3, button: GetButtonByCmd(cmd: .n9)!)
		LayoutButtonRaster(row:row, col: 4, button: GetButtonByType(type: .Divide)!)
		
		row = row - 1
		LayoutButtonRaster(row:row, col: 0, button: GetButtonByType(type: .Inv)!)
		LayoutButtonRaster(row:row, col: 1, button: GetButtonByType(type: .Pow)!)
		LayoutButtonRaster(row:row, col: 2, button: GetButtonByType(type: .sqrt)!)
		LayoutButtonRaster(row:row, col: 3, button: GetButtonByType(type: .Sin)!)
		LayoutButtonRaster(row:row, col: 4, button: GetButtonByType(type: .Cos)!)
		LayoutButtonRaster(row:row, col: 5, button: GetButtonByType(type: .Tan)!)
		
		row = row - 1
		LayoutButtonRaster(row:row, col: 0, button: GetButtonByType(type: .exp)!)
		LayoutButtonRaster(row:row, col: 1, button: GetButtonByType(type: .TenPow)!)
		
		//LayoutButtonRaster(row:9, col: 1, button: GetButtonByType(type: .Sto1)!)
		//LayoutButtonRaster(row:9, col: 2, button: GetButtonByType(type: .Sto2)!)
		//LayoutButtonRaster(row:9, col: 3, button: GetButtonByType(type: .Sto3)!)
		
		LayoutButtonRaster(row:4, col: 5, button: uiesc)
		LayoutButtonRaster(row:4, col: 5, button: uiundo)
		
		LayoutAlpha()
	}
	
	private func findAlphaKey(key : Int) -> AlphaButton {
		for a in alphaarr {
			if a.key == key { return a }
		}
		let b = AlphaButton(key : key)
		b.addTarget(self, action: #selector(AlphaAction), for: .touchUpInside)
		alphaarr.append(b)
		view.addSubview(b)
		return b
	}
	
	private func LayoutAlpha() {
		for key in 65 ... 90 {
			let row = 4 + (key - 65) / 6
			let col = (key - 65) % 6
			let b = findAlphaKey(key: key)
			LayoutButtonRaster(row: row, col: col, button: b)
		}
		for keynum in 48 ... 57 {
			let key = 90 - 65 + keynum - 48 + 1
			let row = 4 + key  / 6
			let col = key % 6
			let b = findAlphaKey(key: keynum)
			LayoutButtonRaster(row: row, col: col, button: b)
		}
		do {
			let b = findAlphaKey(key: 32)
			b.setTitle("SPC", for: .normal)
			LayoutButtonRaster(row: 10, col: 1, button: b)
		}
		do {
			let b = findAlphaKey(key: 59)	//Semikolon
			b.setTitle(";", for: .normal)
			LayoutButtonRaster(row: 10, col: 2, button: b)
		}
		
	}
	
	//This timer is used for a blinking busy signal
	private var timer : Timer? = nil
	private var timertoggle : Bool = false
	@objc func TimerUpdate() {
		uistate.textColor = timertoggle ? .red : .gray
		timertoggle = !timertoggle
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
		/*
		if len >= 12 {
			str = str + String(len)
		}
		*/
		return str
	}
	
	//Shows some infomration about the state of the registers (uistate) is uirelated
	private func ShowStackState() {
		uiesc.isHidden = asynccalc == nil ? true : false
		uiundo.isHidden = asynccalc == nil ? false : true
		timer?.invalidate()
		uistate.textColor = .red
		switch rpn.stackstate {
		case .stored:		uistate.text = "stored"
		case .cancelled:	uistate.text = "cancelled"
		case .factorized:	uistate.text = "factorized"
		case .valid:		uistate.text = ""
		case .busy:			uistate.text = "busy"
			timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.TimerUpdate), userInfo: nil, repeats: true)
		case .error:		uistate.text = "error"
		case .overflow:		uistate.text = "overflow"
		case .prime:		uistate.text = "prime"
		case .unimplemented:uistate.text = "not implemented"
		case .copied: 		uistate.text = "copied"
		}
	}
	
	private func ShowStack() {
		ShowStackState()

		//Calculates the maximal len of the registers
		var (registerrows,registerlen) = (1,1)
		let maxrows = 4 * 2 / visiblestackelems
		for i in 0..<visiblestackelems {
			if i == 0 && !input.IsFinished() {
				uistack[i].text = input.inputstring
			} else {
				let val = rpn[i]
				let (valstr,rows) = val.FormatStr(maxrows: maxrows, rowlen: 18)
				uistack[i].text = valstr
				registerrows = max(registerrows,rows)
			}
			
			uistackdesc[i].text = StackName(index: i)
			if uistack[i].text != nil {
				registerlen = max(registerlen,uistack[i].text!.count)
			}
		}
		
		if visiblestackelems == 1 {
			let val = rpn[0].value
			let str = val.ExponentialString(base: 10, fix: 0)
			uistack[0].text = str
		}
		
		//Changes font according to the maximal number of rows per register
		var fonth = landscape ? RegisterHeight() * 0.45 - 4 : RegisterHeight() * 0.7 - 4
		fonth = fonth / CGFloat(maxrows)
		if registerrows == 1 && registerlen <= 12 { fonth = fonth * 2 }
		for i in 0..<uistack.count {
			if let font = UIFont(name: "digital-7mono", size: fonth) {
				uistack[i].font = font
				uistackdesc[i].font = font
			}
		}
	}
	
	//UI Related Display of the Action-Pad
	private func ShowButtons(clear : Bool = false) {
		if clear {
			shiftmode = false
			asynccalc?.cancel()
			asynccalc = nil
		}
		if alphamode {
			for b in buttonarr {
				b.isHidden = true }
			for a in alphaarr {
				a.isHidden = false
			}
			uishift.isHidden = true
			uialpha.isHidden = false
			return
		}
		else {
			for a in alphaarr {
				a.isHidden = true
			}
			uishift.isHidden = false
		}
		
		if shiftmode {
			uishift.setTitleColor(.yellow, for: .normal)
			uiback.isHidden = true
			uiclx.isHidden = false
		} else {
			uishift.setTitleColor(.white, for: .normal)
			uiback.isHidden = false
			uiclx.isHidden = true
		}
		for b in buttonarr {
			if let shift = b.shiftbutton {
				if shiftmode {
					b.isHidden = true
					shift.isHidden = false
					shift.frame = b.frame
				} else {
					b.isHidden = false
					shift.isHidden = true
				}
			}
			else {
				b.isHidden = false
			}
		}
	}
	
	//When the Calculation ist started this variable is not nil
	var asynccalc : AsyncCalc? = nil
	
	//Executing all Calculation triggered by Buttons
	@objc func CalcAction(sender: CalcButton!)
	{
		if isInfo {
			uiinfotext.ShowText(type: sender.type)
			return
		}
		//Create Copy of Stack for undo action
		rpnlist.insert(rpn.Copy(), at: 1)
		while rpnlist.count > 10 { rpnlist.remove(at: 10)}
		asynccalc?.cancel()		//Try to cancels previous action s
		rpn.stackstate = .busy	//Blinks in Stackview as long as the calculation needs
		ShowStackState()
		
		//Calculation runs asynchrous (as best as i can)
		let queue = OperationQueue()
		asynccalc = AsyncCalc(rpn: rpn, type: sender.type)
		ShowStackState()
		asynccalc?.resultdelegate = self
		queue.addOperation(asynccalc!)
	}
	
	//Called by asynchronous Calculation on main thread
	internal func ShowCalcResult() {
		asynccalc = nil
		input.Finish()
		self.ShowStack()
		self.ShowButtons(clear : true)
	}
	
	//Try to stop all pending Calculations. Rely on cooperative design of calculation
	@objc func EscapeAction(sender: CalcButton!) {
		if isInfo {
			uiinfotext.ShowEscapeInfo()
			return
		}
		asynccalc?.cancel()
		asynccalc = nil
		rpn.stackstate = .cancelled
		ShowButtons()
		ShowStackState()
		ShowStack()
	}
	
	//Some useless information about the buttons in the ui
	private var isInfo : Bool = false
	@objc func InfoAction(sender: CalcButton!) {
		if sender == uiinfo {
			isInfo = !isInfo
			if isInfo {
				uiinfo.setTitleColor(.red, for: .normal)
				uiinfotext.isHidden = false
				uiinfotext.ShowGeneral()
			} else {
				uiinfo.setTitleColor(.white, for: .normal)
				uiinfotext.isHidden = true
			}
			return
		}
		if sender == uishift {
			uiinfotext.ShiftInfo()
			return
		}
		if sender == uialpha {
			uiinfotext.ShiftInfo()
			return
		}
		if sender.type != .Undefined {
			uiinfotext.ShowText(type: sender.type)
			return
		}
		if sender is InputButton {
			uiinfotext.ShowNumInfo()
		}
		if sender == uiundo {
			uiinfotext.ShowEscapeInfo()
		}
	}
	
	//Actions for Number Input and related Actions
	@objc func NumberAction(sender: InputButton!) {
		if isInfo {
			if sender == uiundo { InfoAction(sender: sender); return }
			if sender != uishift { InfoAction(sender: sender); return }
			InfoAction(sender: sender) //Info with uishift and switching keyboard
		}
		if isInfo { InfoAction(sender: sender)}
		
		switch  sender.cmd {
		case .chs:
			if input.IsFinished() {
				let chs = -rpn.x.value
				rpn.pop()
				rpn.push(x: StackElem(val: chs))
			} else {
				input.AppendCmd(cmd : sender.cmd)
				rpn.x = StackElem(val:input.inputvalue)
			}
		case .punct, .ee:
			if input.IsFinished() {
				//rpn.pop()
				rpn.push()
				input.Begin()
			}
			input.AppendCmd(cmd : sender.cmd)
			rpn.x = StackElem(val:input.inputvalue)
		case .n0, .n1, .n2, .n3, .n4, .n5, .n6, .n7, .n8, .n9:
			if input.IsFinished() {
				//rpn.pop()
				rpn.push()
				input.Begin()
			}
			input.AppendCmd(cmd : sender.cmd)
			rpn.x = StackElem(val:input.inputvalue)
		case .back:
			if rpn.stackstate != .valid { rpn.stackstate = .valid ; return}
			if input.IsFinished() { break }
			input.AppendCmd(cmd: .back)
			rpn.x = StackElem(val: input.inputvalue)
		case .enter:
			if input.IsFinished() {
				rpn.push(); break
			}
			input.AppendCmd(cmd: .enter)
			rpn.push(x: input.inputelem)
			input.Begin()
		case .alpha:
			if alphamode {
				if !input.inputstring.isEmpty
				{
					rpn.x = input.inputelem
					input.Finish()
				}
				alphamode = false
			} else {
				input.AppendCmd(cmd: .enter)
				rpn.push(x: input.inputelem)
				alphamode = true
				input.Begin()
			}

		case .unknown:
			if sender == uishift {
				shiftmode = !shiftmode
				ShowButtons()
				return
			}
			if sender == uiundo {
				if rpnlist.count > 1 {	rpnlist.remove(at: 0) }
			}
		}
		rpn.stackstate = .valid
		ShowStack()
		ShowButtons(clear: true)
	}
	
	//Deletes Stack completelye
	@objc func ClearAction() {
		if isInfo { uiinfotext.ShowClearInfo(); return }
		rpn.Clear()
		while rpnlist.count > 1 {	rpnlist.remove(at: 1) }
		ShowStack()
		ShowButtons(clear: true)
	}
	@objc func AlphaAction(sender: AlphaButton) {
		alphamode = true
		input.AppendAlpha(keystr: sender.keystr)
		rpn.x = StackElem(alpha: input.inputstring)
		ShowStack()
	}
	
	@objc func PreviewAction() {
		UIView.animate(withDuration: 2.0, animations: {
			self.visiblestackelems = 5 - self.visiblestackelems	//Toggles between 4 and 1
			self.LayoutStack()
			self.ShowStack()
		})
	}
	
	//Switch Layout when Switching beetween Landscape and Portrail Modud
	override func viewWillLayoutSubviews() {
		Layout()
	}
}

