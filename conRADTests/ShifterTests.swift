//
//  ShifterServiceTests.swift
//  UltimateTriTrainerTests
//
//  Created by Conrad Moeller on 11.04.19.
//  Copyright © 2019 Conrad Moeller. All rights reserved.
//

import XCTest
@testable import conRAD

class ShifterServiceMock: ShifterServiceProtocol {
    
    let gearBox = GearBox(wheelSize: 2095, crank1: "42", crank2: "42", sprockets: "11,12,13,14,15,16,17,19,21,25,28")
    var _shiftUp: (() -> ())!
    var _shiftDown: (() -> ())!
    var toggle: (() -> ())!
    
    func shiftUp() {
        if _shiftUp != nil {
            _shiftUp()
        }
    }
    
    func shiftDown() {
        if _shiftDown != nil {
            _shiftDown()
        }
    }
    
    func toggleShiftMode() {
        if toggle != nil {
            toggle()
        }
    }
    
    func getSpeed(frontIndex: Int, rearIndex: Int, rpm: Int) -> Double {
        return gearBox.getSpeed(frontIndex:frontIndex, rearIndex: rearIndex, rpm: rpm)
    }
    
    func getRPM(frontIndex: Int, rearIndex: Int, speed: Double) -> Int {
        return gearBox.getRPM(frontIndex: frontIndex, rearIndex: rearIndex, speed: speed)
    }
    
    func getBestGear(frontIndex: Int, rpm: Int, speed: Double) -> Int {
        return gearBox.getBestGear(frontIndex: frontIndex, rpm: rpm, speed: speed)
    }
    
    func getAverageDistance(rpm: Int) -> Int {
        return gearBox.getAverageDistance(rpm: rpm)
    }
    
    func findGear(frontIndex: Int, rearIndex: Int) -> Gear {
        return gearBox.findGear(frontIndex: frontIndex, rearIndex: rearIndex)
    }
    
    func getDistanceToBestGear(frontIndex: Int) -> Int {
        return 0
    }
}

class ShiftFilterMock: Filter {
    func apply(service: ShifterServiceProtocol, params: ShiftParameters) -> FilterResult {
        return .next
    }
}

class ShiftStopFilterMock: Filter {
    func apply(service: ShifterServiceProtocol, params: ShiftParameters) -> FilterResult {
        return .stop
    }
}

class ShifterTests: XCTestCase {
    
    var chain = ShiftFilterChain()
    let service = ShifterServiceMock();
    let dataCollector = DataCollectionService.getInstance()
    
    let cim = IntMeterData(useLastValue: false, bufferSize: 2)
    let pim = IntMeterData(useLastValue: false, bufferSize: 15)
    
    override func setUp() {
        print("- setUp -----------------------------------------------------------------------")
        chain = ShiftFilterChain()
        chain.addFilter(toAdd: PrepareShiftFilter())
        chain.addFilter(toAdd: CyclingStoppedFilter())
        chain.addFilter(toAdd: PedalingStoppedFilter())
        chain.addFilter(toAdd: PreventShiftFilter())
        chain.addFilter(toAdd: DriveModeFilter())
        chain.addFilter(toAdd: EcoModeFilter())
        chain.addFilter(toAdd: NoopFilter())
        dataCollector.startRecording()
    }
    
    override func tearDown() {
        reset()
        dataCollector.stopRecording()
        print("- tearDown -------------------------------------------------------------------")
    }
    
    func testShiftFilterChain() {
        let chain = ShiftFilterChain()
        chain.addFilter(toAdd: ShiftFilterMock())
        chain.addFilter(toAdd: ShiftFilterMock())
        chain.addFilter(toAdd: ShiftFilterMock())
        chain.addFilter(toAdd: ShiftFilterMock())
        chain.addFilter(toAdd: ShiftFilterMock())
        chain.addFilter(toAdd: ShiftStopFilterMock())
        chain.addFilter(toAdd: ShiftFilterMock())
        let service = ShifterService.getInstance()
        let params = ShiftParameters()
        chain.start(service: service, params: params)
        XCTAssertEqual(chain.getFiltersCount(), 7)
        XCTAssertEqual(chain.getPassedFiltersCount(), 6)
    }
    
