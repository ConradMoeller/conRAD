//
//  CyclingSpeedCadenceConnector.swift
//  UltimateTriTrainer
//
//  Created by Conrad Moeller on 12.11.18.
//  Copyright © 2018 Conrad Moeller. All rights reserved.
//

import CoreBluetooth
import BicycleBLEKit

class CyclingSpeedCadenceConnector {

    private var wheelSize: Int

    private var wheelRevolutionsData: IntMeterData
    private var wheelRPMData: IntMeterData
    private var speedData: DoubleMeterData

    private var crankRPM: IntMeterData
    
    private let bleKit = BicycleBLEKit()

    required init(speedData: DoubleMeterData, rpmData: IntMeterData, wheelSize: Int) {
        self.speedData = speedData
        self.crankRPM = rpmData
        self.wheelSize = wheelSize
        wheelRevolutionsData = IntMeterData(useLastValue: true, bufferSize: 3)
        wheelRPMData = IntMeterData(useLastValue: true, bufferSize: DataCollectionService.CADENCE_BUFFER_SIZE)
    }

    func getWheelRevolutions() -> IntMeterData {
        return wheelRevolutionsData
    }

    func getWheelRPM() -> IntMeterData {
        return wheelRPMData
    }

    func getDistance() -> Double {
        return Double(wheelRevolutionsData.getTotalSum()) * Double(wheelSize) * 0.001
    }

    func connect() {
        let bike = MasterDataRepo.readBicycle()
        bleKit.startListenToCSCService(deviceId: bike.CSCSensorId, wheelSize: Int(bike.wheelSize)!, delegate: self)
    }
    
    func disconnect() {
        bleKit.stopListenCSCService()
    }
    
    func isDeviceConnected() -> Bool {
        return bleKit.isCSCDeviceConnected()
    }

}

extension CyclingSpeedCadenceConnector: CyclingSpeedCadenceMeasurementDelegate {
    
    func notifySpeed(speed: Double) {
        speedData.queue(v: speed)
    }
    
    func notifyCrankRPM(crankRPM: Int) {
        self.crankRPM.queue(v: crankRPM)
    }
    
    func notifyWheelRevolutions(wheelRev: Int) {
        wheelRevolutionsData.queue(v: wheelRev)
    }
    
    func notifyWheelRPM(wheelRPM: Int) {
        wheelRPMData.queue(v: wheelRPM)
    }
    
    func notifyDistance(dist: Double) {
        
    }
    
}
