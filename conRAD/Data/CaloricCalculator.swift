//
//  CaloricCalculator.swift
//  UltimateTriTrainer
//
//  Created by Conrad Moeller on 17.12.18.
//  Copyright © 2018 Conrad Moeller. All rights reserved.
//

import Foundation

class CaloricCalculator {

    static func getConsumtion(avgSpeed: Double, duration: Double, weight: Int) -> Int {
        return Int((getBase(avgSpeed: avgSpeed * 3.6) * (duration / 60) * Double(weight)) / 60)
    }

    static private func getBase(avgSpeed: Double) -> Double {
        if avgSpeed < 26 {
            return 7.5
        } else if avgSpeed < 31 {
            return 9.5
        } else if avgSpeed < 36 {
            return 11.5
        } else {
            return 16.5
        }
    }

}