    func testPreventShift() {
        let params = ShiftParameters();
        setupParameters(params: params, cadenceTarget: 90, powerTarget: 175, ftp: 250)
        setShiftInput(params: params, cadence: 90, power: 180, rear: 4, speed: 0)
        params.driveMode = true
        chain.start(service: service, params: params)
        let _ = getShiftOutput(params: params, assertionNoShift: {}, assertionShift: {})
        XCTAssertEqual(params.comment, "stop cycling")
        
        setShiftInput(params: params, cadence: 90, power: 30, rear: 4, speed: 7)
        setShiftInput(params: params, cadence: 90, power: 30, rear: 4, speed: 7)
        setShiftInput(params: params, cadence: 90, power: 30, rear: 4, speed: 7)
        params.driveMode = true
        chain.start(service: service, params: params)
        let _ = getShiftOutput(params: params, assertionNoShift: {}, assertionShift: {})
        XCTAssertEqual(params.comment, "power very low")
        
        setShiftInput(params: params, cadence: 20, power: 180, rear: 4, speed: 7)
        setShiftInput(params: params, cadence: 20, power: 180, rear: 4, speed: 7)
        params.driveMode = true
        chain.start(service: service, params: params)
        let _ = getShiftOutput(params: params, assertionNoShift: {}, assertionShift: {})
        XCTAssertEqual(params.comment, "cadence very low")
    }
    
    func testRearIndexRecalculation() {
        let params = ShiftParameters();
        setupParameters(params: params, cadenceTarget: 90, powerTarget: 175, ftp: 250)
        setShiftInput(params: params, cadence: 90, power: 180, rear: 4, speed: 29.5 / 3.6)
        params.manualMode = true
        params.calculatedRearIndex = 5
        chain.start(service: service, params: params)
        var test = getShiftOutput(params: params, assertionNoShift: {}, assertionShift: {})
        XCTAssertEqual(test.1, 4)
        
        setShiftInput(params: params, cadence: 90, power: 180, rear: 4, speed: 25.9 / 3.6)
        params.calculatedRearIndex = 5
        chain.start(service: service, params: params)
        test = getShiftOutput(params: params, assertionNoShift: {}, assertionShift: {})
        XCTAssertEqual(test.1, 5)
        
        setShiftInput(params: params, cadence: 90, power: 180, rear: 4, speed: 27.9 / 3.6)
        params.calculatedRearIndex = 5
        chain.start(service: service, params: params)
        test = getShiftOutput(params: params, assertionNoShift: {}, assertionShift: {})
        XCTAssertEqual(test.1, 4)
        
        params.reset()
    }
    
    func testCyclingStoppedFilter() {
        let params = ShiftParameters();
        setShiftInput(params: params, cadence: 0, power: 0)
        chain.start(service: service, params: params)
        _ = getShiftOutput(params: params, assertionNoShift: {
            XCTAssertEqual(self.chain.getLastFilterName(), "conRAD.CyclingStoppedFilter")
        }, assertionShift: {})

        setShiftInput(params: params, cadence: 90, power: 160)
        chain.start(service: service, params: params)
        _ = getShiftOutput(params: params, assertionNoShift: {
            XCTAssertTrue(self.chain.getPassedFiltersCount() > 1)
        }, assertionShift: {})
    }
        
    func testStopPedaling() {
        let params = ShiftParameters()
        setupParameters(params: params, cadenceTarget: 90, powerTarget: 175, ftp: 250)
        setShiftInput(params: params, cadence: 90, power: 180, rear: 1, speed: 10.0)
        var speed = 10.0
        while speed > 6.0 {
            setShiftInput(params: params, cadence: 0, power: 0, speed: speed)
            chain.start(service: service, params: params)
            _ = getShiftOutput(params: params, assertionNoShift: {}, assertionShift: {
                XCTAssertEqual(self.service.getBestGear(frontIndex: params.frontIndex, rpm: params.cadenceTarget, speed: params.speed) - 1, params.rearIndex)
            })
            speed -= 0.2
        }
        
        setupParameters(params: params, cadenceTarget: 90, powerTarget: 175, ftp: 250)
        setShiftInput(params: params, cadence: 90, power: 180, rear: 5, speed: 7.0)
        speed = 7.0
        while speed < 11.0 {
            setShiftInput(params: params, cadence: 0, power: 0, speed: speed)
            chain.start(service: service, params: params)
            _ = getShiftOutput(params: params, assertionNoShift: {}, assertionShift: {
                XCTAssertEqual(self.service.getBestGear(frontIndex: params.frontIndex, rpm: params.cadenceTarget, speed: params.speed), params.rearIndex)
            })
            speed += 0.2
        }
    }
    
