//
//  PowerMeterConnector.swift
//  UltimateTriTrainer
//
//  Created by Conrad Moeller on 10.10.18.
//  Copyright © 2018 Conrad Moeller. All rights reserved.
//

import BicycleBLEKit

class PowerMeterConnector {

    private let bleKit = BicycleBLEKit()
    private var power: IntMeterData
    private var powerBalance: IntMeterData
    private var rpm: IntMeterData

    required init(powerData: IntMeterData, rpmData: IntMeterData) {
        power = powerData
        powerBalance = IntMeterData(useLastValue: false, bufferSize: 5)
        rpm = rpmData
    }

    func getBalance() -> Int {
        return powerBalance.getValue()
    }

    func connect() {
        let bike = MasterDataRepo.readBicycle()
        bleKit.startListenToPowerService(deviceId: bike.PowerSensorId, delegate: self)
    }

    func disconnect() {
        bleKit.stopListenToPowerService()
    }

    func isDeviceConnected() -> Bool {
        return bleKit.isPowerDeviceConnected()
    }

}

extension PowerMeterConnector: PowerMeterMeasurementDelegate {
    func notifyPower(power: Int) {
        self.power.queue(v: power)
    }

    func notifyBalance(balance: Int) {
        powerBalance.queue(v: balance)
    }

    func notifyCrankRPM(crankRPM: Int) {
        rpm.queue(v: crankRPM)
    }
}
