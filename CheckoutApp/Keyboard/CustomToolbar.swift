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
    
    // -----------------------------------------
    // MARK: - Initializers
    // -----------------------------------------
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    func setup() {
        self.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        self.setShadowImage(UIImage(), forToolbarPosition: .any)
        
        
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if let font = UIFont(name: "Thonburi-Bold", size: 16.0) {
            btnContinue.setTitleTextAttributes([NSFontAttributeName: font], for: UIControlState.normal)
        }
        
        if let font = UIFont(name: "Thonburi-Light", size: 16.0) {
            btnBack.setTitleTextAttributes([NSFontAttributeName: font], for: UIControlState.normal)
        }
    }

}
