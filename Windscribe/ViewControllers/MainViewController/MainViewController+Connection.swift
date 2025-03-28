//
//  MainViewController+Connection.swift
//  Windscribe
//
//  Created by Thomas on 05/11/2021.
//  Copyright © 2021 Windscribe. All rights reserved.
//

import CoreLocation
import Foundation
import NetworkExtension
import RxSwift
import UIKit

extension MainViewController {
    @objc func trustedNetworkValueLabelTapped() {
        if trustedNetworkValueLabel.text == TextsAsset.NetworkSecurity.unknownNetwork {
            locationManagerViewModel.requestLocationPermission {
                self.viewModel.updateSSID()
            }
        } else {
            viewModel.markBlurNetworkName(isBlured: !viewModel.isBlurNetworkName)
            if viewModel.isBlurNetworkName {
                trustedNetworkValueLabel.isBlurring = true
            } else {
                trustedNetworkValueLabel.isBlurring = false
            }
        }
    }

    @objc func yourIPValueLabelTapped() {
        viewModel.markBlurStaticIpAddress(isBlured: !viewModel.isBlurStaticIpAddress)
        if viewModel.isBlurStaticIpAddress {
            yourIPValueLabel.isBlurring = true
        } else {
            yourIPValueLabel.isBlurring = false
        }
    }

    func renderBlurSpacedLabel() {
        if viewModel.isBlurNetworkName {
            trustedNetworkValueLabel.isBlurring = true
        } else {
            trustedNetworkValueLabel.isBlurring = false
        }
        if viewModel.isBlurStaticIpAddress {
            yourIPValueLabel.isBlurring = true
        } else {
            yourIPValueLabel.isBlurring = false
        }
    }

    func showSecureIPAddressState(ipAddress: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let label = self.yourIPValueLabel else { return }
            let formattedIP = ipAddress.formatIpAddress().maxLength(length: 15)
            UIView.animate(withDuration: 0.25) {
                label.text = formattedIP.isEmpty ? "---.---.---.---" : formattedIP
            }
        }
    }

    func setNetworkSsid() {
        Observable.combineLatest(viewModel.updateSSIDTrigger, viewModel.appNetwork)
            .subscribe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (_, network) in
                guard let self = self else { return }
                guard !self.vpnConnectionViewModel.isConnecting() else { return }
                guard !vpnConnectionViewModel.isNetworkCellularWhileConnecting(for: network) else { return }
                if self.locationManagerViewModel.getStatus() == .authorizedWhenInUse || self.locationManagerViewModel.getStatus() == .authorizedAlways {
                    if network.networkType == .cellular || network.networkType == .wifi {
                        if let name = network.name {
                            self.trustedNetworkValueLabel.text = name
                        }
                    } else {
                        self.trustedNetworkValueLabel.text = TextsAsset.NetworkSecurity.unknownNetwork
                    }
                }
            }, onError: { _ in
                self.trustedNetworkValueLabel.text = TextsAsset.noNetworksAvailable
            }).disposed(by: disposeBag)
    }
}
