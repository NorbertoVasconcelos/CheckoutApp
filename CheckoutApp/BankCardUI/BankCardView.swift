//
//  BankCardView.swift
//  CheckoutApp
//
//  Created by Norberto Vasconcelos on 28/11/16.
//  Copyright © 2016 Norberto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

// Card flip types
enum CardFlip {
    case front
    case back
}

class BankCardView: UIView {
    
    // MARK: Outlets
    @IBOutlet weak var imgBank: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var tfSecurityCode: CustomTextField!
    @IBOutlet weak var tfExpDate: CustomTextField!
    @IBOutlet weak var tfCardNum: CustomTextField!
    @IBOutlet weak var front: UIView!
    @IBOutlet weak var back: UIView!
    
    // MARK: Variables
    let disposeBag: DisposeBag = DisposeBag()
    var cardFlip: CardFlip?
    var bankCard: BankCard?
    var toolbar: CustomToolbar? = UINib(nibName: "CustomToolbar", bundle: nil).instantiate(withOwner: nil, options: nil).first as? CustomToolbar
    var currentResponder: UITextField?
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "BankCardFront", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.setup()
        if let t = toolbar {
            self.setupInputAccessoryViews(toolbar: t)
        }
    }
    
    // MARK: - Card Flip -
    public func flipCard(_ flip:CardFlip) {
        
        // Save the current flip
        self.cardFlip = flip
        
        // Guarantee a flip exists
        guard let cf = self.cardFlip else { return }
        
        switch cf {
        case .front:
            UIView
                .transition(from: back,
                            to: front,
                            duration: 0.6,
                            options: [.transitionFlipFromLeft, .showHideTransitionViews],
                            completion: {
                                [weak self] (Bool) -> Void in

                                self?.tfCardNum.becomeFirstResponder()
                })
            break
        case .back:
            UIView
                .transition(from: front,
                            to: back,
                            duration: 0.6,
                            options: [.showHideTransitionViews, .transitionFlipFromRight],
                            completion: {
                                [weak self] (Bool) -> Void in
                                self?.tfSecurityCode.becomeFirstResponder()
                })
            break
        }
    }
    
    // MARK: - Setup -
    func setup() {
        
        if bankCard == nil {
            bankCard = BankCard()
        }
        
        tfCardNum.becomeFirstResponder()
        setDatePicker()
        
        let validCardNumber: Observable<Bool> = tfCardNum
            .rx
            .text
            .map {
                [weak self] text -> Bool in
                self?.bankCard?.cardNumber = text
                return self?.validateCardNumber(number: text ?? "") ?? false
            }
            .shareReplay(1)
        
        let validExpirationDate: Observable<Bool> = tfExpDate
            .rx
            .text
            .map {
                [weak self] text -> Bool in
//                self?.bankCard?.expirationDate = text
//                return self?.validateExpirationDate(date: text ?? "") ?? false
                return true
            }
            .shareReplay(1)
        
        let validSecurityCode: Observable<Bool> = tfSecurityCode
            .rx
            .text
            .map {
                [weak self] text -> Bool in
                self?.bankCard?.cardSecurityCode = text
                return self?.validateSecurityCode(number: text ?? "") ?? false
            }
            .shareReplay(1)
        
        let allValid: Observable<Bool>
            = Observable.combineLatest(validCardNumber, validSecurityCode, validExpirationDate) { $0 && $1 && $2 }
        
        
        tfCardNum
            .rx
            .controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] in
                
                allValid.subscribe(onNext: { [weak self] isValid in
                    self?.bankCard?.validCard = true
                    },
                                   onError: { error in},
                                   onCompleted: {},
                                   onDisposed: {})
                    .addDisposableTo(self?.disposeBag ?? DisposeBag())
                
                self?.tfExpDate.becomeFirstResponder()
                },
                       onError: { error in},
                       onCompleted: {},
                       onDisposed: {})
            .addDisposableTo(disposeBag)
        
        tfExpDate
            .rx
            .controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] in
                
                allValid.subscribe(onNext: { [weak self] isValid in
                    self?.bankCard?.validCard = true
                    },
                                   onError: { error in},
                                   onCompleted: {},
                                   onDisposed: {})
                    .addDisposableTo(self?.disposeBag ?? DisposeBag())
                
                if let num = self?.tfCardNum.text, let result = self?.validateCardNumber(number: num), result {
                    self?.flipCard(.back)
                }
                },
                       onError: { error in},
                       onCompleted: {},
                       onDisposed: {})
            .addDisposableTo(disposeBag)
        
        tfSecurityCode
            .rx
            .controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] in
                if let num = self?.tfSecurityCode.text, let result = self?.validateSecurityCode(number: num), result {
                    self?.flipCard(.front)
                }
                },
                       onError: { error in},
                       onCompleted: {},
                       onDisposed: {})
            .addDisposableTo(disposeBag)
        
    }
    
    func setupInputAccessoryViews(toolbar: CustomToolbar) {
        tfCardNum.inputAccessoryView = toolbar
        tfExpDate.inputAccessoryView = toolbar
        tfSecurityCode.inputAccessoryView = toolbar
    }
    
    // MARK: - DatePicker - 
    func setDatePicker() {
        
        
        tfExpDate
            .rx
            .controlEvent(.editingDidBegin)
            .subscribe(onNext: { [weak self] in
                let datePickerView:UIDatePicker = UIDatePicker()
                datePickerView.backgroundColor = UIColor.emerald
                datePickerView.setValue(UIColor.white, forKey: "textColor")
                datePickerView.datePickerMode = UIDatePickerMode.date
                self?.tfExpDate.inputView = datePickerView
                datePickerView
                    .rx
                    .date
                    .bindNext({
                        [weak self] date in
                        self?.bankCard?.expirationDate = date
                        self?.tfExpDate.text = self?.stringifyDate(date)
                    })
                    .addDisposableTo(self?.disposeBag ?? DisposeBag())
                
                },
                       onError: { error in},
                       onCompleted: {},
                       onDisposed: {})
            .addDisposableTo(disposeBag)
        
    
    }
    
    func stringifyDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yy"
        return dateFormatter.string(from: date)
    }
    
    // MARK: - Validations -
    func validateCardNumber(number:String) -> Bool {
        return number.characters.count > 5
    }
    
    func validateSecurityCode(number:String) -> Bool {
        return number.characters.count == 3
    }
    
    func validateExpirationDate(date: Date) -> Bool {
        return true
    }
    
    // MARK: - Actions - 
    func next() {
        if tfCardNum.isEditing {
            tfExpDate.becomeFirstResponder()
        } else if tfExpDate.isEditing {
            flipCard(.back)
        } else if tfSecurityCode.isEditing {
            flipCard(.front)
        }
    }
    
    func previous() {
        if tfExpDate.isEditing {
            tfCardNum.becomeFirstResponder()
        } else if tfSecurityCode.isEditing {
            flipCard(.front)
            tfExpDate.becomeFirstResponder()
        }
    }

}
