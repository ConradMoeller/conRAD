//
//  CycleViewController.swift
//  UltimateTriTrainer
//
//  Created by Conrad Moeller on 02.10.18.
//  Copyright © 2018 Conrad Moeller. All rights reserved.
//

import AVFoundation
import UIKit
import CoreLocation

class CycleViewController: UIViewController {

    let formatter = DateFormatter()

    @IBOutlet weak var startStopBox: UIView!
    @IBOutlet weak var distanceBox: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var altBox: UIView!
    @IBOutlet weak var speedBox: UIView!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var rpmBox: UIView!
    @IBOutlet weak var hrBox: UIView!
    @IBOutlet weak var powerBox: UIView!
    @IBOutlet weak var gearBox: UIView!

    @IBOutlet weak var heartRateView: MeterDataProgressView!
    @IBOutlet weak var wattageView: MeterDataProgressView!
    @IBOutlet weak var cadenceView: MeterDataProgressView!

    @IBOutlet weak var timeValue: UILabel!
    @IBOutlet weak var intervalProgress: UIProgressView!
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
    @IBOutlet weak var gear1: UILabel!
    @IBOutlet weak var gear2: UILabel!
    
    var metricSystem = true
    var timer: Timer!
    var log = true
    
    var dataCollector = DataCollectionService.getInstance()

    var bike: Bicycle!
    
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
        updateSystem()
        resetView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        updateSystem()
        bike = MasterDataRepo.readBicycle()
        if timer != nil {
            timer.invalidate()
        }
        if dataCollector.recordingStarted {
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateAll), userInfo: nil, repeats: true)
            dataCollector.intervalChange = alertIntervalChange
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
    
    func updateSystem() {
        let cyclist = MasterDataRepo.readCyclist()
        metricSystem = cyclist.metricSystem
        if metricSystem {
            distanceLabel.text = "km"
            speedLabel.text = "km/h"
        } else {
            distanceLabel.text = "mi"
            speedLabel.text = "mph"
        }
    }

    func resetView() {
        timeValue.text = "00:00:00"
        intervalProgress.isHidden = true
        distanceValue.text = "0.00"
        speedValue.text = "0.0"
        optSpeed.text = NSLocalizedString("Gear", comment: "no comment")
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
        let factor1 = metricSystem ? 1000 : 1609.344
        distanceValue.text = String(format: "%4.2f", distance / factor1)

        altValue.text = String(format: "%4.0f", dataCollector.getAltitude())
        
        let speed = dataCollector.getSpeed()
        let factor2 = metricSystem ? 3.6 : 2.23694
        speedValue.text = String(format: "%.1f", speed * factor2)
        if abs(duration) > 0 {
            avgSpeedValue.text = "(\(String(format: "%.1f", abs(distance) / abs(duration) * factor2)))"
        }
        
        let hrData = dataCollector.getHRData()
        hrValue.text = String(hrData.getValue())

        let cadenceData = dataCollector.getCadenceData()
        cadenceValue.text = String(cadenceData.getValue())

        let pmData = dataCollector.getPowerData()
        pwrValue.text = String(pmData.getValue())
        let pbl = dataCollector.getPowerBalance()
        powerBalance.text = "\(pbl) / \(100 - pbl)"
        
        let gearbox = bike.getGearBox()
        let rollOut = dataCollector.getRollOut()
        gear1.text = gearbox.findGear(frontIndex: 0, rollOut: rollOut).getDesc()
        gear2.text = gearbox.findGear(frontIndex: 1, rollOut: rollOut).getDesc()
        
    }

    @objc func updateAll() {
        updateMeasurements()
        updateProgress()
    }

    func initProgress() {
        intervalProgress.progress = 0.0
        heartRateView.setConnectionState(isConnected: dataCollector.isHRDeviceConnected())
        wattageView.setConnectionState(isConnected: dataCollector.isPowerMeterDeviceConnected())
        cadenceView.setConnectionState(isConnected: dataCollector.isCadenceDeviceConnected())
    }
    
    func updateProgress() {
        
        intervalProgress.isHidden = false
        intervalProgress.progress = dataCollector.getIntervalProgress()
        
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
    
    func alertIntervalChange(interval: String) {
        let popup = UIAlertController(title: NSLocalizedString("Next Interval: ", comment: "no comment") + interval, message: "", preferredStyle: .alert)
        present(popup, animated: true, completion: nil)
        AudioServicesPlaySystemSound(SystemSoundID(1025))
        Timer.scheduledTimer(withTimeInterval: 10, repeats: false, block: { _ in
            popup.dismiss(animated: true, completion: nil)
        })
    }

}
