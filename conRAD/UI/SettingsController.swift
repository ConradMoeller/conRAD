//
//  SettingsController.swift
//  UltimateTriTrainer
//
//  Created by Conrad Moeller on 18.11.18.
//  Copyright © 2018 Conrad Moeller. All rights reserved.
//

import UIKit
import FileBrowser

class SettingsViewController: UIViewController {

    @IBOutlet weak var headerBox: UIView!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var weight: UITextField!
    @IBOutlet weak var maxHR: UITextField!
    @IBOutlet weak var ftp: UITextField!
    @IBOutlet weak var tileUrl: UITextField!
    @IBOutlet weak var maxZoom: UITextField!
    @IBOutlet weak var metricSystem: UISwitch!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        userName.delegate = self
        weight.delegate = self
        maxHR.delegate = self
        ftp.delegate = self
        tileUrl.delegate = self
        maxZoom.delegate = self
        UIUtil.applyBoxStyle(view: headerBox)
        readSettings()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        writeSettings()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        userName.resignFirstResponder()
        weight.resignFirstResponder()
        maxHR.resignFirstResponder()
        ftp.resignFirstResponder()
        tileUrl.resignFirstResponder()
        maxZoom.resignFirstResponder()
        writeSettings()
    }

    func readSettings() {
        let cyclist = MasterDataRepo.readCyclist()
        userName.text = cyclist.name
        weight.text = cyclist.weigth
        maxHR.text = cyclist.maxHR
        ftp.text = cyclist.FTP
        tileUrl.text = cyclist.tileUrl
        maxZoom.text = cyclist.maxZoom
    }

    func writeSettings() {
        let oldTileUrl = MasterDataRepo.readCyclist().tileUrl
        var cyclist = Cyclist(name: userName.text!, weigth: weight.text!, maxHR: maxHR.text!, FTP: ftp.text!,dob: "", tileUrl: tileUrl.text!, maxZoom: maxZoom.text!)
        cyclist.metricSystem = metricSystem.isOn
        MasterDataRepo.writeCyclist(cyclist: cyclist)
        if oldTileUrl != cyclist.tileUrl {
            MyMapCache.reInit()
        }
    }

    @IBAction func metricSystemChanged(_ sender: Any) {
        writeSettings()
    }
    
    @IBAction func healthKitPushed(_ sender: Any) {
        HealthDataConnector.sharedInstance.requestAuthorization { (success) in
            DispatchQueue.main.async {
                let message = success ? "Authorized health data access." : "Failed to authorize health data access."
                let alertController = UIAlertController(title: "Health Data", message: message, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}

extension SettingsViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == userName || textField == tileUrl {
            return true
        }
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
