//
//  DeviceViewController.swift
//  UltimateTriTrainer
//
//  Created by Conrad Moeller on 24.11.18.
//  Copyright © 2018 Conrad Moeller. All rights reserved.
//

import UIKit
import BicycleBLEKit

class DeviceViewNavigation: UINavigationController {

    var deviceView: DeviceViewController!

    convenience init() {
        let d = DeviceViewController()
        self.init(rootViewController: d)
        self.deviceView = d
    }
}

class DeviceViewController: UIViewController {

    @IBOutlet weak var scanView: UIView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var scanActivity: UIActivityIndicatorView!
    @IBOutlet weak var deviceList: UITableView!
    @IBOutlet weak var info: UILabel!
    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var battery: UILabel!

    var currentId: String!
    var currentName: String!
    
    var nextSetupStep: (() -> Void)!
    var startScan: ((_: BLEDeviceDiscoverDelegate) -> Void)!
    var stopScan: (() -> Void)!
    var pair: ((_: String, _: String) -> Void)!
    var unpair:(() -> Void)!
    var barItemTitle = "Cancel"

    var scanning = false
    var foundDeviceIds: [String] = []
    var foundDeviceNames: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.infoView.isHidden = true
        self.scanView.isHidden = true
        scanActivity.stopAnimating()
        let dismissButton = UIBarButtonItem(title: barItemTitle, style: .plain, target: self, action: #selector(DeviceViewController.dismiss(button:)))
        self.navigationItem.rightBarButtonItem = dismissButton
        deviceList.delegate = self
        deviceList.dataSource = self
        UIUtil.applyBoxStyle(view: deviceList)
    }

    override func viewDidAppear(_ animated: Bool) {
        self.infoView.isHidden = true
        self.scanView.isHidden = true
        scanActivity.stopAnimating()
        scanning = false
        self.info.text = currentName
        self.id.text = currentId
        self.battery.text = "Battery \(0) %"
        if self.id.text == "na" || self.id.text == "" {
            scanButton.setTitle(" Scan for Devices", for: .normal)
            foundDeviceIds.removeAll()
            foundDeviceNames.removeAll()
            deviceList.reloadData()
            self.infoView.isHidden = true
            self.scanView.isHidden = false
        } else {
            self.infoView.isHidden = false
            self.scanView.isHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func dismiss(button: UIBarButtonItem = UIBarButtonItem()) {
        if nextSetupStep != nil {
            nextSetupStep()
        } else {
            dismiss()
        }
    }

    private func dismiss() {
        self.infoView.isHidden = true
        self.scanView.isHidden = true
        self.dismiss(animated: true, completion: nil)
    }

    private func addDevice(device: BLEDevice) {
        foundDeviceIds.append(device.getDeviceId())
        foundDeviceNames.append(device.getDeviceName())
        let indexPath = IndexPath(row: foundDeviceNames.count - 1, section: 0)
        deviceList.beginUpdates()
        deviceList.insertRows(at: [indexPath], with: .automatic)
        deviceList.endUpdates()
    }
    
    @IBAction func findPushed(_ sender: Any) {
        if scanning {
            scanButton.setTitle(" Scan for Devices", for: .normal)
            scanActivity.stopAnimating()
            scanning = false
            stopScan()
        } else {
            scanButton.setTitle(" Stop Scanning", for: .normal)
            scanActivity.startAnimating()
            scanActivity.layer.zPosition = 1
            scanActivity.layer.borderWidth = CGFloat(1.0)
            scanActivity.layer.cornerRadius = CGFloat(10.0)
            scanActivity.layer.borderColor = UIColor.darkGray.cgColor
            scanning = true
            foundDeviceIds.removeAll()
            foundDeviceNames.removeAll()
            deviceList.reloadData()
            startScan(self)
        }
    }

    @IBAction func unpairPushed(_ sender: Any) {
        var bike = MasterDataRepo.readBicycle()
        bike.HRSensorId = ""
        bike.HRSensorName = ""
        MasterDataRepo.writeBicycle(bicycle: bike)
        self.dismiss(animated: true, completion: nil)
    }

}

extension DeviceViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foundDeviceNames.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "DeviceCell"
        var cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        if let reuseCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            cell = reuseCell
        }
        cell.textLabel?.text = foundDeviceNames[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        pair(foundDeviceIds[indexPath.row],foundDeviceNames[indexPath.row])
        if nextSetupStep != nil {
            nextSetupStep()
        } else {
            dismiss()
        }
    }
}

extension DeviceViewController: BLEDeviceDiscoverDelegate {
    func deviceDiscovered(device: BLEDevice) {
        addDevice(device: device)
    }
}
