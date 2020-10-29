//
//  NavigationController.swift
//  UltimateTriTrainer
//
//  Created by Conrad Moeller on 03.10.18.
//  Copyright © 2018 Conrad Moeller. All rights reserved.
//

import MapKit
import MapCache
import UIKit

class NavigationViewController: UIViewController {

    @IBOutlet weak var topBox: UIView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var downloadProgress: UILabel!
    @IBOutlet weak var bottomLeftBox: UIView!
    @IBOutlet weak var bottomRightBox: UIView!

    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var speed: UILabel!
    @IBOutlet weak var distance: UILabel!

    let formatter = DateFormatter()
    var timer: Timer!
    var dataCollector = DataCollectionService.getInstance()
   
    var downloader: RegionDownloader!
    var downloadPercentage = "0%"
    var downloadTimer: Timer!
    
    var way: MKPolyline!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIUtil.applyBoxStyle(view: topBox)
        UIUtil.applyBoxStyle(view: map)
        UIUtil.applyBoxStyle(view: bottomLeftBox)
        UIUtil.applyBoxStyle(view: bottomRightBox)
        
        let coordinates = [CLLocationCoordinate2D]()
        way = MKPolyline(coordinates: coordinates, count: coordinates.count)
        map.add(way)
        map.delegate = self
        map.useCache(MyMapCache.getInstance())
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
        if dataCollector.recordingStarted {
            map.remove(way)
            let coordinates = dataCollector.getCoordinates()
            way = MKPolyline(coordinates: coordinates, count: coordinates.count)
            map.add(way)
        }
    }

    @IBAction func zoomOutPushed(_ sender: Any) {
        map.setUserTrackingMode(.none, animated: true)
        map.camera.altitude = map.camera.altitude * 2
    }

    @IBAction func followPositionPushed(_ sender: Any) {
        map.setUserTrackingMode(.followWithHeading, animated: true)
    }
    
    @IBAction func downloadRegionPushed(_ sender: Any) {
        let nw = map.northWestCoordinate
        let se = map.southEastCoordinate
        let region = TileCoordsRegion(topLeftLatitude: nw.latitude, topLeftLongitude: nw.longitude, bottomRightLatitude: se.latitude, bottomRightLongitude: se.longitude, minZoom: 10, maxZoom: 15)
        
        let popup = UIAlertController(title: "Map Download", message: "Download \(region?.count ?? 0) tiles?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: {_ in self.startDownload(region: region!)})
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: {_ in popup.dismiss(animated: true, completion: {})})
        popup.addAction(ok)
        popup.addAction(cancel)
        present(popup, animated: true, completion: nil)
    }
    
    func startDownload(region: TileCoordsRegion) {
        downloader = RegionDownloader(forRegion: region, mapCache: MyMapCache.getInstance())
        downloader.delegate = self
        downloadProgress.layer.zPosition = 1
        downloadProgress.text = downloadPercentage
        downloadProgress.isHidden = false
        downloadTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateDownloadProgess), userInfo: nil, repeats: true)
        downloader.start()
    }
    
    @objc func updateDownloadProgess() {
        downloadProgress.text = downloadPercentage
        if downloader.downloadedPercentage == 100 {
            downloadTimer.invalidate()
            downloadProgress.text = "0%"
            downloadProgress.isHidden = true
        }
    }
    
    @IBAction func clearCachePushed(_ sender: Any) {
        MyMapCache.getInstance().clear(completition: alertCacheCleared)
    }
    
    func alertCacheCleared() {
        let popup = UIAlertController(title: "Offline Maps deleted", message: "", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { _ in popup.dismiss(animated: true, completion: {})})
        popup.addAction(ok)
        present(popup, animated: true, completion: nil)
    }
}

extension MKMapView {
    var northWestCoordinate: CLLocationCoordinate2D {
        return MKMapPoint(x: visibleMapRect.minX, y: visibleMapRect.minY).coordinate
    }

    var northEastCoordinate: CLLocationCoordinate2D {
        return MKMapPoint(x: visibleMapRect.maxX, y: visibleMapRect.minY).coordinate
    }

    var southEastCoordinate: CLLocationCoordinate2D {
        return MKMapPoint(x: visibleMapRect.maxX, y: visibleMapRect.maxY).coordinate
    }

    var southWestCoordinate: CLLocationCoordinate2D {
        return MKMapPoint(x: visibleMapRect.minX, y: visibleMapRect.maxY).coordinate
    }
}

extension NavigationViewController: MKMapViewDelegate  {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let way = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: way)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 7
            return renderer
        }
        return mapView.mapCacheRenderer(forOverlay: overlay)
    }
}

extension NavigationViewController: RegionDownloaderDelegate  {
    
    func regionDownloader(_ regionDownloader: RegionDownloader, didDownloadPercentage percentage: Double) {
        downloadPercentage = String(round(percentage)) + "%"
    }
    
    func regionDownloader(_ regionDownloader: RegionDownloader, didFinishDownload tilesDownloaded: TileNumber) {
    }
}
