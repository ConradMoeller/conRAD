//
//  conRADTests.swift
//  conRADTests
//
//  Created by Conrad Moeller on 15.09.19.
//  Copyright © 2019 Conrad Moeller. All rights reserved.
//

import XCTest
@testable import conRAD

class MeterDataTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testIntMeterData() {
 
        var intData = IntMeterData(useLastValue: false, bufferSize: 5)
        intData.queue(v: 1)
        intData.queue(v: 2)
        intData.queue(v: 3)
        XCTAssertEqual(intData.getLastDeviation(), 1)
        XCTAssertEqual(intData.getDeviationSum(), 3)
        intData.queue(v: 4)
        intData.queue(v: 5)
        XCTAssertEqual(intData.getValue(), 3)
        intData.queue(v: 6)
        XCTAssertEqual(intData.getLastDeviation(), 1)
        XCTAssertEqual(intData.getDeviationSum(), 5)
        XCTAssertEqual(intData.getValue(), 4)
        intData.queue(v: 6)
        XCTAssertEqual(intData.getValue(), 4)
        XCTAssertEqual(intData.getLastDeviation(), 0)
        XCTAssertEqual(intData.getDeviationSum(), 4)
        XCTAssertEqual(intData.getDeviationSum(last: 2), 1)
        intData.queue(v: 6)
        XCTAssertEqual(intData.getValue(), 5)
        XCTAssertEqual(intData.getAvgValue(), 5)
        XCTAssertEqual(intData.getLastValue(), 6)
        XCTAssertEqual(intData.getTotalAvg(), 4)
        XCTAssertEqual(intData.getTotalMax(), 6)
        XCTAssertEqual(intData.getTotalSum(), 33)
        XCTAssertEqual(intData.getRange(), 2)
        XCTAssertEqual(intData.getSigma(), 0)
        
        intData = IntMeterData(useLastValue: false, bufferSize: 15)
        let _ = intData.getRange()
        intData.queue(v: 160)
        intData.queue(v: 176)
        intData.queue(v: 200)
        intData.queue(v: 222)
        intData.queue(v: 254)
        intData.queue(v: 192)
        intData.queue(v: 172)
        intData.queue(v: 162)
        intData.queue(v: 160)
        intData.queue(v: 174)
        intData.queue(v: 256)
        intData.queue(v: 168)
        intData.queue(v: 188)
        intData.queue(v: 234)
        intData.queue(v: 230)
        XCTAssertEqual(intData.getMinValue(), 160)
        XCTAssertEqual(intData.getMaxValue(), 256)
        XCTAssertEqual(intData.getAvgValue(), 196)
        XCTAssertEqual(intData.getRange(), 96)
        XCTAssertEqual(intData.getSigma(), 32)
        intData.shrink()
        XCTAssertEqual(intData.getValue(), 196)
        XCTAssertEqual(intData.getLastValue(), 196)
        XCTAssertEqual(intData.getMinValue(), 196)
        XCTAssertEqual(intData.getMaxValue(), 196)
        XCTAssertEqual(intData.getAvgValue(), 196)
        intData.queue(v: 200)
        XCTAssertEqual(intData.getValue(), 198)
        XCTAssertEqual(intData.getLastValue(), 200)
        XCTAssertEqual(intData.getMinValue(), 196)
        XCTAssertEqual(intData.getMaxValue(), 200)
        XCTAssertEqual(intData.getAvgValue(), 198)
        
        XCTAssertEqual(intData.getTotalNotifications(), 16)
        XCTAssertEqual(intData.count(), 2)
        XCTAssertEqual(intData.getFirstValue(), 196)
        intData.resetTotals()
        XCTAssertEqual(intData.getTotalNotifications(), 0)
        
        intData = IntMeterData(useLastValue: true, bufferSize: 2)
        intData.queue(v: 1)
        XCTAssertEqual(intData.getValue(), 1)
        intData.queue(v: 3)
        XCTAssertEqual(intData.getValue(), 3)

        intData = IntMeterData(useLastValue: false, bufferSize: 1)
        intData.queue(v: 1)
        XCTAssertEqual(intData.getValue(), 1)
        intData.queue(v: 3)
        XCTAssertEqual(intData.getValue(), 3)
        
        intData = IntMeterData(useLastValue: false, bufferSize: 5)
        intData.queue(v: 1)
        sleep(1)
        intData.queue(v: 2)
        sleep(1)
        intData.queue(v: 3)
        XCTAssertEqual(intData.getValue(), 2)
        
        sleep(1)
        intData.queue(v: 0)
        XCTAssertEqual(intData.getValue(), 0)
        
        sleep(1)
        intData.queue(v: 0)
        XCTAssertEqual(intData.getValue(), 0)
        
        sleep(1)
        intData.queue(v: 1)
        XCTAssertEqual(intData.getValue(), 1)
        
        sleep(1)
        intData.queue(v: 3)
        XCTAssertEqual(intData.getValue(), 2)
        
        sleep(2)
        XCTAssertEqual(intData.getValue(), 0)
    }
    
    func testDoubleMeterData() {
        
        let doubleData = DoubleMeterData(useLastValue: false, bufferSize: 5)
        doubleData.queue(v: 1.0)
        doubleData.queue(v: 2.0)
        doubleData.queue(v: 3.0)
        doubleData.queue(v: 4.0)
        doubleData.queue(v: 5.0)
        XCTAssertEqual(doubleData.getValue(), 3.0)
        doubleData.queue(v: 6)
        XCTAssertEqual(doubleData.getValue(), 4.0)
        doubleData.queue(v: 6)
        XCTAssertEqual(doubleData.getValue(), 4.8)
        doubleData.queue(v: 6)
        XCTAssertEqual(doubleData.getValue(), 5.4)
        XCTAssertEqual(doubleData.getAvgValue(), 5.4)
        XCTAssertEqual(doubleData.getLastValue(), 6)
        XCTAssertEqual(doubleData.getTotalAvg(), 4.125)
        XCTAssertEqual(doubleData.getTotalMax(), 6)
        XCTAssertEqual(doubleData.getTotalSum(), 33)
        
        XCTAssertEqual(doubleData.getTotalNotifications(), 8)
        XCTAssertEqual(doubleData.count(), 5)
        doubleData.resetTotals()
        XCTAssertEqual(doubleData.getTotalNotifications(), 0)
    }

}
