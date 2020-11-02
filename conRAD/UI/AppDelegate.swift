//
//  AppDelegate.swift
//  UltimateTriTrainer
//
//  Created by Conrad Moeller on 02.10.18.
//  Copyright © 2018 Conrad Moeller. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if FileTool.createFolder(name: "setup") {
            let setup = Settings(setup: true, bike: "", training: "default")
            MasterDataRepo.writeSettings(settings: setup)
        }
        if FileTool.createFolder(name: "cyclist") {
            let cyclist = Cyclist(name: "name", weigth: "0", maxHR: "0", FTP: "0", dob: "", tileUrl: "https://a.tile.openstreetmap.org/{z}/{x}/{y}.png", maxZoom: "15")
            MasterDataRepo.writeCyclist(cyclist: cyclist)
        }
        if FileTool.createFolder(name: "bicycles") {
            var bike = MasterDataRepo.newBicycle()
            bike.name = "bike1"
            MasterDataRepo.writeBicycle(bicycle: bike)
        }
        if FileTool.createFolder(name: "trainings") {
            preInstallFTPTest()
        }
        _ = FileTool.createFolder(name: "sessions")
        _ = FileTool.createFolder(name: "gpx")
        ServiceController.startServices()
        return true
    }
    
    func preInstallFTPTest() {
        var training = MasterDataRepo.newTraining()
        training.name = "FTP Test"
        training.hr = "100"
        training.power = "100"
        training.cadence = "80"
        training.duration = "20"
        training.intervals[training.currentInterval].name = "warm up"
        let hc = Interval(name: "100 rpm", hr: "130", power: "100", cadence: "100", duration: "1")
        let pause = Interval(name: "slow down", hr: "130", power: "100", cadence: "80", duration: "1")
        training.intervals.append(hc)
        training.intervals.append(pause)
        training.intervals.append(hc)
        training.intervals.append(pause)
        training.intervals.append(hc)
        training.intervals.append(pause)
        let test = Interval(name: "ftp test", hr: "180", power: "200", cadence: "90", duration: "20")
        training.intervals.append(test)
        let pause2 = Interval(name: "cool down", hr: "130", power: "100", cadence: "80", duration: "15")
        training.intervals.append(pause2)
        MasterDataRepo.writeTraining(training: training)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        let fileManager = FileManager.default
        do {
            _ = url.startAccessingSecurityScopedResource()
            try fileManager.copyItem(at: url, to: FileTool.getDir(name: "gpx").appendingPathComponent(url.lastPathComponent))
            url.stopAccessingSecurityScopedResource()
        } catch let error as NSError {
            print("\(error)")
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}
