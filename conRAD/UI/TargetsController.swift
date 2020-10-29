//
//  TargetsController.swift
//  UltimateTriTrainer
//
//  Created by Conrad Moeller on 02.10.18.
//  Copyright © 2018 Conrad Moeller. All rights reserved.
//

import UIKit
import CoreData
import FileBrowser

class TargetsViewController: UIViewController {

    @IBOutlet weak var backGround: UIImageView!

    @IBOutlet weak var headerBox: UIView!
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnOpen: UIButton!

    @IBOutlet weak var bpmAvg: UITextField!
    @IBOutlet weak var wattAvg: UITextField!
    @IBOutlet weak var rpmAvg: UITextField!

    @IBOutlet weak var btBox: UIView!

    @IBOutlet weak var btSwitch: UISwitch!
    @IBOutlet weak var isHRConnected: UIImageView!
    @IBOutlet weak var isCadenceConnected: UIImageView!
    @IBOutlet weak var isPowerConnected: UIImageView!
    @IBOutlet weak var isSpeedConnected: UIImageView!

    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var btnStop: UIButton!

    @IBOutlet weak var stravaUpload: UIActivityIndicatorView!

    let trainingsList = ListViewNavigation()
    
    var dataCollector = DataCollectionService.getInstance()
    
    var btResponseTimer: Timer!
    var i = 0

    var fileName: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()
        sleep(0)
        bpmAvg.delegate = self
        wattAvg.delegate = self
        rpmAvg.delegate = self
        trainingsList.listView.listViewDelegate = self
        readSettings()

