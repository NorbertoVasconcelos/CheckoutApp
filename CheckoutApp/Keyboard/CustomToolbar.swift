//
//  CustomToolbar.swift
//  CheckoutApp
//
//  Created by Norberto Vasconcelos on 29/11/16.
//  Copyright © 2016 Norberto. All rights reserved.
//

import UIKit

class CustomToolbar: UIToolbar {

    @IBOutlet weak var btnBack: UIBarButtonItem!
    @IBOutlet weak var btnContinue: UIBarButtonItem!
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "CustomToolbar", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }

}
