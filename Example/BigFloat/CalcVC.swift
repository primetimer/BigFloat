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

enum KeyBoardView {
	case num, shift
	case alpha, alphashift
	case hex, hexshift
}

class CalcVC: UIViewController, ProtShowResult, StackInputDelegate {
	func InputHasStarted() {
		rpn.push()
	}
	
	func InputHasFinished() {
		let inputelem = input.GetStackElem()
		rpn.x = inputelem
		show.ShowStack()
	}
	
	private var buttonarr : [UIButton] = []
	private var show : StackShow!
	
	private var _keyboardview = KeyBoardView.num
	private var keyboardview : KeyBoardView {
		get { return _keyboardview }
		set {
			_keyboardview = newValue
			if inputmode == .prog { return }
			switch keyboardview  {
			case .num, .shift:
				inputmode = .number
			case .alpha,.alphashift:
				inputmode = .alpha
			case .hex,.hexshift:
				inputmode = .number //.hex
			}
			input.SetBase(base: base)
		}
	}
	private var _inputmode = StackInputType.number
	private var inputmode : StackInputType {
		get { return _inputmode }
		set {
			if newValue != _inputmode {
				_inputmode = newValue
				input.SetInputMode(mode: _inputmode)
			}
		}
	}
	private var base = 10
	private var input = StackInput()
	private var rpnlist : [RPNCalc] = [RPNCalc()]
	private var rpn : RPNCalc {
		get { return rpnlist[0] }
	}
	