    public func testShiftResetOnStop() {
        let params = ShiftParameters()
        setupParameters(params: params, cadenceTarget: 90, powerTarget: 175, ftp: 250)
        setShiftInput(params: params, cadence: 90, power: 180, rear: 2, speed: 10.0)
        var speed = 10.0
        while speed > 6.0 {
            setShiftInput(params: params, cadence: 0, power: 0, speed: speed)
            chain.start(service: service, params: params)
            _ = getShiftOutput(params: params, assertionNoShift: {}, assertionShift: {})
            speed -= 0.25
        }
        
        XCTAssertEqual(params.rearIndex, 5)
        
        setShiftInput(params: params, speed: 6.0)
        chain.start(service: service, params: params)
        _ = getShiftOutput(params: params, assertionNoShift: {}, assertionShift: {})
        
        setShiftInput(params: params, speed: 6.0)
        chain.start(service: service, params: params)
        _ = getShiftOutput(params: params, assertionNoShift: {}, assertionShift: {})
        
        setShiftInput(params: params, speed: 0)
        chain.start(service: service, params: params)
        _ = getShiftOutput(params: params, assertionNoShift: {}, assertionShift: {})
        
        XCTAssertEqual(params.rearIndex, 2)
        
        setupParameters(params: params, cadenceTarget: 90, powerTarget: 175, ftp: 250)
        setShiftInput(params: params, cadence: 90, power: 180, rear: 2, speed: 10.0)
        speed = 10.0
        while speed > 6.0 {
            setShiftInput(params: params, cadence: 0, power: 0, speed: speed)
            chain.start(service: service, params: params)
            _ = getShiftOutput(params: params, assertionNoShift: {}, assertionShift: {})
            speed -= 0.25
        }
        
        XCTAssertEqual(params.rearIndex, 5)
        
        setShiftInput(params: params, cadence: 10, power: 100, speed: 6.0)
        chain.start(service: service, params: params)
        _ = getShiftOutput(params: params, assertionNoShift: {}, assertionShift: {})
        
        setShiftInput(params: params, cadence: 10, power: 100, speed: 6.0)
        chain.start(service: service, params: params)
        _ = getShiftOutput(params: params, assertionNoShift: {}, assertionShift: {})
        
        setShiftInput(params: params, speed: 0)
        chain.start(service: service, params: params)
        _ = getShiftOutput(params: params, assertionNoShift: {}, assertionShift: {})
        
        XCTAssertEqual(params.rearIndex, 5)
        
        setupParameters(params: params, cadenceTarget: 90, powerTarget: 175, ftp: 250)
        setShiftInput(params: params, cadence: 90, power: 180, rear: 5, speed: 6.0)
        speed = 6.0
        while speed < 10.0 {
            setShiftInput(params: params, cadence: 0, power: 0, speed: speed)
            chain.start(service: service, params: params)
            _ = getShiftOutput(params: params, assertionNoShift: {}, assertionShift: {})
            speed += 0.25
        }
        
        XCTAssertEqual(params.rearIndex, 2)
        
        setShiftInput(params: params, speed: 10.0)
        chain.start(service: service, params: params)
        _ = getShiftOutput(params: params, assertionNoShift: {}, assertionShift: {})
        
        setShiftInput(params: params, speed: 10.0)
        chain.start(service: service, params: params)
        _ = getShiftOutput(params: params, assertionNoShift: {}, assertionShift: {})
        
        setShiftInput(params: params, speed: 0)
        chain.start(service: service, params: params)
        _ = getShiftOutput(params: params, assertionNoShift: {}, assertionShift: {})
        
        XCTAssertEqual(params.rearIndex, 5)
    }

            
    public func testDriveModeUp() {
        let params = ShiftParameters()
        setupParameters(params: params, cadenceTarget: 90, powerTarget: 175, ftp: 250)
        params.driveMode = true
        var rpm = 0
        var watt = 250
        setShiftInput(params: params, cadence: 5, power: 200, rear: 8)
        while params.speed < params.startSpeed {
            rpm += 5
            setShiftInput(params: params, cadence: rpm, power: watt, rear: params.rearIndex)
            chain.start(service: service, params: params)
            rpm = getShiftOutput(params: params, assertionNoShift: {}, assertionShift: {}).0
            watt -= 5
        }
        while params.speed < 11.2 {
            rpm += 1
            watt += 3
            setShiftInput(params: params, cadence: rpm, power: watt, rear: params.rearIndex)
            chain.start(service: service, params: params)
            rpm = getShiftOutput(params: params, assertionNoShift: {}, assertionShift: {
                switch  params.shiftId {
                case 1:
                    // 23 - 21
                    XCTAssertEqual(params.shiftCadence, 94)
                case 2:
                    // 21 - 19
                    XCTAssertEqual(params.shiftCadence, 96)
                case 3:
                    // 19 - 17
                    XCTAssertEqual(params.shiftCadence, 95)
                case 4:
                    // 17 - 15
                    XCTAssertEqual(params.shiftCadence, 95)
                case 5:
                    // 15 - 14
                    XCTAssertEqual(params.shiftCadence, 93)
                case 6:
                    // 14 - 13
                    XCTAssertEqual(params.shiftCadence, 93)
                case 7:
                    // 13 - 12
                    XCTAssertEqual(params.shiftCadence, 93)
                case 8:
                    // 12 - 11
                    XCTAssertEqual(params.shiftCadence, 94)
                default:
                    print("\(params.shiftId)")
                }
                }).0
        }
    }

