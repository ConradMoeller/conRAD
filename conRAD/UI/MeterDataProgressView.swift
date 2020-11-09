//
//  MeterDataProgressView.swift
//  UltimateTriTrainer
//
//  Created by Conrad Moeller on 09.10.18.
//  Copyright © 2018 Conrad Moeller. All rights reserved.
//

import UIKit
import AVFoundation

@IBDesignable class MeterDataProgressView: UIStackView {

    let lblue = UILabel()
    let l2 = UILabel()
    let l1 = UILabel()
    let lcenter = UILabel()
    let r1 = UILabel()
    let r2 = UILabel()
    let rred = UILabel()

    var labels = [UILabel]()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        setUpView()
    }

    private func setUpView() {

        let width = bounds.width / 20

        lblue.backgroundColor = UIColor.blue
        lblue.translatesAutoresizingMaskIntoConstraints = false
        lblue.widthAnchor.constraint(equalToConstant: 3 * width).isActive = true
        lblue.heightAnchor.constraint(equalToConstant: bounds.height).isActive = true

        l2.backgroundColor = UIColor.green
        l2.translatesAutoresizingMaskIntoConstraints = false
        l2.widthAnchor.constraint(equalToConstant: 2 * width).isActive = true
        l2.heightAnchor.constraint(equalToConstant: bounds.height).isActive = true

        l1.backgroundColor = UIColor.green
        l1.translatesAutoresizingMaskIntoConstraints = false
        l1.widthAnchor.constraint(equalToConstant: 2 * width).isActive = true
        l1.heightAnchor.constraint(equalToConstant: bounds.height).isActive = true

        lcenter.backgroundColor = UIColor.green
        lcenter.alpha = 0.5
        lcenter.translatesAutoresizingMaskIntoConstraints = false
        lcenter.widthAnchor.constraint(equalToConstant: 5 * width).isActive = true
        lcenter.heightAnchor.constraint(equalToConstant: bounds.height).isActive = true
        lcenter.textAlignment = .center
        lcenter.adjustsFontSizeToFitWidth = true
        lcenter.font = lcenter.font.withSize(17)

        r1.backgroundColor = UIColor.green
        r1.translatesAutoresizingMaskIntoConstraints = false
        r1.widthAnchor.constraint(equalToConstant: 2 * width).isActive = true
        r1.heightAnchor.constraint(equalToConstant: bounds.height).isActive = true

        r2.backgroundColor = UIColor.green
        r2.translatesAutoresizingMaskIntoConstraints = false
        r2.widthAnchor.constraint(equalToConstant: 2 * width).isActive = true
        r2.heightAnchor.constraint(equalToConstant: bounds.height).isActive = true

        rred.backgroundColor = UIColor.red
        rred.translatesAutoresizingMaskIntoConstraints = false
        rred.widthAnchor.constraint(equalToConstant: 3 * width).isActive = true
        rred.heightAnchor.constraint(equalToConstant: bounds.height).isActive = true

        labels.append(lblue)
        labels.append(l2)
        labels.append(l1)
        labels.append(r1)
        labels.append(r2)
        labels.append(rred)

        addArrangedSubview(lblue)
        addArrangedSubview(l2)
        addArrangedSubview(l1)
        addArrangedSubview(lcenter)
        addArrangedSubview(r1)
        addArrangedSubview(r2)
        addArrangedSubview(rred)
    }

    func setConnectionState(isConnected: Bool) {

        if isConnected {
            lcenter.backgroundColor = UIColor.green
            lcenter.alpha = 1.0
        } else {
            lcenter.backgroundColor = UIColor.red
            lcenter.alpha = 0.5
        }
        for label in labels {
            label.alpha = 0.0
        }
    }

    func updateProgress(isConnected: Bool, data: ProgressDataProvider) {

        setConnectionState(isConnected: isConnected)
        lcenter.text = String(data.getTarget())
        if isConnected && data.getTarget() > 0 {
            let progress = data.getProgressValue()
            if progress < -99.0 {
                return
            }
            if progress < 0.0 {
                if abs(progress) < 0.5 {
                    l1.alpha = CGFloat(0.95 - abs(progress))
                    l2.alpha = 0.0
                }
                if abs(progress) >= 0.5 {
                    l1.alpha = 0.5
                    l2.alpha = CGFloat(1 - abs(progress))
                }
                if abs(progress) >= 1.0 {
                    l2.alpha = 0.1
                    lblue.alpha = CGFloat(abs(progress) - 0.5)
                } else {
                    lblue.alpha = 0.0
                }
            } else {
                if progress < 0.5 {
                    r1.alpha = CGFloat(0.95 - progress)
                    r2.alpha = 0.0
                }
                if progress >= 0.5 {
                    r1.alpha = 0.5
                    r2.alpha = CGFloat(1.0 - progress)
                }
                if progress >= 1.0 {
                    r2.alpha = 0.1
                    rred.alpha = CGFloat(progress - 0.5)
                } else {
                    rred.alpha = 0.0
                }
            }
        }
    }

}

protocol ProgressDataProvider {
    func getTarget() -> Int
    func getProgressValue() -> Double
}
