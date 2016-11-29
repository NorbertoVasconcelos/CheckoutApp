//
//  CustomTextField.swift
//  CheckoutApp
//
//  Created by Norberto Vasconcelos on 25/11/16.
//  Copyright © 2016 Norberto. All rights reserved.
//

import UIKit

public class CustomTextField: UITextField, KeyboardDelegate {
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.tintColor = UIColor.emerald
        initKeyboard()
    }
    required override public init(frame: CGRect) {
        super.init(frame: frame)
        self.tintColor = UIColor.emerald
        initKeyboard()
    }
    
    func initKeyboard() {
        // initialize custom keyboard
        let keyboardView = Keyboard(frame: CGRect(x: 0, y: 0, width: 0, height: 216))
        keyboardView.delegate = self
        
        // replace system keyboard with custom keyboard
        self.inputView = keyboardView
    }
    
    
    func keyWasTapped(character: String) {
        // Define Keyboard Action
        switch character {
        case KeyboardAction.backspace.rawValue:
            if let text = self.text, text.characters.count > 0 {
                self.text = text.substring(to: text.index(before: text.endIndex))
            }
            break
        case KeyboardAction.delete.rawValue:
            self.text = ""
            break
        default:
            self.insertText(character)
        }
    }
}