    public func testDriveModeDown() {
        
        let params = ShiftParameters()
        setupParameters(params: params, cadenceTarget: 90, powerTarget: 175, ftp: 250)
        params.driveMode = true
        var rpm = 90
        var watt = 200
        setShiftInput(params: params, cadence: 90, power: watt, rear: 0)
        while params.speed > 4.5 {
            rpm -= 1
            watt += 3
            setShiftInput(params: params, cadence: rpm, power: watt)
            chain.start(service: service, params: params)
            rpm = getShiftOutput(params: params, assertionNoShift: {}, assertionShift: {
                switch  params.shiftId {
                case 1:
                    // 11 - 12
                    XCTAssertEqual(params.shiftCadence, 86)
                case 2:
                    // 12 - 13
                    XCTAssertEqual(params.shiftCadence, 86)
                case 3:
                    // 13 - 14
                    XCTAssertEqual(params.shiftCadence, 86)
                case 4:
                    // 14 - 15
                    XCTAssertEqual(params.shiftCadence, 87)
                case 5:
                    // 15 - 17
                    XCTAssertEqual(params.shiftCadence, 84)
                case 6:
                    // 17 - 19
                    XCTAssertEqual(params.shiftCadence, 85)
                case 7:
                    // 19 - 21
                    XCTAssertEqual(params.shiftCadence, 85)
                case 8:
                    // 21 - 23
                    XCTAssertEqual(params.shiftCadence, 86)
                case 9:
                    // 23 - 25
                    XCTAssertEqual(params.shiftCadence, 86)
                case 10:
                    // 25 - 28
                    XCTAssertEqual(params.shiftCadence, 85)
                default:
                    print("\(params.shiftId)")
                }
                }).0
        }
    }
    
