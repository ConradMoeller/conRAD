//
//  WelcomeViewController.swift
//  conRAD
//
//  Created by Conrad Moeller on 08.10.19.
//  Copyright © 2019 Conrad Moeller. All rights reserved.
//

import Foundation
import UIKit

class WelcomeViewController: UIViewController {

    var nextSetupStep: (() -> Void)!

    @IBOutlet weak var cyclistLabel: UILabel!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var weight: UITextField!
    @IBOutlet weak var hrLabel: UILabel!
    @IBOutlet weak var maxhr: UITextField!
    @IBOutlet weak var ftpLabel: UILabel!
    @IBOutlet weak var ftp: UITextField!
    @IBOutlet weak var bikenameLabel: UILabel!
    @IBOutlet weak var bikename: UITextField!
    @IBOutlet weak var wheelsizeLabel: UILabel!
    @IBOutlet weak var wheelsize: UITextField!
    @IBOutlet weak var crankLabel: UILabel!
    @IBOutlet weak var crank1: UITextField!
    @IBOutlet weak var crank2: UITextField!
    @IBOutlet weak var sprocketsLabel: UILabel!
    @IBOutlet weak var sprockets: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        let dismissButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(WelcomeViewController.done(button:)))
        self.navigationItem.rightBarButtonItem = dismissButton
        cyclistLabel.text = NSLocalizedString("Cyclist", comment: "no comment")
        weightLabel.text = NSLocalizedString("Weight", comment: "no comment")
        hrLabel.text = NSLocalizedString("max HR", comment: "no comment")
        bikenameLabel.text = NSLocalizedString("Bicyle Name", comment: "no comment")
        wheelsizeLabel.text = NSLocalizedString("Wheel Size", comment: "no comment")
        crankLabel.text = NSLocalizedString("Crank", comment: "no comment")
        sprocketsLabel.text = NSLocalizedString("Sprockets", comment: "no comment")
    }

    override func viewDidAppear(_ animated: Bool) {
        updateView()
    }

    override func viewDidDisappear(_ animated: Bool) {
        writeSettings()
    }

    func updateView() {
        let cyclist = MasterDataRepo.readCyclist()
        name.text = cyclist.name
        weight.text = cyclist.weigth
        maxhr.text = cyclist.maxHR
        ftp.text = cyclist.FTP
        let bike = MasterDataRepo.readBicycle()
        bikename.text = bike.name
        wheelsize.text = bike.wheelSize
        crank1.text = bike.crank1
        crank2.text = bike.crank2
        sprockets.text = bike.sprockets
    }

    @objc func done(button: UIBarButtonItem = UIBarButtonItem()) {
        writeSettings()
        if nextSetupStep != nil {
            nextSetupStep()
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        name.resignFirstResponder()
        weight.resignFirstResponder()
        maxhr.resignFirstResponder()
        ftp.resignFirstResponder()
        bikename.resignFirstResponder()
        wheelsize.resignFirstResponder()
        crank1.resignFirstResponder()
        crank2.resignFirstResponder()
        sprockets.resignFirstResponder()
        writeSettings()
    }

    func writeSettings() {
        var cyclist = MasterDataRepo.readCyclist()
        cyclist.name = name.text!
        cyclist.weigth = weight.text!
        cyclist.maxHR = maxhr.text!
        cyclist.FTP = ftp.text!
        MasterDataRepo.writeCyclist(cyclist: cyclist)
        var bike = MasterDataRepo.readBicycle()
        bike.name = bikename.text!
        bike.wheelSize = wheelsize.text!
        bike.crank1 = crank1.text!
        bike.crank2 = crank2.text!
        bike.sprockets = sprockets.text!
        MasterDataRepo.writeBicycle(bicycle: bike)
        var setup = MasterDataRepo.readSettings()
        setup.setup = false
        MasterDataRepo.writeSettings(settings: setup)
    }

}

extension WelcomeViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == name {
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
