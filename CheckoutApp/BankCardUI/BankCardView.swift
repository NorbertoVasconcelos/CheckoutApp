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
    @IBOutlet weak var securityCodeAlert: UIImageView!
    @IBOutlet weak var cardNumberAlert: UIImageView!
    @IBOutlet weak var expDateAlert: UIImageView!
    
    // MARK: Variables
    let disposeBag: DisposeBag = DisposeBag()
    var allValid: Observable<Bool>?
    var cardFlip: CardFlip = .front
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
        mutateActionButton()
    }
    
    // MARK: - Card Flip -
    public func flipCard(_ flip:CardFlip) {
        
        // Save the current flip
        cardFlip = flip
        
        switch flip {
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
                let isValid: Bool = self?.validateCardNumber(number: text ?? "") ?? false
                self?.cardNumberAlert.isHidden = isValid
                return isValid
            }
            .shareReplay(1)
        
        let validExpirationDate: Observable<Bool> = tfExpDate
            .rx
            .text
            .map {
                [weak self] text -> Bool in
                
                let date = self?.datifyString(text ?? "")
                self?.bankCard?.expirationDate = date
                if let d = date {
                    let isValid: Bool = self?.validateExpirationDate(date: d) ?? false
                    self?.expDateAlert.isHidden = isValid
                    return isValid
                }
                return false

            }
            .shareReplay(1)
        
        let validSecurityCode: Observable<Bool> = tfSecurityCode
            .rx
            .text
            .map {
                [weak self] text -> Bool in
                self?.bankCard?.cardSecurityCode = text
                let isValid: Bool = self?.validateSecurityCode(number: text ?? "") ?? false
                self?.securityCodeAlert.isHidden = isValid
                return isValid
            }
            .shareReplay(1)
        
         allValid = Observable.combineLatest(validCardNumber, validSecurityCode, validExpirationDate) { $0 && $1 && $2 }
        
        
        tfCardNum
            .rx
            .controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] in
                
                self?.allValid?.subscribe(onNext: { [weak self] isValid in
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
                
                self?.allValid?.subscribe(onNext: { [weak self] isValid in
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
    
    func datifyString(_ text: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yy"
        return dateFormatter.date(from: text)
    }
    
    // MARK: - Validations -
    func validateCardNumber(number:String) -> Bool {
        return number.characters.count > 5
    }
    
    func validateSecurityCode(number:String) -> Bool {
        return number.characters.count == 3
    }
    
    func validateExpirationDate(date: Date) -> Bool {
        return stringifyDate(date).characters.count > 0
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
        mutateActionButton()
    }
    
    func previous() {
        if tfExpDate.isEditing {
            tfCardNum.becomeFirstResponder()
        } else if tfSecurityCode.isEditing {
            flipCard(.front)
        }
        mutateActionButton()
    }
    
    func mutateActionButton() {
        let isCardFlipped = cardFlip == .back
        Observable.just(isCardFlipped).subscribe(toolbar!.btnBack.rx.isEnabled).addDisposableTo(disposeBag)
        toolbar?.btnContinue.image = isCardFlipped ? #imageLiteral(resourceName: "ic_check") : #imageLiteral(resourceName: "ic_arrow_right")
        allValid?
            .subscribe(onNext: { [weak self] areValid in
                if isCardFlipped {
                    self?.toolbar?.btnContinue.isEnabled = areValid
                } else {
                    self?.toolbar?.btnContinue.isEnabled = true
                }
                
                },
                       onError: { error in},
                       onCompleted: {},
                       onDisposed: {})
            .addDisposableTo(disposeBag)
        
    }

}
