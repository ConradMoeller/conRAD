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

   
    @IBOutlet weak var trainingName: UITextField!
    @IBOutlet weak var intervalTable: UITableView!
    
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
    let intervalEdit = IntervalViewNavigation()
    
    var dataCollector = DataCollectionService.getInstance()
    
    var btResponseTimer: Timer!
    var i = 0

    var fileName: UITextField?
    var training: Training!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIUtil.applyBoxStyle(view: headerBox)
        UIUtil.applyBoxStyle(view: btBox)

        trainingsList.listView.listViewDelegate = self
        
        trainingName.delegate = self
        
        intervalTable.backgroundColor = UIColor.clear
        intervalTable.delegate = self
        intervalTable.dataSource = self
        
        intervalEdit.intervalView.updateTraining = writeTraining
        
        readSettings()
    }

    private func readSettings() {
        training = MasterDataRepo.readTraining()
        trainingName.text = training.name
        intervalTable.reloadData()
    }

    private func writeTraining(training: Training) {
        MasterDataRepo.writeTraining(training: training)
        self.training = MasterDataRepo.readTraining()
        intervalTable.reloadData()
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
        training.name = trainingName.text ?? training.name
        writeTraining(training: training)
        if btResponseTimer != nil {
            btResponseTimer.invalidate()
        }
        super.viewDidDisappear(animated)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        trainingName.resignFirstResponder()
        training.name = trainingName.text ?? training.name
        writeTraining(training: training)
    }


    @IBAction func newFilePushed(_ sender: Any) {
        let popup = UIAlertController(title: NSLocalizedString("New Training", comment: "no comment"), message: NSLocalizedString("Type in the name!", comment: "no comment"), preferredStyle: .alert)
        popup.addTextField(configurationHandler: fileName)
        let ok = UIAlertAction(title: "OK", style: .default, handler: handleOK)
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "no comment"), style: .cancel, handler: nil)
        popup.addAction(ok)
        popup.addAction(cancel)
        present(popup, animated: true, completion: nil)
    }

    func fileName(textField: UITextField) {
        fileName = textField
    }

    func handleOK(action: UIAlertAction) {
        var training = MasterDataRepo.newTraining()
        training.name = fileName?.text ?? NSLocalizedString("new training", comment: "no comment")
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
    
    @IBAction func copyTrainingPushed(_ sender: Any) {
        training = training.copy()
        writeTraining(training: training)
        readSettings()
    }
    
    @IBAction func editListPushed(_ sender: Any) {
        intervalTable.isEditing = !intervalTable.isEditing
    }
    
    @IBAction func addIntervalPushed(_ sender: Any) {
        training.intervals.append(Interval(name: "interval \(training.intervals.count + 1)", hr: "0", power: "0", cadence: "0", duration: "0"))
        training.currentInterval = training.intervals.count - 1
        intervalEdit.intervalView.training = training
        intervalEdit.intervalView.isNew = true
        present(intervalEdit, animated: true, completion: nil)
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
            let popup = UIAlertController(title: NSLocalizedString("Starting Training", comment: "no comment"), message: NSLocalizedString("Connecting to BLE Devices!", comment: "no comment"), preferredStyle: .alert)
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
        let fb = FileBrowser(initialPath: FileTool.getDir(name: "sessions"), allowEditing: true, showCancelButton: true)
        fb.excludesFileExtensions = []
        present(fb, animated: true, completion: nil)
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
        let popup = UIAlertController(title: NSLocalizedString("Strava Upload", comment: "no comment"), message: NSLocalizedString("Sorry, strava upload finished with an error!", comment: "no comment"), preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        popup.addAction(ok)
        present(popup, animated: true, completion: nil)
    }

}

extension TargetsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        training.name = trainingName.text ?? training.name
        writeTraining(training: training)
        return true
    }
}

extension TargetsViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return training.intervals.count
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.white
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = training.intervals[sourceIndexPath.row]
        training.intervals.remove(at: sourceIndexPath.row)
        training.intervals.insert(movedObject, at: destinationIndexPath.row)
        writeTraining(training: training)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "DeviceCell"
        var cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        if let reuseCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            cell = reuseCell
        }
        cell.textLabel?.text = ("\(training.intervals[indexPath.row].name) (\(training.intervals[indexPath.row].duration) min)")
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        training.currentInterval = indexPath.row
        intervalEdit.intervalView.training = training
        intervalEdit.intervalView.isNew = false
        present(intervalEdit, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && training.intervals.count > 1 {
            training.intervals.remove(at: indexPath.row)
            intervalTable.deleteRows(at: [indexPath], with: .fade)
            writeTraining(training: training)
        }
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
    
    func getSelectedFile() -> String {
        return MasterDataRepo.readTraining().id
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
