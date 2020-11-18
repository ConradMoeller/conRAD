//
//  HeartRateConnector.swift
//  UltimateTriTrainer
//
//  Created by Conrad Moeller on 10.10.18.
//  Copyright © 2018 Conrad Moeller. All rights reserved.
//

import BicycleBLEKit
import WatchConnectivity

class HeartRateConnector: NSObject {

    private let bleKit = BicycleBLEKit()
    private var data: IntMeterData
    
    private var session = WCSession.default

    private var connected = false
    
    required init(hrData: IntMeterData) {
        self.data = hrData
    }

    func connect() {
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
        let bike = MasterDataRepo.readBicycle()
        bleKit.startListenToHeartRateService(deviceId: bike.HRSensorId, delegate: self)
        connected = true
    }
        
    private func isWatchConnected() -> Bool {
        if connected {
            return WCSession.isSupported() && session.isWatchAppInstalled && session.isReachable
        } else {
            return false
        }
    }

    func disconnect() {
        bleKit.stopListenHeartRateService()
        connected = false
    }

    func isDeviceConnected() -> Bool {
        return connected && (bleKit.isHearRateDeviceConnected() || isWatchConnected())
    }
}

extension HeartRateConnector: HeartRateMeasurementDelegate {
    func notifyHeartRate(bpm: Int) {
        self.data.queue(v: bpm)
    }
}

extension HeartRateConnector: WCSessionDelegate  {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        self.session.activate()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let heartRate = message["heartRate"] as? Double {
            if connected {
                self.data.queue(v: Int(heartRate))
            }
        }
    }
    
}
