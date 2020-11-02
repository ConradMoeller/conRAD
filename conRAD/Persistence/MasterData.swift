//
//  MasterData.swift
//  conRAD
//
//  Created by Conrad Moeller on 27.09.20.
//  Copyright © 2020 Conrad Moeller. All rights reserved.
//

import Foundation

struct Settings: Encodable, Decodable {

    var setup: Bool
    var bike: String
    var training: String

}

struct Bicycle: Encodable, Decodable {

    var id: String
    var name: String
    var wheelSize: String
    var crank1: String
    var crank2: String
    var sprockets: String
    var HRSensorId: String
    var HRSensorName: String
    var CSCSensorId: String
    var CSCSensorName: String
    var PowerSensorId: String
    var PowerSensorName: String
    
    func getGearBox() -> GearBox {
        return GearBox(wheelSize: Int(wheelSize) ?? 2000, crank1: crank1, crank2: crank2, sprockets: sprockets)
    }

}

struct Cyclist: Encodable, Decodable {

    var name: String
    var weigth: String
    var maxHR: String
    var FTP: String
    var dob: String
    var tileUrl: String
    var maxZoom: String
    var metricSystem: Bool = true
}

struct Training: Encodable, Decodable {

    var id: String
    var name: String
    var intervals: [Interval]
    var currentInterval = 0
    
    var hr: String {
        get {
            intervals[currentInterval].hr
        }
        set(newValue) {
            intervals[currentInterval].hr = newValue
        }
    }

    var cadence: String {
        get {
            intervals[currentInterval].cadence
        }
        set(newValue) {
            intervals[currentInterval].cadence = newValue
        }
    }

    var power: String {
        get {
            intervals[currentInterval].power
        }
        set(newValue) {
            intervals[currentInterval].power = newValue
        }
    }

    var duration: String {
        get {
            intervals[currentInterval].duration
        }
        set(newValue) {
            intervals[currentInterval].duration = newValue
        }
    }
    
    func copy() -> Training {
        let result = Training(id: UUID().uuidString, name: name + "_", intervals: intervals, currentInterval: 0)
        return result
    }
    
    func getIntervalStart() -> Double {
        var result = 0
        var count = 0
        for i in intervals {
            if count < currentInterval {
                result += (Int(i.duration) ?? 0) + (Int(i.duration_s) ?? 0)
            }
            count += 1
        }
        return Double(result)
    }

}

struct Interval: Encodable, Decodable {

    var name: String
    var hr: String
    var power: String
    var cadence: String
    var duration: String
    var duration_s = "0"
    
}
