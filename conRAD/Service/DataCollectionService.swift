//
//  DataCollectionService.swift
//  UltimateTriTrainer
//
//  Created by Conrad Moeller on 16.11.18.
//  Copyright © 2018 Conrad Moeller. All rights reserved.
//

import Foundation
import CoreMotion
import CoreLocation

class DataCollectionService {

    // tailor:off
    public static let METRIC_TIME = "time"
    public static let METRIC_DIST = "dist"
    public static let METRIC_LAT = "lat"
    public static let METRIC_LONG = "lon"
    public static let METRIC_ALT = "ele"
    public static let METRIC_SPEED = "speed"
    public static let METRIC_SPEED_MAX = "speed.max"
    public static let METRIC_HR = "hr"
    public static let METRIC_HR_MAX = "hr.max"
    public static let METRIC_CAD = "cad"
    public static let METRIC_POWER = "power"
    public static let METRIC_WHEELRPM = "wheelrpm"
    public static let METRIC_CALORIES = "calories"

    public static let POWER_BUFFER_SIZE = 15
    public static let CADENCE_BUFFER_SIZE = 2
    public static let SPEED_BUFFER_SIZE = 2
    // tailor:on

    private static var dataCollector = DataCollectionService()

    public static func getInstance() -> DataCollectionService {
        return dataCollector
    }
    private var motionManager = CMMotionManager()

    var recordingStarted = false
    var startTime: Date = Date()
    var duration = 0.0

    private var hrConnector: HeartRateConnector
    private var pmConnector: PowerMeterConnector
    private var cscConnector: CyclingSpeedCadenceConnector
    private var gpsConnector = GPSConnector()

    private var hrData: IntMeterData
    private var powerData: IntMeterData
    private var cadenceData: IntMeterData
    private var speedData: DoubleMeterData
    private var cadenceData2: IntMeterData

    private var coordinates = [CLLocationCoordinate2D]()
    private var speed = 0.0
    private var lastSpeed = 0.0
    private var distance = 0.0
    private var altitude = 0.0

    private var timer: Timer!

    private let df = DateFormatter()
    private var logFile: ActivityLogFile!
    private let logDateFormat = "yyyy-MM-dd'T'HH:mm:ss.'000Z'"
    
    private var count = 0

    private init() {
    
        hrData = IntMeterData(useLastValue: true, bufferSize: 1)
        hrConnector = HeartRateConnector(hrData: hrData)
        powerData = IntMeterData(useLastValue: false, bufferSize: DataCollectionService.POWER_BUFFER_SIZE)
        cadenceData = IntMeterData(useLastValue: false, bufferSize: DataCollectionService.CADENCE_BUFFER_SIZE)
        pmConnector = PowerMeterConnector(powerData: powerData, rpmData: cadenceData)

        let bike =  MasterDataRepo.readBicycle()
        var ws = bike.wheelSize
        if ws == "0" {
            ws = "2000"
        }
        speedData = DoubleMeterData(useLastValue: false, bufferSize: DataCollectionService.SPEED_BUFFER_SIZE)
        cadenceData2 = IntMeterData(useLastValue: false, bufferSize: DataCollectionService.CADENCE_BUFFER_SIZE)
        cscConnector = CyclingSpeedCadenceConnector(speedData: speedData, rpmData: cadenceData2, wheelSize: Int(ws) ?? 2000)
    }

    func reInitPowerData() {
        powerData = IntMeterData(useLastValue: false, bufferSize: DataCollectionService.CADENCE_BUFFER_SIZE)
        pmConnector = PowerMeterConnector(powerData: powerData, rpmData: cadenceData)
    }

    func connectDevices() {
        hrConnector.connect()
        pmConnector.connect()
        cscConnector.connect()
        gpsConnector.connect()
    }

    func disconnectDevices() {
        stopRecording()
        hrConnector.disconnect()
        pmConnector.disconnect()
        cscConnector.disconnect()
        gpsConnector.disconnect()
    }

