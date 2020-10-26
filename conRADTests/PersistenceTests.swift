//
//  PersistenceTests.swift
//  conRADTests
//
//  Created by Conrad Moeller on 27.09.20.
//  Copyright © 2020 Conrad Moeller. All rights reserved.
//

import XCTest
@testable import conRAD

class PersistenceTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testMasterData() throws {
        
        let bicycle = Bicycle(desc: "TT", wheelSize: 2095, crank1: 42, crank2: 42, sprockets: "11,12,13", HRSensorId: "QWE123", HRSensorName: "HR", CSCSensorId: "ASD456", CSCSensorName: "CSC", PowerSensorId: "YXC789", PowerSensorName: "POWER")
        MasterDataRepo.writeBicycle(name: "TT", bicycle: bicycle)
        let bicycle2 = MasterDataRepo.readBicycle(name: "TT")
        XCTAssertEqual(bicycle.desc, bicycle2.desc)
        XCTAssertEqual(bicycle.wheelSize, bicycle2.wheelSize)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
