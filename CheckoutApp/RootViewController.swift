//
//  RootViewController.swift
//  CheckoutApp
//
//  Created by Norberto Vasconcelos on 25/11/16.
//  Copyright © 2016 Norberto. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class RootViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var cardContainerView: UIView!
    
    let disposeBag: DisposeBag = DisposeBag()
    var bankCardView: BankCardView?

    override func viewDidLoad() {
        super.viewDidLoad()
                // Add BankCard
        bankCardView = BankCardView.instanceFromNib() as? BankCardView
        if let bcv = bankCardView {
            self.cardContainerView.addSubview(bcv)
            toolbarActions()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func toolbarActions() {
        if let bcv = bankCardView {
            bcv.toolbar?
                .btnContinue
                .rx
                .tap
                .subscribe(onNext: { _ in
                    bcv.next()
                },
                           onError: { error in},
                           onCompleted: {},
                           onDisposed: {})
                .addDisposableTo(disposeBag)
            
            bcv.toolbar?
                .btnBack
                .rx
                .tap
                .subscribe(onNext: { _ in
                    bcv.previous()
                },
                           onError: { error in},
                           onCompleted: {},
                           onDisposed: {})
                .addDisposableTo(disposeBag)
        }
    }

}

