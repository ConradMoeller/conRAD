//
//  DeviceController.swift
//  UltimateTriTrainer
//
//  Created by Conrad Moeller on 13.10.18.
//  Copyright © 2018 Conrad Moeller. All rights reserved.
//

import UIKit
import FileBrowser
import BicycleBLEKit

class DevicesViewController: UIViewController {

    @IBOutlet weak var headerBox: UIView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var wheelsize: UITextField!
    @IBOutlet weak var crank1: UITextField!
    @IBOutlet weak var crank2: UITextField!
    @IBOutlet weak var sprockets: UITextField!

    let bicycleList = ListViewNavigation()
    
    let detail = DeviceViewNavigation()
    let bleKit = BicycleBLEKit()
    var fileName: UITextField?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        name.delegate = self
        wheelsize.delegate = self
        crank1.delegate = self
        crank2.delegate = self
        sprockets.delegate = self
        bicycleList.listView.listViewDelegate = self
        UIUtil.applyBoxStyle(view: headerBox)
        readBike()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        writeBike()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func newBikePushed(_ sender: Any) {
        let popup = UIAlertController(title: "New Bicyle", message: "Type in the name!", preferredStyle: .alert)
        popup.addTextField(configurationHandler: fileName)
        let ok = UIAlertAction(title: "OK", style: .default, handler: handleOK)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        popup.addAction(ok)
        popup.addAction(cancel)
        present(popup, animated: true, completion: nil)

    }

    func fileName(textField: UITextField) {
        fileName = textField
    }

    func handleOK(action: UIAlertAction) {
        var bike = MasterDataRepo.newBicycle()
        bike.name = (fileName?.text)!
        MasterDataRepo.writeBicycle(bicycle: bike)
        var settings = MasterDataRepo.readSettings()
        settings.bike = bike.id
        MasterDataRepo.writeSettings(settings: settings)
        readBike()
    }

    @IBAction func selectBikePushed(_ sender: Any) {
        present(bicycleList, animated: true, completion: nil)
    }

    @IBAction func hrDevicePushed(_ sender: Any) {
        let bike = MasterDataRepo.readBicycle()
        detail.deviceView.currentId = bike.HRSensorId
        detail.deviceView.currentName = bike.HRSensorName
        detail.deviceView.startScan = bleKit.startScanHeartRateDevices
        detail.deviceView.stopScan = bleKit.stopScanHeartRateDevices
        detail.deviceView.pair = pairHRDevice
        detail.deviceView.unpair = unpairHRDevice
        present(detail, animated: true, completion: nil)
    }

    func pairHRDevice(id: String, name: String) {
        var bike = MasterDataRepo.readBicycle()
        bike.HRSensorId = id
        bike.HRSensorName = name
        MasterDataRepo.writeBicycle(bicycle: bike)
    }

    func unpairHRDevice() {
        var bike = MasterDataRepo.readBicycle()
        bike.HRSensorId = ""
        bike.HRSensorName = ""
        MasterDataRepo.writeBicycle(bicycle: bike)
    }

    @IBAction func powerMeterPushed(_ sender: Any) {
        let bike = MasterDataRepo.readBicycle()
        detail.deviceView.currentId = bike.PowerSensorId
        detail.deviceView.currentName = bike.PowerSensorName
        detail.deviceView.startScan = bleKit.startScanPowerDevices
        detail.deviceView.stopScan = bleKit.stopScanPowerDevices
        detail.deviceView.pair = pairPowerDevice
        detail.deviceView.unpair = unpairPowerDevice
        present(detail, animated: true, completion: nil)
    }

    func pairPowerDevice(id: String, name: String) {
        var bike = MasterDataRepo.readBicycle()
        bike.PowerSensorId = id
        bike.PowerSensorName = name
        MasterDataRepo.writeBicycle(bicycle: bike)
    }

    func unpairPowerDevice() {
        var bike = MasterDataRepo.readBicycle()
        bike.PowerSensorId = ""
        bike.PowerSensorName = ""
        MasterDataRepo.writeBicycle(bicycle: bike)
    }

    @IBAction func cscMeterPushed(_ sender: Any) {
        let bike = MasterDataRepo.readBicycle()
        detail.deviceView.currentId = bike.CSCSensorId
        detail.deviceView.currentName = bike.CSCSensorName
        detail.deviceView.startScan = bleKit.startScanCSCDevices
        detail.deviceView.stopScan = bleKit.stopScanCSCDevices
        detail.deviceView.pair = pairCSCDevice
        detail.deviceView.unpair = unpairCSCDevice
        present(detail, animated: true, completion: nil)
    }

    func pairCSCDevice(id: String, name: String) {
        var bike = MasterDataRepo.readBicycle()
        bike.CSCSensorId = id
        bike.CSCSensorName = name
        MasterDataRepo.writeBicycle(bicycle: bike)
    }

    func unpairCSCDevice() {
        var bike = MasterDataRepo.readBicycle()
        bike.CSCSensorId = ""
        bike.CSCSensorName = ""
        MasterDataRepo.writeBicycle(bicycle: bike)
    }

    func readBike() {
        let bike = MasterDataRepo.readBicycle()
        name.text = bike.name
        wheelsize.text = bike.wheelSize
        crank1.text = bike.crank1
        crank2.text = bike.crank2
        sprockets.text = bike.sprockets
    }

    func writeBike() {
        var bike = MasterDataRepo.readBicycle()
        bike.name = name.text!
        bike.wheelSize = wheelsize.text!
        bike.crank1 = crank1.text!
        bike.crank2 = crank2.text!
        bike.sprockets = sprockets.text!
        MasterDataRepo.writeBicycle(bicycle: bike)
    }
}

extension DevicesViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == name {
            return true
        }
        let  char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        if isBackSpace == -92 {
            return true
        }
        if textField == sprockets && string == "," {
            return true
        }
        if Int(string) == nil {
            return false
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        writeBike()
        return true
    }

}

extension DevicesViewController: ListViewDelegate {
    
    func getFileList() -> [(id: String, name: String)] {
        var result = [(id: String, name: String)]()
        let bicycles = MasterDataRepo.readBicycles()
        for bicycle in bicycles {
            result.append((bicycle.id, bicycle.name))
        }
        return result
    }
    
    func setSelectedFile(id: String) {
        var settings = MasterDataRepo.readSettings()
        settings.bike = id
        MasterDataRepo.writeSettings(settings: settings)
        readBike()
    }
    
    func removeFile(id: String) {
        MasterDataRepo.deleteBike(id: id)
    }

}

