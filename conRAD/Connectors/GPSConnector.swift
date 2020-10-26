//
//  GPSDConnector.swift
//  UltimateTriTrainer
//
//  Created by Conrad Moeller on 18.11.18.
//  Copyright © 2018 Conrad Moeller. All rights reserved.
//

import CoreLocation

class GPSConnector: NSObject {

    private var locationManager: CLLocationManager = CLLocationManager()
    private var startLocation: CLLocation!

    private var traveledDistance = 0.0
    private var speed = DoubleMeterData(useLastValue: false, bufferSize: 3)

    private var connected = false
    
    override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
    }

    public func connect() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        startLocation = locationManager.location
        connected = true
    }

    public func disconnect() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
        connected = false
    }

    public func isConnected() -> Bool {
        return connected
    }
    
    public func reset() {
        startLocation = locationManager.location
        traveledDistance = 0.0
        speed.clear()
    }

    func getDistance() -> Double {
        guard let location = locationManager.location else { return traveledDistance }
        if startLocation != nil {
            traveledDistance += startLocation.distance(from: location)
        }
        startLocation = location
        return traveledDistance
    }

    func getLatitude() -> Double {
        guard let location = locationManager.location else { return 0.0 }
        return location.coordinate.latitude
    }

    func getLongitude() -> Double {
        guard let location = locationManager.location else { return 0.0 }
        return location.coordinate.longitude
    }

    func getAltitude() -> Double {
        guard let location = locationManager.location else { return 0.0 }
        return location.altitude
    }

    func getSpeed() -> DoubleMeterData {
        guard let location = locationManager.location else { return speed }
        let s = location.speed
        if s < 0 {
            return speed
        }
        speed.queue(v: s)
        return speed
    }

}

extension GPSConnector: CLLocationManagerDelegate {

}
