//
//  TimeSeries.swift
//  UltimateTriTrainer
//
//  Created by Conrad Moeller on 13.11.18.
//  Copyright © 2018 Conrad Moeller. All rights reserved.
//

import Foundation

class TimeSeries<T: Numeric> {

    private var times = [Date]()
    private var values = [T]()

    private var capacity: Int

    init(capacity: Int) {
        self.capacity = capacity
    }

    func append(value: T) {
        times.append(Date())
        values.append(value)
        if values.count > capacity {
            times.remove(at: 0)
            values.remove(at: 0)
        }
    }

    func removeAll() {
        times.removeAll()
        values.removeAll()
    }

    func getFirstValue() -> T {
        if values.count == 0 {
            return 0
        }
        return values[0]
    }

    func getLastValue() -> T {
        if values.count == 0 {
            return 0
        }
        return values[values.count - 1]
    }

    func getValueList() -> [T] {
        return values
    }

    func sum() -> T {
        var sum: T = 0
        for v in values {
            sum += v
        }
        return sum
    }

    func sum(last: Int) -> T {
        var sum: T = 0
        for i in 0..<last {
            let index = values.count - 1 - i
            if index >= 0 {
                sum += values[index]
            }
        }
        return sum
    }

}