    func startRecording() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.5
            motionManager.startAccelerometerUpdates()
        }
        updateTrainingLimits()
        recordingStarted = true
        resetTotals()
        startTime = Date()
        df.timeZone = TimeZone.current
        df.dateFormat = "yyyy-MM-dd-HH-mm"
        logFile = ActivityLogFile(name: "sessions/conRAD-" + df.string(from: Date()))
        df.timeZone = TimeZone(identifier: "UTC")
        df.dateFormat = logDateFormat
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(log), userInfo: nil, repeats: true)
    }
    
    func stopRecording() {
        if !recordingStarted {
            return
        }
        recordingStarted = false
        // altimeter.stopRelativeAltitudeUpdates()
        timer.invalidate()
        let cyclist = MasterDataRepo.readCyclist()
        let weight = Int(cyclist.weigth)
        let record = LogRecord()
        let duration = abs(startTime.timeIntervalSinceNow)
        record.data[DataCollectionService.METRIC_TIME] = String(duration)
        record.data[DataCollectionService.METRIC_DIST] = String(getDistance())
        record.data[DataCollectionService.METRIC_CAD] = String(getCadenceData().getTotalAvg())
        record.data[DataCollectionService.METRIC_HR] = String(getHRData().getTotalAvg())
        record.data[DataCollectionService.METRIC_HR_MAX] = String(getHRData().getTotalMax())
        record.data[DataCollectionService.METRIC_SPEED_MAX] = String(getSpeedData().getMaxValue())
        record.data[DataCollectionService.METRIC_CALORIES] = String(CaloricCalculator.getConsumtion(avgSpeed: getSpeedData().getTotalAvg(), duration: duration, weight: weight!))
        logFile.setTotals(record: record)
        // FileTool.writeJSON(name: logFile.getFileName(), data: logFile)
        FileTool.write(name: logFile.getFileName(), data: logFile.toTCX(id: df.string(from: startTime)), ext: "tcx")
        // FileTool.write(name: logFile.getFileName(), data: logFile.toCSV(), ext: "csv")
    }

    func updateTrainingLimits() {
        let training = MasterDataRepo.readTraining()
        hrData.setTarget(target: Int(training.hr) ?? 0)
        hrData.setTolerance(tolerance: 10)
        powerData.setTarget(target: Int(training.power) ?? 0)
        powerData.setTolerance(tolerance: 25)
        cadenceData.setTarget(target: Int(training.cadence) ?? 0)
        cadenceData.setTolerance(tolerance: 5)
        cadenceData2.setTarget(target: Int(training.cadence) ?? 0)
        cadenceData2.setTolerance(tolerance: 5)
    }
    
    func resetTotals() {
        hrData.clear()
        hrData.resetTotals()
        powerData.clear()
        powerData.resetTotals()
        cadenceData.clear()
        cadenceData.resetTotals()
        if cscConnector.isDeviceConnected() {
            cscConnector.getWheelRevolutions().resetTotals()
            cscConnector.getWheelRevolutions().clear()
        }
        cadenceData2.clear()
        cadenceData2.resetTotals()
        if !gpsConnector.isConnected() {
            gpsConnector.connect()
        }
        gpsConnector.reset()
        coordinates.removeAll()
    }

    func isHRDeviceConnected() -> Bool {
        return hrConnector.isDeviceConnected()
    }

    func isPowerMeterDeviceConnected() -> Bool {
        return pmConnector.isDeviceConnected()
    }

    func isCadenceDeviceConnected() -> Bool {
        return pmConnector.isDeviceConnected() || cscConnector.isDeviceConnected()
    }

    func isSpeedDeviceConnected() -> Bool {
        return cscConnector.isDeviceConnected()
    }

    func getHRData() -> IntMeterData {
        return hrData
    }

    func getPowerData() -> IntMeterData {
        return powerData
    }

    func getCadenceData() -> IntMeterData {
        if pmConnector.isDeviceConnected() {
            return cadenceData
        } else {
            return cadenceData2
        }
    }

    func getWheelRPMData() -> IntMeterData {
        if cscConnector.isDeviceConnected() {
            return cscConnector.getWheelRPM()
        }
        return IntMeterData(useLastValue: true, bufferSize: 1)
    }

    private func getSpeedData() -> DoubleMeterData {
        if cscConnector.isDeviceConnected() {
            return speedData
        } else {
            return gpsConnector.getSpeed()
        }
    }

    func getDuration() -> Double {
        if getSpeed() > 0 {
            duration += abs(startTime.timeIntervalSinceNow)
            startTime = Date()
            return duration
        } else {
            startTime = Date()
            return duration
        }
    }

    func getSpeed() -> Double {
        evaluateSpeed()
        return speed
    }

    private func evaluateSpeed() {
        let speedData = getSpeedData()
        speed = speedData.getValue()
        lastSpeed = speedData.getLastValue()
    }

    func getDistance() -> Double {
        distance = evaluateDistance()
        return distance
    }

    private func evaluateDistance() -> Double {
        if cscConnector.isDeviceConnected() {
            return cscConnector.getDistance()
        } else {
            return gpsConnector.getDistance()
        }
    }

    func getAltitude() -> Double {
        evaluateAltitude()
        return altitude
    }

    func getPowerBalance() -> Int {
        return pmConnector.getBalance()
    }
    
    func getCoordinates() -> [CLLocationCoordinate2D] {
        return coordinates
    }

    private func evaluateAltitude() {
        altitude = round(gpsConnector.getAltitude() * 1000) / 1000
    }

    @objc private func log() {
        if recordingStarted {
            if count % 5 == 0 {
                coordinates.append(gpsConnector.getCoordinate())
            }
            count += 1
            let record = LogRecord()
            record.data[DataCollectionService.METRIC_TIME] = String(df.string(from: Date()))
            record.data[DataCollectionService.METRIC_DIST] = String(getDistance())
            record.data[DataCollectionService.METRIC_LAT] = String(gpsConnector.getLatitude())
            record.data[DataCollectionService.METRIC_LONG] = String(gpsConnector.getLongitude())
            record.data[DataCollectionService.METRIC_ALT] = String(getAltitude())
            record.data[DataCollectionService.METRIC_SPEED] = String(getSpeed())
            record.data[DataCollectionService.METRIC_HR] = String(hrData.getValue())
            record.data[DataCollectionService.METRIC_CAD] = String(getCadenceData().getValue())
            record.data[DataCollectionService.METRIC_POWER] = String(powerData.getValue())
            record.data[DataCollectionService.METRIC_WHEELRPM] = String(getWheelRPMData().getValue())
            logFile.addRecord(record: record)
        }
    }

}
