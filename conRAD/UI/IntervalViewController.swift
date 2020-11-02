//
//  IntervalViewController.swift
//  conRAD
//
//  Created by Conrad Moeller on 01.11.20.
//  Copyright © 2020 Conrad Moeller. All rights reserved.
//

import Foundation
import UIKit

class IntervalViewNavigation: UINavigationController {

    var intervalView: IntervalViewController!
    
    convenience init() {
        let d = IntervalViewController()
        self.init(rootViewController: d)
        self.intervalView = d
    }
}

class IntervalViewController: UIViewController {
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var lhr: UILabel!
    @IBOutlet weak var hr: UITextField!
    @IBOutlet weak var lpower: UILabel!
    @IBOutlet weak var power: UITextField!
    @IBOutlet weak var lcadence: UILabel!
    @IBOutlet weak var cadence: UITextField!
    @IBOutlet weak var lduration: UILabel!
    @IBOutlet weak var duration: UITextField!
    @IBOutlet weak var duration_s: UITextField!
    
    var barItemSave = NSLocalizedString("Save", comment: "no comment")
    var barItemCancel = NSLocalizedString("Cancel", comment: "no comment")
    
    var training: Training!
    var updateTraining: ((_: Training) -> Void)!
    var isNew = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lhr.text = NSLocalizedString("Heart Rate", comment: "no comment")
        lpower.text = NSLocalizedString("Power", comment: "no comment")
        lcadence.text = NSLocalizedString("Cadence", comment: "no comment")
        lduration.text = NSLocalizedString("Duration", comment: "no comment")
        
        hr.delegate = self
        cadence.delegate = self
        power.delegate = self
        duration.delegate = self
        duration_s.delegate = self
        
        let saveButton = UIBarButtonItem(title: barItemSave, style: .plain, target: self, action: #selector(IntervalViewController.save(button:)))
        self.navigationItem.rightBarButtonItem = saveButton
        let dismissButton = UIBarButtonItem(title: barItemCancel, style: .plain, target: self, action: #selector(IntervalViewController.dismiss(button:)))
        self.navigationItem.leftBarButtonItem = dismissButton
    }
    
    override func viewDidAppear(_ animated: Bool) {
        name.text = training.intervals[training.currentInterval].name
        hr.text = training.intervals[training.currentInterval].hr
        power.text = training.intervals[training.currentInterval].power
        cadence.text = training.intervals[training.currentInterval].cadence
        duration.text = training.intervals[training.currentInterval].duration
        duration_s.text = training.intervals[training.currentInterval].duration_s
    }
    
    @objc func save(button: UIBarButtonItem = UIBarButtonItem()) {
        updateInterval()
        updateTraining(training)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func dismiss(button: UIBarButtonItem = UIBarButtonItem()) {
        if isNew {
            training.intervals.remove(at: training.currentInterval)
        }
        updateTraining(training)
        self.dismiss(animated: true, completion: nil)
    }
    
    func updateInterval() {
        training.intervals[training.currentInterval].name = name.text ?? "???"
        training.intervals[training.currentInterval].hr = hr.text ?? "0"
        training.intervals[training.currentInterval].power = power.text ?? "0"
        training.intervals[training.currentInterval].cadence = cadence.text ?? "0"
        training.intervals[training.currentInterval].duration = duration.text ?? "0"
        training.intervals[training.currentInterval].duration_s = duration_s.text ?? "0"
    }
}

extension IntervalViewController: UITextFieldDelegate {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        name.resignFirstResponder()
        hr.resignFirstResponder()
        cadence.resignFirstResponder()
        power.resignFirstResponder()
        duration.resignFirstResponder()
    }
    
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
        return true
    }
}
