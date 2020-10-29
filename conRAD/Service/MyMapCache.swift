//
//  MyMapCache.swift
//  conRAD
//
//  Created by Conrad Moeller on 27.10.20.
//  Copyright © 2020 Conrad Moeller. All rights reserved.
//

import Foundation
import MapCache

class MyMapCache {

    private static let myCache = MyMapCache()
    
    public static func getInstance() -> MapCache {
        return myCache.mapCache
    }
    
    public static func reInit() {
        myCache.renew()
    }
    
    private var mapCache: MapCache!
    
    private init() {
        renew()
    }
    
    private func renew() {
        let cyclist = MasterDataRepo.readCyclist()
        let urlTemplate = cyclist.tileUrl
        // "https://tile.thunderforest.com/cycle/{z}/{x}/{y}.png?apikey=8f5c6811c78046cd958871381565537b"
        let config = MapCacheConfig(withUrlTemplate: urlTemplate)
        mapCache = MapCache(withConfig: config)
    }
}
