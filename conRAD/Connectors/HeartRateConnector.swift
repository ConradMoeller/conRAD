//
//  HeartRateConnector.swift
//  UltimateTriTrainer
//
//  Created by Conrad Moeller on 10.10.18.
//  Copyright © 2018 Conrad Moeller. All rights reserved.
//

import BicycleBLEKit

class HeartRateConnector {

    private let bleKit = BicycleBLEKit()
    private var data: IntMeterData

    required init(hrData: IntMeterData) {
        self.data = hrData
    }

    func connect() {
        let bike = MasterDataRepo.readBicycle()
        bleKit.startListenToHeartRateService(deviceId: bike.HRSensorId, delegate: self)
    }

    func disconnect() {
        bleKit.stopListenHeartRateService()
    }

    func isDeviceConnected() -> Bool {
        return bleKit.isHearRateDeviceConnected()
    }
}

extension HeartRateConnector: HeartRateMeasurementDelegate {
    func notifyHeartRate(bpm: Int) {
        self.data.queue(v: bpm)
    }
}
