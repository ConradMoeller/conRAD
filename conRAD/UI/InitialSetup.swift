//
//  InitialSetup.swift
//  conRAD
//
//  Created by Conrad Moeller on 08.10.19.
//  Copyright © 2019 Conrad Moeller. All rights reserved.
//

import Foundation
import UIKit
import BicycleBLEKit

class InitialSetuptNavigation: UINavigationController {

    let bleKit = BicycleBLEKit()
    let step1vc = DeviceViewController()
    let step2vc = DeviceViewController()
    let step3vc = DeviceViewController()

    convenience init() {
        let step0vc = WelcomeViewController()
        self.init(rootViewController: step0vc)
        step0vc.title = "Welcome"
        step0vc.nextSetupStep = step1
        popToRootViewController(animated: true)
        unpairAll()
    }

    func unpairAll() {
        var bike = MasterDataRepo.readBicycle()
        bike.HRSensorId = ""
        bike.HRSensorName = ""
        bike.CSCSensorId = ""
        bike.CSCSensorName = ""
        bike.PowerSensorId = ""
        bike.PowerSensorName = ""
        MasterDataRepo.writeBicycle(bicycle: bike)
    }

    func step1() {
        step1vc.title = "HR Sensor"
        step1vc.barItemTitle = "Next"
        step1vc.startScan = bleKit.startScanHeartRateDevices
        step1vc.stopScan = bleKit.stopScanHeartRateDevices
        step1vc.pair = pairHRDevice
        step1vc.unpair = unpairHRDevice
        step1vc.nextSetupStep = step2
        pushViewController(step1vc, animated: true)
    }

    func pairHRDevice(id: String, name: String) {
        var bike = MasterDataRepo.readBicycle()
        bike.HRSensorId = id
        bike.HRSensorName = name
        MasterDataRepo.writeBicycle(bicycle: bike)
    }

    func unpairHRDevice() {
        var bike = MasterDataRepo.readBicycle()
        bike.HRSensorId = ""
        bike.HRSensorName = ""
        MasterDataRepo.writeBicycle(bicycle: bike)
    }

    func step2() {
        step2vc.title = "Powermeter"
        step2vc.barItemTitle = "Next"
        step2vc.startScan = bleKit.startScanPowerDevices
        step2vc.stopScan = bleKit.stopScanPowerDevices
        step2vc.pair = pairHRDevice
        step2vc.unpair = unpairHRDevice
        step2vc.nextSetupStep = step3
        pushViewController(step2vc, animated: true)
    }

    func pairPowerDevice(id: String, name: String) {
        var bike = MasterDataRepo.readBicycle()
        bike.PowerSensorId = id
        bike.PowerSensorName = name
        MasterDataRepo.writeBicycle(bicycle: bike)
    }

    func unpairPowerDevice() {
        var bike = MasterDataRepo.readBicycle()
        bike.PowerSensorId = ""
        bike.PowerSensorName = ""
        MasterDataRepo.writeBicycle(bicycle: bike)
    }

    func step3() {
        step3vc.title = "Speed Sensor"
        step3vc.barItemTitle = "Next"
        step3vc.startScan = bleKit.startScanCSCDevices
        step3vc.stopScan = bleKit.stopScanCSCDevices
        step3vc.pair = pairHRDevice
        step3vc.unpair = unpairHRDevice
        pushViewController(step3vc, animated: true)
    }

    func pairCSCDevice(id: String, name: String) {
        var bike = MasterDataRepo.readBicycle()
        bike.CSCSensorId = id
        bike.CSCSensorName = name
        MasterDataRepo.writeBicycle(bicycle: bike)
    }

    func unpairCSCDevice() {
        var bike = MasterDataRepo.readBicycle()
        bike.CSCSensorId = ""
        bike.CSCSensorName = ""
        MasterDataRepo.writeBicycle(bicycle: bike)
    }

}
