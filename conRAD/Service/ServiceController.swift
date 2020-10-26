//
//  ServiceController.swift
//  UltimateTriTrainer
//
//  Created by Conrad Moeller on 15.12.18.
//  Copyright © 2018 Conrad Moeller. All rights reserved.
//

import Foundation

class ServiceController {

    static func startServices() {
        _ = DataCollectionService.getInstance()
    }

}
