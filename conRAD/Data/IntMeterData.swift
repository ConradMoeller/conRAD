//
//  IntMeterData.swift
//  UltimateTriTrainer
//
//  Created by Conrad Moeller on 09.10.18.
//  Copyright © 2018 Conrad Moeller. All rights reserved.
//
import Foundation

class IntMeterData: ProgressDataProvider {

    private var lastNotification: Date = Date(timeIntervalSince1970: 0)

    private var useLast = true
    private var maxSize = 0

    private var values: TimeSeries<Int>
    private var deviation: TimeSeries<Int>

    private var lastValue = 0
    private var minValue = Int.max
    private var maxValue = 0
    private var avgValue = 0
    private var sigma = 0

    private var notificationTimeout = 1.5
    private var totalNotifications = 0
    private var totalSum = 0
    private var totalMax = 0

    private var target = 0
    private var tolerance = 0

    init(useLastValue: Bool, bufferSize: Int) {
        useLast = useLastValue
        maxSize = bufferSize
        notificationTimeout = 1.5
        lastNotification = Date()
        values = TimeSeries<Int>(capacity: maxSize)
        deviation = TimeSeries<Int>(capacity: maxSize)
    }

    func clear() {
        values.removeAll()
        deviation.removeAll()
        lastValue = 0
        minValue = 0
        maxValue = 0
        avgValue = 0
    }

    func shrink() {
        values.removeAll()
        values.append(value: avgValue)
        deviation.removeAll()
        deviation.append(value: avgValue - lastValue)
        lastValue = avgValue
        minValue = avgValue
        maxValue = avgValue
    }

    func queue(v: Int) {
        if v == 0 {
            if values.getValueList().count > 0 {
                lastNotification -= notificationTimeout
                lastNotification -= 0.1
                totalNotifications += 1
            }
            clear()
            return
        }
        notificationTimeout = min(2.0, ((notificationTimeout + abs(lastNotification.timeIntervalSinceNow)) / 2) * 1.25)
        lastNotification = Date()
        totalNotifications += 1
        totalSum += v
        if v > totalMax {
            totalMax = v
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
        minValue = Int.max
        maxValue = Int.min
        var sum = 0
        let list = values.getValueList()
        for i in list {
            sum += i
            if i < minValue {
                minValue = i
            }
            if i > maxValue {
                maxValue = i
            }
        }
        avgValue = sum / list.count
        var sqsum = 0.0
        for i in list {
            sqsum += pow(Double(i - avgValue), 2)
        }
        sigma = Int(sqrt(sqsum / Double(list.count)))
    }

    func getRange() -> Int {
        return maxValue - minValue
    }

    func getSigma() -> Int {
        return sigma
    }

    func getTotalNotifications() -> Int {
        return totalNotifications
    }

    func getTotalSum() -> Int {
        return totalSum
    }

    func getTotalAvg() -> Int {
        if totalNotifications == 0 {
            return 0
        }
        return totalSum / totalNotifications
    }

    func getTotalMax() -> Int {
        return totalMax
    }

    func resetTotals() {
        totalNotifications = 0
        totalSum = 0
        totalMax = 0
    }

    func getMinValue() -> Int {
        return minValue
    }

    func getMaxValue() -> Int {
        return maxValue
    }

    func getAvgValue() -> Int {
        return avgValue
    }

    func getLastValue() -> Int {
        testNotificationTimeout()
        return lastValue
    }

    func getLastNotificationTime() -> Date {
        return lastNotification
    }

    func setTarget(target: Int) {
        self.target = target
    }

    func getTarget() -> Int {
        return target
    }

    func setTolerance(tolerance: Int) {
        self.tolerance = tolerance
    }

    func getTolerance() -> Int {
        return tolerance
    }

    func getValue() -> Int {
        if useLast {
            return getLastValue()
        } else {
            testNotificationTimeout()
            return avgValue
        }
    }

    private func testNotificationTimeout() {
        if abs(lastNotification.timeIntervalSinceNow) > notificationTimeout {
            queue(v: 0)
        }
    }

    func getProgressValue() -> Double {
        let v = getValue()
        if v == 0 {
            return -100.0
        }
        return Double((v - target)) / Double(tolerance)
    }

    func getMaxLimit() -> Int {
        return target + tolerance
    }

    func getMinLimit() -> Int {
        return target - tolerance
    }

    func getLastDeviation() -> Int {
        return deviation.getLastValue()
    }

    func getDeviationSum() -> Int {
        return deviation.sum()
    }

    func getDeviationSum(last: Int) -> Int {
        return deviation.sum(last: last)
    }

    func getFirstValue() -> Int {
        return values.getFirstValue()
    }

    func count() -> Int {
        return values.getValueList().count
    }

}
