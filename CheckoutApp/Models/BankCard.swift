//
//  BankCard.swift
//  CheckoutApp
//
//  Created by Norberto Vasconcelos on 25/11/16.
//  Copyright © 2016 Norberto. All rights reserved.
//

import Foundation

struct BankCard {
    var name: String
    var expirationDate: Date?
    var cardNumber: String?
    var cardSecurityCode: String?
    var validCard: Bool?
    
    init() {
        self.name = "Norberto Vasconcelos"
    }
}