    public func testDriveMode() {
        
        let params = ShiftParameters()
        setupParameters(params: params, cadenceTarget: 90, powerTarget: 175, ftp: 250)
        params.driveMode = true
        setShiftInput(params: params, cadence: 90, power: 180, rear: 5, speed: 7.2)
        for _ in 1 ... 150 {
            setShiftInput(params: params, cadence: 92, power: 183)
        }
        let input = [(90,185,7.2),(90,190,7.2),(89,193,7.1),(89,250,7.0),(87,270,6.96),(85,290,6.8),(88,305,6.3),(88,310,6.3),(88,330,6.3),(88,330,6.3),(88,330,6.3),(88,330,6.3),(88,330,6.3),(90,300,6.3),(92,200,6.3)]
        for p in input {
            setShiftInput(params: params, cadence: p.0, power: p.1, speed: p.2)
            chain.start(service: service, params: params)
            _ = getShiftOutput(params: params, assertionNoShift: {}, assertionShift: {})
        }
        
        setShiftInput(params: params, cadence: 97, power: 50, speed: 7)
        chain.start(service: service, params: params)
        _ = getShiftOutput(params: params, assertionNoShift: {}, assertionShift: {})
        
        print("")
        reset()
        params.reset()
        setShiftInput(params: params, cadence: 90, power: 180, rear: 5, speed: 7.2)
        chain.start(service: service, params: params)
        _ = getShiftOutput(params: params, assertionNoShift: {}, assertionShift: {})
        setShiftInput(params: params, cadence: 93, power: 180, rear: 5, speed: 7.4)
        chain.start(service: service, params: params)
        _ = getShiftOutput(params: params, assertionNoShift: {}, assertionShift: {})
        setShiftInput(params: params, cadence: 96, power: 180, speed: 7.68)
        chain.start(service: service, params: params)
        _ = getShiftOutput(params: params, assertionNoShift: {}, assertionShift: {})
        setShiftInput(params: params, cadence: 96, power: 180, speed: 7.68)
        chain.start(service: service, params: params)
        _ = getShiftOutput(params: params, assertionNoShift: {}, assertionShift: {})
        setShiftInput(params: params, cadence: 96, power: 180, speed: 7.68)
        setShiftInput(params: params, cadence: 96, power: 180, speed: 7.68)
        setShiftInput(params: params, cadence: 96, power: 180, speed: 7.68)
        setShiftInput(params: params, cadence: 96, power: 180, speed: 7.71)
        chain.start(service: service, params: params)
        _ = getShiftOutput(params: params, assertionNoShift: {}, assertionShift: {})
        
        print("")
        reset()
        params.reset()
        setShiftInput(params: params, cadence: 90, power: 180, rear: 5, speed: 7.2)
        chain.start(service: service, params: params)
        _ = getShiftOutput(params: params, assertionNoShift: {}, assertionShift: {})
        setShiftInput(params: params, cadence: 93, power: 180, rear: 5, speed: 7.4)
        chain.start(service: service, params: params)
        _ = getShiftOutput(params: params, assertionNoShift: {}, assertionShift: {})
        setShiftInput(params: params, cadence: 96, power: 180, speed: 7.68)
        chain.start(service: service, params: params)
        _ = getShiftOutput(params: params, assertionNoShift: {}, assertionShift: {})
        setShiftInput(params: params, cadence: 96, power: 180, speed: 7.68)
        chain.start(service: service, params: params)
        _ = getShiftOutput(params: params, assertionNoShift: {}, assertionShift: {})
        setShiftInput(params: params, cadence: 96, power: 180, speed: 7.68)
        setShiftInput(params: params, cadence: 96, power: 180, speed: 7.68)
        setShiftInput(params: params, cadence: 96, power: 180, speed: 7.68)
        setShiftInput(params: params, cadence: 96, power: 80, speed: 7.71)
        chain.start(service: service, params: params)
        _ = getShiftOutput(params: params, assertionNoShift: {}, assertionShift: {})
    }
    
    public func testReplaySessionRecording() {
        let params = ShiftParameters()
        setupParameters(params: params, cadenceTarget: 90, powerTarget: 175, ftp: 350)
        params.driveMode = true
        params.rearIndex = 1
        let recording = read(filename: "autoshift")
        for index in 3770 ... recording.count {
            let record = recording[index]
            setShiftInput(params: params, cadence: record.1, power: record.2, speed: record.4)
            chain.start(service: service, params: params)
            _ = getShiftOutput(params: params, assertionNoShift: {
                print("\(record.6) \(record.7)")
            }, assertionShift: {
                print("\(record.6) \(record.7)")
            })
            if index == 3830 {
                break
            }
        }
    }
    
