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
            let cyclist = Cyclist(name: "Your Name", weigth: "0", maxHR: "0", FTP: "0", dob: "")
            MasterDataRepo.writeCyclist(cyclist: cyclist)
        }
        if FileTool.createFolder(name: "bicycles") {
            var bike = MasterDataRepo.newBicycle()
            bike.name = "bike1"
            MasterDataRepo.writeBicycle(bicycle: bike)
        }
        if FileTool.createFolder(name: "trainings") {
            var training = MasterDataRepo.newTraining()
            training.name = "training 1"
            training.hr = "130"
            training.power = "150"
            training.cadence = "90"
            MasterDataRepo.writeTraining(training: training)
        }
        _ = FileTool.createFolder(name: "sessions")
        ServiceController.startServices()
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