//
//  CycleViewController.swift
//  UltimateTriTrainer
//
//  Created by Conrad Moeller on 02.10.18.
//  Copyright © 2018 Conrad Moeller. All rights reserved.
//

import UIKit
import CoreLocation

class CycleViewController: UIViewController {

    let formatter = DateFormatter()

    @IBOutlet weak var startStopBox: UIView!
    @IBOutlet weak var distanceBox: UIView!
    @IBOutlet weak var altBox: UIView!
    @IBOutlet weak var speedBox: UIView!
    @IBOutlet weak var rpmBox: UIView!
    @IBOutlet weak var hrBox: UIView!
    @IBOutlet weak var powerBox: UIView!
    @IBOutlet weak var gearBox: UIView!

    @IBOutlet weak var heartRateView: MeterDataProgressView!
    @IBOutlet weak var wattageView: MeterDataProgressView!
    @IBOutlet weak var cadenceView: MeterDataProgressView!

    @IBOutlet weak var timeValue: UILabel!
    @IBOutlet weak var distanceValue: UILabel!
    @IBOutlet weak var speedValue: UILabel!
    @IBOutlet weak var avgSpeedValue: UILabel!
    @IBOutlet weak var optSpeed: UILabel!

    @IBOutlet weak var altValue: UILabel!

    @IBOutlet weak var hrValue: UILabel!
    @IBOutlet weak var currentWattValue: UILabel!
    @IBOutlet weak var powerBalance: UILabel!
    @IBOutlet weak var avgWattValue: UILabel!
    @IBOutlet weak var pwrValue: UILabel!
    @IBOutlet weak var cadenceValue: UILabel!

    var timer: Timer!
    var log = true

    var dataCollector = DataCollectionService.getInstance()

    override func viewDidLoad() {
        super.viewDidLoad()

        UIUtil.applyBoxStyle(view: startStopBox)
        UIUtil.applyBoxStyle(view: distanceBox)
        UIUtil.applyBoxStyle(view: altBox)
        UIUtil.applyBoxStyle(view: hrBox)
        UIUtil.applyBoxStyle(view: rpmBox)
        UIUtil.applyBoxStyle(view: powerBox)
        UIUtil.applyBoxStyle(view: speedBox)
        UIUtil.applyBoxStyle(view: gearBox)

        resetView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        if timer != nil {
            timer.invalidate()
        }
        if dataCollector.recordingStarted {
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateAll), userInfo: nil, repeats: true)
            updateAll()
        } else {
            resetView()
            initProgress()
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateMeasurements), userInfo: nil, repeats: true)
            updateMeasurements()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if dataCollector.recordingStarted {
            timer.invalidate()
        }
    }

    func resetView() {
        timeValue.text = "00:00:00"
        distanceValue.text = "0.00"
        speedValue.text = "0.0"
        optSpeed.text = "--"
        avgSpeedValue.text = "(--)"
        altValue.text = "0"
        hrValue.text = "0"
        currentWattValue.text = "0"
        avgWattValue.text = "0"
        pwrValue.text = "0"
        cadenceValue.text = "0"
        powerBalance.text = "0.0"
    }
    
    @objc func updateMeasurements() {
        let duration = dataCollector.getDuration()
        formatter.timeZone = TimeZone.init(abbreviation: "UTC")
        formatter.dateFormat = "HH:mm:ss"
        timeValue.text = formatter.string(for: Date(timeIntervalSince1970: duration))

        let distance = dataCollector.getDistance()
        distanceValue.text = String(format: "%4.2f", distance / 1000)

        altValue.text = String(format: "%4.0f", dataCollector.getAltitude())
        
        let speed = dataCollector.getSpeed()
        speedValue.text = String(format: "%.1f", speed * 3.6)
        avgSpeedValue.text = "(\(String(format: "%.1f", abs(distance) / abs(duration) * 3.6)))"

        let hrData = dataCollector.getHRData()
        hrValue.text = String(hrData.getValue())

        let cadenceData = dataCollector.getCadenceData()
        cadenceValue.text = String(cadenceData.getValue())

        let pmData = dataCollector.getPowerData()
        pwrValue.text = String(pmData.getValue())
        let pbl = dataCollector.getPowerBalance()
        powerBalance.text = "\(pbl) / \(100 - pbl)"
    }

    @objc func updateAll() {
        updateMeasurements()
        updateProgress()
    }

    func initProgress() {
        heartRateView.setConnectionState(isConnected: dataCollector.isHRDeviceConnected())
        wattageView.setConnectionState(isConnected: dataCollector.isPowerMeterDeviceConnected())
        cadenceView.setConnectionState(isConnected: dataCollector.isCadenceDeviceConnected())
    }
    
    func updateProgress() {
        let hrData = dataCollector.getHRData()
        hrValue.text = String(hrData.getValue())
        heartRateView.updateProgress(isConnected: dataCollector.isHRDeviceConnected(), data: hrData)

        let pmData = dataCollector.getPowerData()
        currentWattValue.text = String(pmData.getLastValue())
        avgWattValue.text = String(pmData.getTotalAvg())
        pwrValue.text = String(pmData.getValue())
        wattageView.updateProgress(isConnected: dataCollector.isPowerMeterDeviceConnected(), data: pmData)

        let cadenceData = dataCollector.getCadenceData()
        cadenceValue.text = String(cadenceData.getValue())
        cadenceView.updateProgress(isConnected: dataCollector.isCadenceDeviceConnected(), data: cadenceData)
    }

}
