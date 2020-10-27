//
//  MasterDataRepo.swift
//  conRAD
//
//  Created by Conrad Moeller on 27.09.20.
//  Copyright © 2020 Conrad Moeller. All rights reserved.
//

import Foundation

class MasterDataRepo {

    static func readSettings() -> Settings {
        do {
            let input = try Data(contentsOf: FileTool.getFileURL(name: "setup/settings", ext: "json"))
            return try JSONDecoder().decode(Settings.self, from: input)
        } catch let error as NSError {
            print(error)
        }
        return Settings(setup: true, bike: "bike", training: "default")
    }

    static func writeSettings(settings: Settings) {
        let json = try? JSONEncoder().encode(settings)
        let filePath = FileTool.getFileURL(name: "setup/settings", ext: "json")
        do {
            try json!.write(to: filePath)
        } catch {
            print("Failed to write JSON data: \(error.localizedDescription)")
        }
    }
    
    static func readCyclist() -> Cyclist {
        do {
            let input = try Data(contentsOf: FileTool.getFileURL(name: "cyclist/cyclist", ext: "json"))
            return try JSONDecoder().decode(Cyclist.self, from: input)
        } catch let error as NSError {
            print(error)
        }
        return Cyclist(name: "", weigth: "0", maxHR: "0", FTP: "0", dob: "")
    }

    static func writeCyclist(cyclist: Cyclist) {
        let json = try? JSONEncoder().encode(cyclist)
        let filePath = FileTool.getFileURL(name: "cyclist/cyclist", ext: "json")
        do {
            try json!.write(to: filePath)
        } catch {
            print("Failed to write JSON data: \(error.localizedDescription)")
        }
    }
    
    static func newBicycle() -> Bicycle {
        return Bicycle(id: UUID().uuidString, name: "", wheelSize: "2000", crank1: "34", crank2: "50", sprockets: "11,12,13,14,15,17,19,23,25,28", HRSensorId: "", HRSensorName: "", CSCSensorId: "", CSCSensorName: "", PowerSensorId: "", PowerSensorName: "")
    }
    
    static func readBicycle() -> Bicycle {
        return readBicycle(id: readSettings().bike)
    }

    static func readBicycle(id: String) -> Bicycle {
        do {
            let input = try Data(contentsOf: FileTool.getFileURL(name: "bicycles/" + id, ext: "json"))
            return try JSONDecoder().decode(Bicycle.self, from: input)
        } catch let error as NSError {
            print(error)
        }
        return newBicycle()
    }

    static func readBicycles() -> [Bicycle] {
        let dir = FileTool.getDir(name: "bicycles")
        var result = [Bicycle]()
        do {
            let content = try FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil, options: [])
            for file in content {
                let id = file.lastPathComponent.replacingOccurrences(of: ".json", with: "")
                result.append(readBicycle(id: id))
            }
        } catch {
            print(error.localizedDescription)
        }
        return result
    }
    
    static func writeBicycle(bicycle: Bicycle) {
        let json = try? JSONEncoder().encode(bicycle)
        let filePath = FileTool.getFileURL(name: "bicycles/" + bicycle.id, ext: "json")
        do {
            try json!.write(to: filePath)
        } catch {
            print("Failed to write JSON data: \(error.localizedDescription)")
        }
        var setup = readSettings()
        setup.bike = bicycle.id
        writeSettings(settings: setup)
    }

    static func newTraining() -> Training {
        return Training(id: UUID().uuidString, name: "", hr: "0", power: "0", cadence: "0")
    }
    
    static func readTraining() -> Training {
        return readTraining(id: readSettings().training)
    }

    static func readTraining(id: String) -> Training {
        do {
            let input = try Data(contentsOf: FileTool.getFileURL(name: "trainings/" + id, ext: "json"))
            return try JSONDecoder().decode(Training.self, from: input)
        } catch let error as NSError {
            print(error)
        }
        return newTraining()
    }
    
    static func readTrainings() -> [Training] {
        let dir = FileTool.getDir(name: "trainings")
        var result = [Training]()
        do {
            let content = try FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil, options: [])
            for file in content {
                let id = file.lastPathComponent.replacingOccurrences(of: ".json", with: "")
                result.append(readTraining(id: id))
            }
        } catch {
            print(error.localizedDescription)
        }
        return result
    }

    static func writeTraining(training: Training) {
        let json = try? JSONEncoder().encode(training)
        let filePath = FileTool.getFileURL(name: "trainings/" + training.id, ext: "json")
        do {
            try json!.write(to: filePath)
        } catch {
            print("Failed to write JSON data: \(error.localizedDescription)")
        }
        var setup = readSettings()
        setup.training = training.id
        writeSettings(settings: setup)
    }

}