	private func GetAlphaButton(key : Int) -> AlphaButton {
		for a in buttonarr {
			if let alpha = a as? AlphaButton {
				if alpha.key == key { return alpha}
			}
		}
		let a = AlphaButton(key : key)
		a.addTarget(self, action: #selector(AlphaAction), for: .touchUpInside)
		buttonarr.append(a)
		view.addSubview(a)
		return a
	}
	private func CreateSpecialButton(key : KeyBoardSpecialCmd) -> SpecialButton {
		let b = SpecialButton(key: key)
		buttonarr.append(b)
		view.addSubview(b)
		b.addTarget(self, action: #selector(SpecialAction), for: .touchUpInside)
		return b
	}
	private func CreateSpecialButtons() {
		_ = CreateSpecialButton(key: .back)
		_ = CreateSpecialButton(key: .undo)
		_ = CreateSpecialButton(key: .shift)
		_ = CreateSpecialButton(key: .alpha)
		_ = CreateSpecialButton(key: .prog)
		_ = CreateSpecialButton(key: .esc)
		_ = CreateSpecialButton(key: .preview)
		_ = CreateSpecialButton(key: .hex)
		_ = CreateSpecialButton(key: .info)
		_ = CreateSpecialButton(key: .clx)
	}
	private func GetSpecialButton(key: KeyBoardSpecialCmd) -> SpecialButton {
		for b in buttonarr {
			if let button = b as? SpecialButton {
				if button.cmd.cmd == key { return button }
			}
		}
		return CreateSpecialButton(key: key)
	}
	
	private func LinkButtons(b: CalcButton, shift: CalcButton) {
		b.shiftbutton = shift
		shift.unshiftbutton = b
	}
	
	private func CreateInputButton(str: String, cmd : NumInputCmd)  -> InputCmdButton {
		let b = InputCmdButton(cmd: cmd)
		buttonarr.append(b)
		view.addSubview(b)
		b.setTitle(str, for: .normal)
		b.addTarget(self, action: #selector(NumberAction), for: .touchUpInside)
		return b
	}
	private func GetInputButton(cmd : InputCmd) -> InputCmdButton {
		for b in buttonarr {
			if let button = b as? InputCmdButton {
				if button.cmd == cmd { return button }
			}
		}
		let numcmd = cmd as! NumInputCmd
		return CreateInputButton(str: String(numcmd.key),cmd: numcmd)
	}
	
	//Create Button for Calc Action
	private func CreateCalcButton(str: String, type : RPNCalcCmd) -> CalcButton {
		let b = CalcButton(type: type)
		buttonarr.append(b)
		view.addSubview(b)
		b.setTitle(str, for: .normal)
		b.addTarget(self, action: #selector(CalcAction), for: .touchUpInside)
		return b
	}
	func CreateCalcButton(type : RPNCalcCmd) -> CalcButton {
		let str = type.description
		return CreateCalcButton(str: str,type: type)
	}
	private func GetCalcButton(type : RPNCalcCmd) -> CalcButton {
		for b in buttonarr {
			if let button = b as? CalcButton {
				if button.type == type { return button }
			}
		}
		return CreateCalcButton(type : type)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.TimerUpdate), userInfo: nil, repeats: true)
		show.ShowStack()
		ShowButtons()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		show = StackShow(vc: self, rpn: rpn, input: input)
		input.inputdelegate = self
		self.view.backgroundColor = UIColor.black
		
		
		
		
		_ = CreateInputButton(str: ".", cmd:  NumInputCmd(type: .punct))
		_ = CreateInputButton(str: "EE", cmd: NumInputCmd(type: .ee))
		_ = CreateInputButton(str: "+/-", cmd: NumInputCmd(type: .chs))

		
		//LinkButtons(b: GetSpecialButton(key: .preview), shift: GetSpecialButton(key: .hex))
		LinkButtons(b: GetCalcButton(type: .Sin), shift: GetCalcButton(type: .aSin))
		LinkButtons(b: GetCalcButton(type: .Cos), shift: GetCalcButton(type: .aCos))
		LinkButtons(b: GetCalcButton(type: .Tan), shift: GetCalcButton(type: .aTan))
		LinkButtons(b: GetCalcButton(type: .sqrt), shift: GetCalcButton(type: .crt))
		LinkButtons(b: GetCalcButton(type: .TenPow), shift: GetCalcButton(type: .log))
		LinkButtons(b: GetCalcButton(type: .exp), shift: GetCalcButton(type: .ln))
		LinkButtons(b: GetCalcButton(type: .CmdC), shift: GetCalcButton(type: .CmdV))
		LinkButtons(b: GetCalcButton(type: .lower), shift: GetCalcButton(type: .lowerequal))
		LinkButtons(b: GetCalcButton(type: .greater), shift: GetCalcButton(type: .greaterequal))
		LinkButtons(b: GetCalcButton(type: .equal), shift: GetCalcButton(type: .unequal))
		
		
		LinkButtons(b: GetInputButton(cmd: NumInputCmd(digit : 3)), shift: GetCalcButton(type: .pi))
		LinkButtons(b: GetInputButton(cmd: NumInputCmd(digit : 4)), shift: GetCalcButton(type: .sqrt2))
		LinkButtons(b: GetInputButton(cmd: NumInputCmd(digit : 0)), shift: GetCalcButton(type: .ln2))
		LinkButtons(b: GetInputButton(cmd: NumInputCmd(digit : 2)), shift: GetCalcButton(type: .exp1))
		
		//LinkButtons(b: GetInputButton(cmd: .ee), shift: GetS
		//LinkButtons(b: GetSpecialButton(key: .enter) , shift: GetSpecialButton(key: .preview))
		Layout()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	//Digit Buttons
	//private var ui_num : [InputButton] = []
	
	
	
	//Size of the Number and Action depending on landscape or portrait mode and device type
	private func GetNumpadFrameWidth() -> CGFloat
	{
		if !view.landscape { return show.StackWidth() }
		return self.view.frame.width - show.StackWidth()
	}
	
	private func LayoutButtonRaster(row : Int, col : Int, button: UIButton, numcols : Int = 1) {
		let w = GetNumpadFrameWidth()
		let h = view.frame.height
		let x0 = view.landscape ? show.StackWidth() + 20 : 20
		let row0 = view.landscape ? 4 : 0
		let parts = 12 - row0
		let wpart = (w-40) / 6
		let hpart = (h-40) / CGFloat(parts)
		let x = x0 + CGFloat(col) * wpart
		let y = 20 + CGFloat(row-row0) * hpart
		let rect = CGRect(x: x, y: y, width: wpart*CGFloat(numcols), height: hpart)
		button.frame = rect
	}
	
	
	
	
	
	//All UI-Elements are manual layouted, not via storyboard
	private func Layout() {
		show.LayoutStack()
		
		
		var row = 11
		LayoutButtonRaster(row: row, col: 0, button: GetSpecialButton(key: .shift))
		LayoutButtonRaster(row:row, col: 1, button: GetSpecialButton(key: .enter),numcols: 2)
		LayoutButtonRaster(row:row, col: 3, button: GetInputButton(cmd: NumInputCmd(type: .ee)))
		LayoutButtonRaster(row:row, col: 4, button: GetCalcButton(type: .CmdC))
		LayoutButtonRaster(row:row, col: 5, button: GetSpecialButton(key: .info))
		row = row - 1
		LayoutButtonRaster(row:row, col: 0, button: GetCalcButton(type: .LastX))
		LayoutButtonRaster(row:row, col: 1, button: GetInputButton(cmd: NumInputCmd(digit : 0)))
		LayoutButtonRaster(row:row, col: 2, button: GetInputButton(cmd: NumInputCmd(type: .punct)))
		LayoutButtonRaster(row:row, col: 3, button: GetInputButton(cmd: NumInputCmd(type: .chs)))
		LayoutButtonRaster(row:row, col: 4, button: GetCalcButton(type: .Plus))
		LayoutButtonRaster(row:row, col: 5, button: GetCalcButton(type: .Sto))
		row = row - 1
		LayoutButtonRaster(row:row, col: 1, button: GetInputButton(cmd: NumInputCmd(digit : 1)))
		LayoutButtonRaster(row:row, col: 2, button: GetInputButton(cmd: NumInputCmd(digit : 2)))
		LayoutButtonRaster(row:row, col: 3, button: GetInputButton(cmd: NumInputCmd(digit : 3)))
		LayoutButtonRaster(row:row, col: 4, button: GetCalcButton(type: .Minus))
		LayoutButtonRaster(row:row, col: 5, button: GetCalcButton(type: .Rcl))
		
		row = row - 1
		LayoutButtonRaster(row:row, col: 0, button: GetCalcButton(type: .Swap))
		LayoutButtonRaster(row:row, col: 1, button: GetInputButton(cmd: NumInputCmd(digit : 4)))
		LayoutButtonRaster(row:row, col: 2, button: GetInputButton(cmd: NumInputCmd(digit : 5)))
		LayoutButtonRaster(row:row, col: 3, button: GetInputButton(cmd: NumInputCmd(digit : 6)))
		LayoutButtonRaster(row:row, col: 4, button: GetCalcButton(type: .Prod))
		LayoutButtonRaster(row:row, col: 5, button: GetCalcButton(type: .TenPow))
		
		row = row - 1
		LayoutButtonRaster(row:row, col: 0, button: GetCalcButton(type: .Pop))
		LayoutButtonRaster(row:row, col: 1, button: GetInputButton(cmd: NumInputCmd(digit : 7)))
		LayoutButtonRaster(row:row, col: 2, button: GetInputButton(cmd: NumInputCmd(digit : 8)))
		LayoutButtonRaster(row:row, col: 3, button: GetInputButton(cmd: NumInputCmd(digit : 9)))
		LayoutButtonRaster(row:row, col: 4, button: GetCalcButton(type: .Divide))
		LayoutButtonRaster(row:row, col: 5, button: GetCalcButton(type: .exp))
		
		row = row - 1
		LayoutButtonRaster(row:row, col: 0, button: GetCalcButton(type: .Inv))
		LayoutButtonRaster(row:row, col: 1, button: GetCalcButton(type: .Pow))
		LayoutButtonRaster(row:row, col: 2, button: GetCalcButton(type: .sqrt))
		LayoutButtonRaster(row:row, col: 3, button: GetCalcButton(type: .Sin))
		LayoutButtonRaster(row:row, col: 4, button: GetCalcButton(type: .Cos))
		LayoutButtonRaster(row:row, col: 5, button: GetCalcButton(type: .Tan))
		
		row = row - 1
		//LayoutButtonRaster(row:row, col: 0, button: GetProgButton(type: .ifcond))
		//LayoutButtonRaster(row:row, col: 1, button: GetProgButton(type: .thencond))
		LayoutButtonRaster(row:row, col: 3, button: GetCalcButton(type: .lower))
		LayoutButtonRaster(row:row, col: 4, button: GetCalcButton(type: .greater))
		LayoutButtonRaster(row:row, col: 5, button: GetCalcButton(type: .equal))
		
		row = row - 1
		LayoutButtonRaster(row:row, col: 0, button: GetSpecialButton(key: .alpha))
		LayoutButtonRaster(row:row, col: 1, button: GetSpecialButton(key: .prog))
		LayoutButtonRaster(row:row, col: 3, button: GetSpecialButton(key: .preview))
		LayoutButtonRaster(row:row, col: 2, button: GetSpecialButton(key: .hex))
		LayoutButtonRaster(row:4, col: 4, button: GetSpecialButton(key: .esc))
		LayoutButtonRaster(row:4, col: 4, button: GetSpecialButton(key: .undo))
		LayoutButtonRaster(row:row, col: 5, button: GetSpecialButton(key: .back))
		LayoutButtonRaster(row:row, col: 5, button: GetSpecialButton(key: .clx))
		
		
		
		//Layout Shifted Buttons {
		for b in buttonarr {
			if let button = b as? CalcButton {
				button.shiftbutton?.frame = b.frame
			}
		}
		LayoutAlpha()
	}
	
	private func LayoutAlpha() {
		for key in 65 ... 90 {
			let row = 4 + (key - 65 + 6) / 6
			let col = (key - 65 + 6 ) % 6
			let b = GetAlphaButton(key: key)
			LayoutButtonRaster(row: row, col: col, button: b)
		}
		for keynum in 48 ... 57 {
			let key = 90 - 65 + 6 + keynum - 48 + 1
			let row = 4 + key  / 6
			let col = key % 6
			let b = GetAlphaButton(key: keynum)
			LayoutButtonRaster(row: row, col: col, button: b)
		}
		do {
			let b = GetAlphaButton(key: 32)
			b.setTitle("SPC", for: .normal)
			LayoutButtonRaster(row: 11, col: 3, button: b, numcols: 2)
		}
		do {
			let b = GetAlphaButton(key: 59)	//Semikolon
			b.setTitle(";", for: .normal)
			LayoutButtonRaster(row: 4, col: 3, button: b)
		}
		
	}
	
	//This timer is used for a blinking busy signal
	private var timer : Timer? = nil
	private var timertoggle : Bool = false
	@objc func TimerUpdate() {
		GetSpecialButton(key: .esc).isHidden = asynccalc != nil ? false : true
		GetSpecialButton(key: .undo).isHidden = asynccalc != nil ? true : false
		timertoggle = asynccalc != nil ? !timertoggle : false
		show.uistate.textColor = timertoggle ? .gray : .red
	}
	
	
	
	
	//UI Related Display of the Action-Pad
	private func ShowButtons(clear : Bool = false) {
		if clear {
			//keyboardview = .num
			asynccalc?.cancel()
			asynccalc = nil
		}
			
		do {
			let uipreview = self.GetSpecialButton(key: .preview)
			if show.visible == 1 {
				uipreview.setTitleColor(.red,for: .normal)
			}
			else {
				uipreview.setTitleColor(.white, for: .normal)
			}
		}
		do {
			let b = GetSpecialButton(key: .hex)
			if base == 16 {
				b.setTitleColor(.red, for: .normal)
			} else	{
				b.setTitleColor(.white, for: .normal)
			}
		}
		do {
			let b = GetSpecialButton(key: .shift)
			if keyboardview == .alphashift || keyboardview == .shift {
				b.setTitleColor(.red, for: .normal)
			} else	{
				b.setTitleColor(.white, for: .normal)
			}
		}
		do {
			let b = GetSpecialButton(key: .prog)
			if inputmode == .prog {
				b.setTitleColor(.red, for: .normal)
			} else	{
				b.setTitleColor(.white, for: .normal)
			}
		}
		do {
			let b = GetSpecialButton(key: .alpha)
			if keyboardview == .alpha || keyboardview == .alphashift {
				b.setTitleColor(.red, for: .normal)
			} else	{
				b.setTitleColor(.white, for: .normal)
			}
		}
		
		switch keyboardview {
		case .alpha, .alphashift:
			for b in buttonarr {
				b.isHidden = true
				if b is AlphaButton { b.isHidden = false }
				if b is SpecialButton { b.isHidden = false}
			}
			GetSpecialButton(key: .back).isHidden = false
			GetSpecialButton(key: .clx).isHidden = true
		case .shift:
			for b in buttonarr {
				b.isHidden = true
				
				if let button = b as? CalcButton {
					if button.unshiftbutton != nil { b.isHidden = false }
					if button.shiftbutton == nil { b.isHidden = false }
				}
				GetSpecialButton(key: .back).isHidden = true
				GetSpecialButton(key: .clx).isHidden = false
			}
		case .num:
			for b in buttonarr {
				b.isHidden = true
				if let button = b as? CalcButton {
					if button.unshiftbutton == nil { b.isHidden = false }
				}
				if b is ProgButton {
					b.isHidden = true
				}
			}
			GetSpecialButton(key: .back).isHidden = false
			GetSpecialButton(key: .enter).isHidden = false
			GetSpecialButton(key: .clx).isHidden = true
		case .hex:
			for b in buttonarr {
				b.isHidden = true
				if let calc = b as? CalcButton {
					if calc.unshiftbutton == nil { b.isHidden = false }
				}
				if b is ProgButton {
					b.isHidden = true
				}
				if let alpha = b as? AlphaButton {
					if alpha.key >= 65 && alpha.key <= 65+5 {
						alpha.isHidden = false
					}
				}
			}
			GetSpecialButton(key: .back).isHidden = false
			GetSpecialButton(key: .enter).isHidden = false
			GetSpecialButton(key: .clx).isHidden = true
		case .hexshift:
			for b in buttonarr {
				b.isHidden = true
				if let calc = b as? CalcButton {
					if calc.unshiftbutton == nil { b.isHidden = false }
				}
				if let alpha = b as? AlphaButton {
					if alpha.key >= 65 && alpha.key <= 65+5 {
						alpha.isHidden = false
					}
				}
				if let num = b as? InputCmdButton {
					num.isHidden = false
				}
			}
			
			GetSpecialButton(key: .back).isHidden = false
			GetSpecialButton(key: .enter).isHidden = false
			GetSpecialButton(key: .clx).isHidden = true
		}
		GetSpecialButton(key: .hex).isHidden = false
		GetSpecialButton(key: .prog).isHidden = false
		GetSpecialButton(key: .shift).isHidden = false
		GetSpecialButton(key: .esc).isHidden = asynccalc != nil ? false : true
		GetSpecialButton(key: .undo).isHidden = asynccalc != nil ? true : false
	}
	
	//When the Calculation ist started this variable is not nil
	var asynccalc : AsyncCalc? = nil
	
	//Executing all Calculation triggered by Buttons
	@objc func CalcAction(sender: CalcButton!)
	{
		if isInfo {
			show.ShowInfoText(type: sender.type)
			
			return
		}
		if inputmode == .prog {
			input.SendCmd(cmd: ProgInputCmd(rpncmd: sender.type))
			show.ShowStack()
			return
		}
		input.Finish()
		StartCalculation(cmd: sender.type)
	}
		
	private func StartCalculation(cmd: RPNCalcCmd) {
		
		//Create Copy of Stack for undo action
		rpnlist.insert(rpn.Copy(), at: 1)
		while rpnlist.count > 10 { rpnlist.remove(at: 10)}
		
		switch inputmode {
		case .prog:
			show.ShowStack()
		case .number: //,.hex:
			asynccalc?.cancel()		//Try to cancels previous action s
			rpn.stackstate = .busy	//Blinks in Stackview as long as the calculation needs
			show.ShowStackState()
			//Calculation runs asynchrous (as best as i can)
			let queue = OperationQueue()
			asynccalc = AsyncCalc(rpn: rpn, type: cmd)
			show.ShowStackState()
			asynccalc?.resultdelegate = self
			queue.addOperation(asynccalc!)
		case .alpha:
			show.ShowStack()
		case .none:
			break
		}
			
	}
	
	//Called by asynchronous Calculation on main thread
	internal func ShowCalcResult() {
		asynccalc = nil
		input.Finish()
		show.ShowStack()
		self.ShowButtons(clear : true)
	}
	
	//Try to stop all pending Calculations. Rely on cooperative design of calculation
	private func EscapeAction() {
		asynccalc?.cancel()
		asynccalc = nil
		rpn.stackstate = .cancelled
		ShowButtons()
		show.ShowStackState()
		show.ShowStack()
	}
	
	//Some useless information about the buttons in the ui
	private var isInfo : Bool = false
	@objc func InfoAction(sender: UIButton!) {
		
	}
	
	@objc func SpecialAction(sender : SpecialButton) {
		switch sender.cmd.cmd {
		case .shift:
			switch keyboardview {
			case .num:
				keyboardview = .shift
			case .alpha:
				keyboardview = .alphashift
			case .shift:
				keyboardview = .num
			case .alphashift:
				keyboardview = .alpha
			case .hex:
				keyboardview = .hexshift
			case .hexshift:
				keyboardview = .hex
			}
		case .prog:
			inputmode = inputmode == .prog ? .none : .prog
		case .alpha:
			switch keyboardview {
			case .num,.hex,.hexshift:
				keyboardview = .alpha
			case .alpha:
				keyboardview = base == 10 ? .num : .hex
			case .shift:
				keyboardview = .alphashift
			case .alphashift:
				keyboardview = base == 10 ? .shift : .hexshift
			}
		case .hex:
			input.Finish()
			base = 10 + 16 - base
			keyboardview = base == 16 ? .hex : .num
		case .enter:
			if inputmode == .prog {
				input.SendCmd(cmd: ProgInputCmd(type: .enter))
				show.ShowStack()
				return
			}
			
			switch rpn.x.type {
			case .ProgCmd, .ProgLine:
				let forth = ForthExecuter(rpn: rpn)
				forth.Execute()
			
			case .BigInt, .BigFloat, .Alpha, .Unknown:
				if input.IsFinished() {
					rpn.push()
				}
				input.Finish()
			}
			
			//if keyboardview != .prog { 	keyboardview = .num }
			
		case .preview:
			PreviewAction()
			
		case .esc:
			EscapeAction()
			
		case .back:
			input.Back()
			
		case .clx:
			input.Finish()
			ClearAction()
			
		case .undo:
			if asynccalc == nil && rpnlist.count > 1 {
				rpnlist.removeFirst()
			}
		case .none, .info:
			print("Not implemented: Never come here")
		
		}
		show.ShowStack()
		ShowButtons()
	}
	//Actions for Number Input and related Actions
	@objc func NumberAction(sender: InputCmdButton!) {
		if inputmode == .prog {
			input.SendCmd(cmd: ProgInputCmd(numcmd: sender.cmd))
			show.ShowStack()
			return
		}
		if input.IsFinished() && (sender.cmd.type == .chs)  {
			StartCalculation(cmd: .negate)
		} else {
			input.SendCmd(cmd: sender.cmd)
			rpn.stackstate = .valid
		}
		show.ShowStack()
	}
	
	@objc func AlphaAction(sender: AlphaButton!) {
		if inputmode == .prog {
			input.SendCmd(cmd: ProgInputCmd(alpcmd: sender.alphacmd))
			show.ShowStack()
			return
		}
		if keyboardview == .hex || keyboardview == .hexshift {
			if sender.alphacmd.key >= 65 && sender.alphacmd.key <= 65+5 {
				let numcmd = NumInputCmd(digit: sender.alphacmd.key-65+10)
				input.SendCmd(cmd: numcmd)
			}
		} else {
			input.SendCmd(cmd: sender.alphacmd)
		}
		rpn.stackstate = .valid
		show.ShowStack()
	}
	
	//Deletes Stack completelye
	private func ClearAction() {
		rpn.Clear()
		while rpnlist.count > 1 {	rpnlist.remove(at: 1) }
		show.ShowStack()
		ShowButtons(clear: true)
	}
	
	private func PreviewAction() {
		UIView.animate(withDuration: 2.0, animations: {
			self.show.visible = 5 - self.show.visible	//Toggles between 4 and 1
			self.show.LayoutStack()
			self.show.ShowStack()
		})
	}
	
	//Switch Layout when Switching beetween Landscape and Portrail Modud
	override func viewWillLayoutSubviews() {
		Layout()
	}
}

