//
//  Keyboard.swift
//  CheckoutApp
//
//  Created by Norberto Vasconcelos on 25/11/16.
//  Copyright © 2016 Norberto. All rights reserved.
//

import UIKit

enum KeyboardAction: String {
    case backspace = "backspace"
    case delete = "delete"
}

// The view controller will adopt this protocol (delegate)
// and thus must contain the keyWasTapped method
protocol KeyboardDelegate: class {
    func keyWasTapped(character: String)
}

class Keyboard: UIView {
    
    // This variable will be set as the view controller so that
    // the keyboard can send messages to the view controller.
    weak var delegate: KeyboardDelegate?
    
    // MARK:- keyboard initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeSubviews()
    }
    
    func initializeSubviews() {
        let xibFileName = "NumKeyboard" // xib extention not included
        let view = Bundle.main.loadNibNamed(xibFileName, owner: self, options: nil)?[0] as! UIView
        self.addSubview(view)
        view.frame = self.bounds
    }
    
    // MARK:- Button actions from .xib file
    
    @IBAction func keyTapped(sender: UIButton) {
        // When a button is tapped, send that information to the
        // delegate (ie, the view controller)
        if let text = sender.titleLabel?.text {
            self.delegate?.keyWasTapped(character: text)
        } else {
            switch sender.tag {
            case -1:
                self.delegate?.keyWasTapped(character: KeyboardAction.backspace.rawValue)
                break
            case -2:
                self.delegate?.keyWasTapped(character: KeyboardAction.delete.rawValue)
                break
            default:
                break
            }
        }
    }
    
}

