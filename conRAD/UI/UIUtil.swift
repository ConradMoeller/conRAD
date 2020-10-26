//
//  UIUtil.swift
//  UltimateTriTrainer
//
//  Created by Conrad Moeller on 06.10.18.
//  Copyright © 2018 Conrad Moeller. All rights reserved.
//
import UIKit

class UIUtil {

    static func applyBoxStyle(view: UIView) {
        view.layer.borderWidth = CGFloat(1.0)
        view.layer.cornerRadius = CGFloat(10.0)
        view.layer.borderColor = UIColor.darkGray.cgColor
    }

}
