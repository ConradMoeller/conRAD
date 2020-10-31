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
    var hr: String
    var power: String
    var cadence: String

}
