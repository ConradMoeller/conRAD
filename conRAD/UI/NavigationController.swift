//
//  NavigationController.swift
//  UltimateTriTrainer
//
//  Created by Conrad Moeller on 03.10.18.
//  Copyright © 2018 Conrad Moeller. All rights reserved.
//

import MapKit
import UIKit

class NavigationViewController: UIViewController {

    @IBOutlet weak var topBox: UIView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var bottomLeftBox: UIView!
    @IBOutlet weak var bottomRightBox: UIView!

    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var speed: UILabel!
    @IBOutlet weak var distance: UILabel!

    let formatter = DateFormatter()
    var timer: Timer!
    var dataCollector = DataCollectionService.getInstance()

    override func viewDidLoad() {
        super.viewDidLoad()
        UIUtil.applyBoxStyle(view: topBox)
        UIUtil.applyBoxStyle(view: map)
        UIUtil.applyBoxStyle(view: bottomLeftBox)
        UIUtil.applyBoxStyle(view: bottomRightBox)

        map.setUserTrackingMode(.followWithHeading, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidAppear(_ animated: Bool) {
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateView), userInfo: nil, repeats: true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        timer.invalidate()
    }

    @objc func updateView() {
        formatter.timeZone = TimeZone.init(abbreviation: "UTC")
        formatter.dateFormat = "HH:mm:ss"
        let t = dataCollector.getDuration()
        let speed = dataCollector.getSpeed()
        let distance = dataCollector.getDistance()
        self.time.text = formatter.string(for: Date(timeIntervalSince1970: dataCollector.getDuration()))
        self.speed.text = "\(String(format: "%.1f", speed * 3.6)) (\(String(format: "%.1f", abs(distance) / abs(t) * 3.6)))"
        self.distance.text = String(format: "%4.2f", distance / 1000)
    }

}
