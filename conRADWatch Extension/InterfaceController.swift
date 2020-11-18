//
//  InterfaceController.swift
//  conRADWatch Extension
//
//  Created by Conrad Moeller on 17.11.20.
//  Copyright © 2020 Conrad Moeller. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit
import WatchConnectivity


class InterfaceController: WKInterfaceController {

    @IBOutlet weak var hrLabel: WKInterfaceLabel!
    @IBOutlet weak var startStop: WKInterfaceButton!

    var started = false;

    var workoutSession: HKWorkoutSession?
    var watchSession = WCSession.default

    override func awake(withContext context: Any?) {
        hrLabel.setText("off")
    }
    
    override func willActivate() {
        super.willActivate()
        if WCSession.isSupported() {
            watchSession.delegate = self
            watchSession.activate()
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }

    @IBAction func startStopPushed() {
        if started {
            stopWorkout()
        } else {
            startWorkout()
        }
    }
    
    func stopWorkout() {
        workoutSession?.stopActivity(with: Date())
        workoutSession?.end()
        workoutSession = nil
        startStop.setTitle("Start")
        startStop.setBackgroundColor(UIColor.blue)
        started = false
    }
    
    func startWorkout() {
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .cycling
        workoutConfiguration.locationType = .outdoor
        do {
            if workoutSession == nil {
                workoutSession = try HKWorkoutSession(healthStore: HealthDataConnector.sharedInstance.healthStore!, configuration: workoutConfiguration)
                workoutSession?.startActivity(with: Date())
                
                startStop.setTitle("Stop")
                startStop.setBackgroundColor(UIColor.red)
                started = true
            }
            monitorHeartRate()
        } catch {
            print("Error starting workout session: \(error.localizedDescription)")
        }
    }
    
    func monitorHeartRate() {
        HealthDataConnector.sharedInstance.observeHeartRateSamples({(heartRate) -> (Void) in
            self.sendHeartRate(heartRate: heartRate)
        })
    }
    
    func sendHeartRate(heartRate: Double) {
        if started && watchSession.isReachable {
            self.hrLabel.setText("on")
            watchSession.sendMessage(["heartRate" : heartRate], replyHandler: nil, errorHandler: { (error) in
                self.hrLabel.setText("err")
            })
        } else {
            hrLabel.setText("off")
            watchSession.sendMessage(["heartRate" : 0.0], replyHandler: nil, errorHandler: { (error) in
                self.hrLabel.setText("err")
            })
        }
    }

}

extension InterfaceController: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidCompleteWith activationState:\(activationState) error:\(String(describing: error))")
    }
}
