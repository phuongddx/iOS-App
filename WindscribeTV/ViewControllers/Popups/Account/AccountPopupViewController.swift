//
//  AccountPopupViewController.swift
//  WindscribeTV
//
//  Created by Andre Fonseca on 03/09/2024.
//  Copyright © 2024 Windscribe. All rights reserved.
//

import RxSwift
import UIKit

class AccountPopupViewController: BasePopUpViewController {
    var accountPopupViewModel: AccountPopupModelType!

    var actionButton = WSPillButton()
    var cancelButton = WSPillButton()

    @IBOutlet var imageView: UIImageView!

    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        logger?.logD(self, "Displaying Account Popup View")
        bindViews()
    }

    // MARK: Setting up

    override func setup() {
        super.setup()
        titleLabel?.text = ""
        headerLabel.isHidden = false
        for item in [actionButton, cancelButton] {
            item.setup(withHeight: 96.0)
            mainStackView.addArrangedSubview(item)
        }
        mainStackView.addArrangedSubview(UIView())
    }

    private func bindViews() {
        accountPopupViewModel.imageName.subscribe(onNext: { [self] in
            imageView.image = UIImage(named: $0)
        }).disposed(by: disposeBag)
        accountPopupViewModel.title.subscribe(onNext: { [self] in
            headerLabel?.text = $0
        }).disposed(by: disposeBag)
        accountPopupViewModel.description.subscribe(onNext: { [self] in
            bodyLabel.text = $0
        }).disposed(by: disposeBag)

        accountPopupViewModel.actionButtonTitle.subscribe(onNext: { [self] in
            actionButton.setTitle($0, for: .normal)
            cancelButton.isHidden = $0.isEmpty
        }).disposed(by: disposeBag)
        accountPopupViewModel.cancelButtonTitle.subscribe(onNext: { [self] in
            cancelButton.setTitle($0, for: .normal)
            cancelButton.isHidden = $0.isEmpty
        }).disposed(by: disposeBag)

        actionButton.rx.primaryAction.bind { [self] in
            accountPopupViewModel.action(viewController: self)
        }.disposed(by: disposeBag)
        cancelButton.rx.primaryAction.bind { [self] in
            dismiss(animated: true)
        }.disposed(by: disposeBag)
    }
}

class BannedAccountPopupViewController: AccountPopupViewController {}
class OutOfDataAccountPopupViewController: AccountPopupViewController {}
class ProPlanExpiredAccountPopupViewController: AccountPopupViewController {}
