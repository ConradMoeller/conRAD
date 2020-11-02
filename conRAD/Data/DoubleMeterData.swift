//
//  DoubleMeterData.swift
//  UltimateTriTrainer
//
//  Created by Conrad Moeller on 09.10.18.
//  Copyright © 2018 Conrad Moeller. All rights reserved.
//
import Foundation

class DoubleMeterData: ProgressDataProvider {

    private var lastNotification: Date = Date(timeIntervalSince1970: 0)

    private var useLast = true
    private var maxSize = 5

    private var values: TimeSeries<Double>
    private var deviation: TimeSeries<Double>

    private var lastValue = 0.0
    private var maxValue = 0.0
    private var avgValue = 0.0

    private var totalNotifications = 0
    private var totalSum = 0.0
    private var totalMax = 0.0
    private var totalMin = 1000000.0

    private var target = 0.0
    private var tolerance = 0.0

    init(useLastValue: Bool, bufferSize: Int) {
        useLast = useLastValue
        maxSize = bufferSize
        values = TimeSeries<Double>(capacity: maxSize)
        deviation = TimeSeries<Double>(capacity: maxSize)
    }

    func clear() {
        values.removeAll()
        deviation.removeAll()
        lastValue = 0
        maxValue = 0
        avgValue = 0
    }

    func queue(v: Double) {
        lastNotification = Date()
        totalNotifications += 1
        totalSum += v
        if v > totalMax {
            totalMax = v
        }
        if v < totalMin {
            totalMin = v
        }
        if maxSize < 2 {
            lastValue = v
            avgValue = v
            maxValue = v
            return
        }
        deviation.append(value: v - lastValue)
        lastValue = v
        values.append(value: v)
        maxValue = 0.0
        var sum = 0.0
        let list = values.getValueList()
        for (i) in list {
            sum += i
            if i > maxValue {
                maxValue = i
            }
        }
        let d = sum / Double(list.count)
        avgValue = d
    }

    func getTotalNotifications() -> Int {
        return totalNotifications
    }

    func getTotalSum() -> Double {
        return totalSum
    }

    func getTotalAvg() -> Double {
        if totalNotifications == 0 {
            return 0
        }
        return totalSum / Double(totalNotifications)
    }

    func getTotalMax() -> Double {
        return totalMax
    }

    func resetTotals() {
        totalNotifications = 0
        totalSum = 0
        totalMax = 0
        totalMin = 0
    }

    func getMaxValue() -> Double {
        return maxValue
    }

    func getAvgValue() -> Double {
        return avgValue
    }

    func getLastValue() -> Double {
        if abs(lastNotification.timeIntervalSinceNow) > 1.5 {
            return 0
        }
        return lastValue
    }

    func setTarget(target: Double) {
        self.target = target
    }

    func getTarget() -> Double {
        return target
    }
    
    func getTarget() -> Int {
        return Int(target)
    }

    func setTolerance(tolerance: Double) {
        self.tolerance = tolerance
    }

    func getTolerance() -> Double {
        return tolerance
    }

    func getValue() -> Double {
        if abs(lastNotification.timeIntervalSinceNow) > 1.5 {
            return 0.0
        }
        if useLast {
            return lastValue
        }
        return avgValue
    }

    func getProgressValue() -> Double {
        return Double((getValue() - target)) / Double(tolerance)
    }

    func getLastDeviation() -> Double {
        return deviation.getLastValue()
    }

    func getDeviationSum() -> Double {
        return deviation.sum()
    }

    func getDeviationSum(last: Int) -> Double {
        return deviation.sum(last: last)
    }

    func count() -> Int {
        return values.getValueList().count
    }

}