    public func offtestReplaySessionRecording2() {
        let params = ShiftParameters()
        setupParameters(params: params, cadenceTarget: 90, powerTarget: 175, ftp: 350)
        params.driveMode = true
        params.rearIndex = 1
        let recording = read(filename: "autoshift")
        for index in 1 ... recording.count - 1 {
            let record = recording[index]
            setShiftInput(params: params, cadence: record.1, power: record.2, speed: record.4)
            chain.start(service: service, params: params)
            _ = getShiftOutput(params: params, assertionNoShift: {}, assertionShift: {})
            if record.7 == "shift up" || record.7 == "shift down" || true {
                print("\(record.5),\(params.powerActual),\(params.power13.getValue()),\(params.power23.getValue()),\(params.powerValue)")
            }
        }
    }

    public func testGearBox() {
        let params = ShiftParameters();
        
        setShiftInput(params: params, cadence: 96, power: 160)
        let gear = service.getBestGear(frontIndex: 0, rpm: 90, speed: (28/3.6))
        XCTAssertEqual(gear, 4)
                
        let rpm = service.getRPM(frontIndex: 0, rearIndex: 4, speed: (28/3.6))
        XCTAssertEqual(rpm, 85)
        
        var speed = service.getSpeed(frontIndex: 0, rearIndex: 4, rpm: 88)
        speed = speed * 3.6
        speed.round()
        XCTAssertEqual(speed, 29)
                
        speed = 0.0
        while speed < 20 {
            XCTAssertNotNil(service.getBestGear(frontIndex: 0, rpm: 90, speed: speed))
            speed += 0.1
        }
        
        _ = service.getBestGear(frontIndex: 0, rpm: 0, speed: 10)
        _ = service.getSpeed(frontIndex: 0, rearIndex: 5, rpm: 0)
        _ = service.getRPM(frontIndex: 0, rearIndex: -1, speed: 9.72921102426984)
        _ = service.getRPM(frontIndex: 0, rearIndex: 11, speed: 9.72921102426984)
        
        let rpm1 = service.getRPM(frontIndex: 0, rearIndex: 1, speed: 9.72921102426984)
        let rpm2 = service.getRPM(frontIndex: 0, rearIndex: 2, speed: 9.72921102426984)
        print("\(rpm1) \(rpm2)")
    }
    
    public func testGears() {
    
        for gear in 0 ... 10 {
            for rpm in 80 ... 100 {
                let speed = service.getSpeed(frontIndex: 0, rearIndex: gear, rpm: rpm)
                print("\(gear) \(rpm) \(speed) \(service.getBestGear(frontIndex: 0, rpm: 90, speed: speed))")
            }
        }
        
        for speed in 0 ... 130 {
            print("\(Double(speed) / 10) \(service.getBestGear(frontIndex: 0, rpm: 90, speed: Double(speed) / 10))")
        }
        
        print("\(service.getAverageDistance(rpm: 90))")
    }
    
    public func testAdaptionTimeFormula() {
        
        for index in 0 ... 9 {
            print("\(index) \(service.findGear(frontIndex: 0, rearIndex: index).getDesc()) \(Int(-3/81 * pow(Double(index), 2) + 4)) \(round(-3/81 * pow(Double(index), 2)) + 4)")
        }
    }
    
    private func setupParameters(params: ShiftParameters, cadenceTarget: Int, powerTarget: Int, ftp: Int) {
    
        cim.setTarget(target: cadenceTarget)
        cim.setTolerance(tolerance: 3)
        pim.setTarget(target: powerTarget)
        pim.setTolerance(tolerance: 25)
        params.ftp = ftp
    }