        UIUtil.applyBoxStyle(view: headerBox)
        UIUtil.applyBoxStyle(view: btBox)
    }

    private func getFileBrowser() -> FileBrowser {
        let fb = FileBrowser(initialPath: FileTool.getDir(name: "sessions"), allowEditing: true, showCancelButton: true)
        fb.excludesFileExtensions = []
        return fb
    }

    private func readSettings() {
        let training = MasterDataRepo.readTraining()
        bpmAvg.text = training.hr
        wattAvg.text = training.power
        rpmAvg.text = training.cadence
    }

    private func writeSettings() {
        var training = MasterDataRepo.readTraining()
        training.hr = bpmAvg.text!
        training.power = wattAvg.text!
        training.cadence = rpmAvg.text!
        MasterDataRepo.writeTraining(training: training)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkBluetoothState()
        btResponseTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkBluetoothState), userInfo: nil, repeats: true)
        btnStart.isEnabled = !dataCollector.recordingStarted
        btnStop.isEnabled = dataCollector.recordingStarted
        let setup = MasterDataRepo.readSettings()
        if setup.setup {
            let setupUI = InitialSetuptNavigation()
            present(setupUI, animated: true, completion: nil)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        writeSettings()
        if btResponseTimer != nil {
            btResponseTimer.invalidate()
        }
        super.viewDidDisappear(animated)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        bpmAvg.resignFirstResponder()
        wattAvg.resignFirstResponder()
        rpmAvg.resignFirstResponder()
        writeSettings()
    }

    @IBAction func newFilePushed(_ sender: Any) {
        let popup = UIAlertController(title: "New Setup", message: "Type in the name!", preferredStyle: .alert)
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
        var training = MasterDataRepo.newTraining()
        training.name = fileName?.text ?? "new training"
        training.hr = "0"
        training.cadence = "0"
        training.power = "0"
        MasterDataRepo.writeTraining(training: training)
        var settings = MasterDataRepo.readSettings()
        settings.training = training.id
        MasterDataRepo.writeSettings(settings: settings)
        readSettings()
    }

    @IBAction func openFilePushed(_ sender: Any) {
        present(trainingsList, animated: true, completion: nil)
    }

    @IBAction func switchChanged(_ sender: Any) {

        if btSwitch.isOn {
            connectDevices()
        } else {
            disconnectDevices()
        }
    }

    func connectDevices() {
        dataCollector.connectDevices()
    }

    func disconnectDevices() {
        dataCollector.disconnectDevices()
        btnStart.isEnabled = !dataCollector.recordingStarted
        btnStop.isEnabled = dataCollector.recordingStarted
    }

    @objc func checkBluetoothState() {
        if dataCollector.isHRDeviceConnected() {
            isHRConnected.alpha = 1
        } else {
            isHRConnected.alpha = 0.25
        }
        if dataCollector.isPowerMeterDeviceConnected() {
            isPowerConnected.alpha = 1
        } else {
            isPowerConnected.alpha = 0.25
        }
        if dataCollector.isCadenceDeviceConnected() {
            isCadenceConnected.alpha = 1
        } else {
            isCadenceConnected.alpha = 0.25
        }
        if dataCollector.isSpeedDeviceConnected() {
            isSpeedConnected.alpha = 1
        } else {
            isSpeedConnected.alpha = 0.25
        }
    }

    @IBAction func startPushed(_ sender: Any) {

        if !btSwitch.isOn {
            btSwitch.setOn(true, animated: true)
            let popup = UIAlertController(title: "Starting Session", message: "Connecting to BLE Devices!", preferredStyle: .alert)
            present(popup, animated: true, completion: nil)
            connectDevices()
            Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { _ in
                popup.dismiss(animated: true, completion: {
                    self.dataCollector.startRecording()
                    self.tabBarController?.selectedIndex = 1
                })
            })
        } else {
            self.dataCollector.startRecording()
            self.tabBarController?.selectedIndex = 1
        }
    }

    @IBAction func stopPushed(_ sender: Any) {
        self.dataCollector.stopRecording()
        btnStart.isEnabled = !self.dataCollector.recordingStarted
        btnStop.isEnabled = self.dataCollector.recordingStarted
    }

    @IBAction func uploadPushed(_ sender: Any) {
        let strava = Strava.getInstance()
        if strava.code.count == 0 {
            let authentication = StravaAuthenticationNavigation()
            authentication.completion {
                self.selectUpload(strava: strava)
            }
            present(authentication, animated: true, completion: nil)
        } else {
            selectUpload(strava: strava)
        }
    }

    @IBAction func openSessionsFolderPushed(_ sender: Any) {
        present(getFileBrowser(), animated: true, completion: nil)
    }
    
    func selectUpload(strava: Strava) {
        let fb = FileBrowser()
        fb.excludesFilepaths = []
        fb.excludesFileExtensions = ["csv", "json"]
        fb.didSelectFile = { (file: FBFile) -> Void in
            self.stravaUpload.startAnimating()
            DispatchQueue(label: "strava").async {
                strava.upload(file: file.filePath, fileName: file.displayName, success: { self.stravaUpload.stopAnimating() }, error: { self.alertUploadError() })
            }
        }
        present(fb, animated: true, completion: nil)
    }

    func alertUploadError() {
        stravaUpload.stopAnimating()
        let popup = UIAlertController(title: "Strava Upload", message: "Sorry, strava upload finished with an error!", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        popup.addAction(ok)
        present(popup, animated: true, completion: nil)
    }

}

extension TargetsViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let  char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        if isBackSpace == -92 {
            return true
        }
        if Int(string) == nil {
            return false
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        writeSettings()
        return true
    }
}

extension TargetsViewController: ListViewDelegate {
        
    func getFileList() -> [(id: String, name: String)] {
        var result = [(id: String, name: String)]()
        let trainings = MasterDataRepo.readTrainings()
        for training in trainings {
            result.append((training.id, training.name))
        }
        return result
    }
    
    func setSelectedFile(id: String) {
        var settings = MasterDataRepo.readSettings()
        settings.training = id
        MasterDataRepo.writeSettings(settings: settings)
        readSettings()
    }
    
    func removeFile(id: String) {
        MasterDataRepo.deleteTraining(id: id)
    }

}
