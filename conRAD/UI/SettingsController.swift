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

    @IBOutlet weak var dob: UIDatePicker!

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        userName.delegate = self
        weight.delegate = self
        maxHR.delegate = self
        ftp.delegate = self
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
        writeSettings()
    }

    func readSettings() {
        let cyclist = MasterDataRepo.readCyclist()
        userName.text = cyclist.name
        weight.text = cyclist.weigth
        maxHR.text = cyclist.maxHR
        ftp.text = cyclist.FTP
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let d = df.date(from: cyclist.dob)
        if d != nil {
            dob.setDate(d!, animated: false)
        }
    }

    func writeSettings() {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let cyclist = Cyclist(name: userName.text!, weigth: weight.text!, maxHR: maxHR.text!, FTP: ftp.text!, dob: df.string(from: dob.date))
        MasterDataRepo.writeCyclist(cyclist: cyclist)
    }

}

extension SettingsViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == userName {
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