    private func setShiftInput(params: ShiftParameters, cadence: Int = 0, power: Int = 0, rear: Int = -1, speed: Double = -1.0) {
        
        cim.queue(v: cadence)
        pim.queue(v: power)
        
        // power
        let powerMeterData = pim
        params.powerValue = powerMeterData.getValue()
        params.powerActual = powerMeterData.getLastValue()
        params.powerLastNotification = powerMeterData.getLastNotificationTime()
        params.powerProgress = powerMeterData.getProgressValue()
        params.powerTarget = powerMeterData.getTarget()
        params.powerMin = powerMeterData.getMinLimit()
        params.powerMax = powerMeterData.getMaxLimit()
        params.powerRange = params.powerTarget - params.powerMin
        params.powerTotalAvg = powerMeterData.getTotalAvg()
        
        // cadence
        let cadenceMeterData = cim
        params.cadenceValue = cadenceMeterData.getValue()
        params.cadenceActual = cadenceMeterData.getLastValue()
        params.cadenceLastNotification = cadenceMeterData.getLastNotificationTime()
        params.cadenceProgress = cadenceMeterData.getProgressValue()
        params.cadenceTarget = cadenceMeterData.getTarget()
        params.cadenceMin = cadenceMeterData.getMinLimit()
        params.cadenceMax = cadenceMeterData.getMaxLimit()
        
        params.count += 1
        params.frontIndex = 0
        
        if rear > -1 {
            params.rearIndex = rear
        }
        
        let s = params.speed
        if speed > -0.9 {
            params.speed = speed
        } else {
            params.speed = service.getSpeed(frontIndex: params.frontIndex, rearIndex: params.rearIndex, rpm: cadence)
        }
        params.acceleration = params.speed - s
        
        params.comment = ""
        
        service._shiftUp = {
            params.snapShot(direction: .rearUp)
            self.pim.shrink()
        }
        service._shiftDown = {
            params.snapShot(direction: .rearDown)
            self.pim.shrink()
        }
    }
    
    func getShiftOutput(params: ShiftParameters, assertionNoShift: @escaping(() -> ()), assertionShift: @escaping(() -> ())) -> (Int,Int) {
        
        print("\((String(format: "%4.2f", params.speed * 3.6))) - \(params.cadenceValue) (\(params.cadenceActual)) - \(params.powerValue) - \(service.findGear(frontIndex: params.frontIndex, rearIndex: params.rearIndex).getDesc()) - \(chain.getLastFilterName()) - \(params.comment)")
        params.filter = chain.getLastFilterName()
        params.log()
        if params.shiftPerformed {
            print("- \(params.shiftId) --- \(params.powerValue) --- \(params.powerTotalAvg) ----------------------")
            assertionShift()
            sleep(1)
            return (service.getRPM(frontIndex: params.frontIndex, rearIndex: params.rearIndex, speed: params.speed), params.rearIndex)
        } else {
            assertionNoShift()
            sleep(1)
            return (params.cadenceActual, params.rearIndex)
        }
    }
    
    func reset() {
        cim.clear()
        pim.clear()
    }
    
    func read(filename: String) -> [(Int,Int,Int,Int,Double,Int,String,String)] {
        let testBundle = Bundle(for: type(of: self))
        guard let ressourceURL = testBundle.url(forResource: filename, withExtension: "csv") else {
            print("no session file with name \(filename).json found")
            return [(Int,Int,Int,Int,Double,Int,String,String)]()
        }
        do {
            var dataArray : [(Int,Int,Int,Int,Double,Int,String,String)] = []
            let data = try Data(contentsOf: ressourceURL)
            let dataEncoded = String(data: data, encoding: .utf8)
            if let dataArr = dataEncoded?.components(separatedBy: "\n").map({ $0.components(separatedBy: ";") }) {
                for line in dataArr {
                    if line.count > 7 {
                        if let row = Int(line[0]) {
                            if let rpm = Int(line[2]) {
                                if let power = Int(line[3]) {
                                    if let rear = Int(line[4]) {
                                        if let speed = Double(line[6]) {
                                            if let shift = Int(line[7]) {
                                                let filter = line[8]
                                                let comment = line[9]
                                                dataArray.append((row,rpm,power,rear,speed,shift,filter,comment))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            return dataArray
        } catch let error {
            print(error)
        }
        return [(Int,Int,Int,Int,Double,Int,String,String)]()
    }

}
