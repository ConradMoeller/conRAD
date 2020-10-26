//
//  GearBox.swift
//  UltimateTriTrainer
//
//  Created by Conrad Moeller on 05.04.19.
//  Copyright © 2019 Conrad Moeller. All rights reserved.
//

import Foundation

struct Gear {

    let frontIndex: Int
    let front: Int

    let rearIndex: Int
    let rear: Int

    init() {
        frontIndex = 0
        front = 0
        rearIndex = 0
        rear = 0
    }

    init(fi: Int, f: Int, ri: Int, r: Int) {
        frontIndex = fi
        front = f
        rearIndex = ri
        rear = r
    }

    func rollOut() -> Double {
        if rear == 0 {
            return 0.0
        }
        return Double(front) / Double(rear)
    }

    func getDesc() -> String {
        if rear == 0 {
            return "--/--"
        }
        return String(front) + "/" + String(rear)
    }

}

class GearBox {

    private let wheelSize: Int
    private var gears = [Gear]()
    private var maxRear = 0

    init(wheelSize: Int, crank1: String, crank2: String, sprockets: String) {
        self.wheelSize = wheelSize
        gears.removeAll()
        var front = [Int]()
        front.append(Int(crank1)!)
        front.append(Int(crank2)!)
        front.sort(by: { $0 <= $1 })
        let list = sprockets.split(separator: ",")
        var rear = [Int]()
        for l in list {
            let i = Int(l)!
            if !rear.contains(i) {
                rear.append(i)
            }
        }
        rear.sort(by: { $0 <= $1 })
        maxRear = rear.count - 1
        var i = 0
        for f in front {
            var j = 0
            for r in rear {
                gears.append(Gear(fi: i, f: f, ri: j, r: r))
                j += 1
            }
            i += 1
        }
    }

    func getMaxRearIndex() -> Int {
        return maxRear
    }

    func findGear(frontIndex: Int, rollOut: Double) -> Gear {
        var dev = 123.456
        var currentGear = Gear()
        for value in gears {
            let a = abs(value.rollOut() - rollOut)
            if value.frontIndex == frontIndex && a < dev {
                dev = a
                currentGear = value
            }
        }
        return currentGear
    }

    func findGear(frontIndex: Int, rearIndex: Int) -> Gear {
        var rear = 0
        if rearIndex < 0 {
            rear = 0
        } else if rearIndex > getMaxRearIndex() {
            rear = getMaxRearIndex()
        } else {
            rear = rearIndex
        }
        for value in gears {
            if value.frontIndex == frontIndex && value.rearIndex == rear {
                return value
            }
        }
        return Gear()
    }

    func getSpeed(frontIndex: Int, rearIndex: Int, rpm: Int) -> Double {
        if rpm < 1 {
            return 0.0
        }
        let rollout = findGear(frontIndex: frontIndex, rearIndex: rearIndex).rollOut()
        return Double(wheelSize) * rollout / 1000.0 * Double(rpm) / 60.0
    }

    func getRPM(frontIndex: Int, rearIndex: Int, speed: Double) -> Int {
        let rollout = findGear(frontIndex: frontIndex, rearIndex: rearIndex).rollOut()
        return Int(speed * 60000 / Double(wheelSize) / rollout)
    }

    func getBestGear(frontIndex: Int, rpm: Int, speed: Double) -> Int {
        let gear = findGear(frontIndex: frontIndex, rollOut: speed * 60000 / Double(wheelSize) / Double(rpm))
        return gear.rearIndex
    }

    func getAverageDistance(rpm: Int) -> Int {
        let data = IntMeterData(useLastValue: false, bufferSize: 44)
        for front in 0 ... 1 {
            for gear in 1 ... 9 {
                let speedHigh = getSpeed(frontIndex: front, rearIndex: gear - 1, rpm: rpm - 2)
                let speedLow = getSpeed(frontIndex: front, rearIndex: gear + 1, rpm: rpm + 2)
                data.queue(v: getRPM(frontIndex: front, rearIndex: gear, speed: speedHigh) - rpm)
                data.queue(v: rpm - getRPM(frontIndex: front, rearIndex: gear, speed: speedLow))
            }
        }
        return data.getTotalAvg()
    }

}
