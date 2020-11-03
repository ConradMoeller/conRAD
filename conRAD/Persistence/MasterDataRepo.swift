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
        return Cyclist(name: "", weigth: "0", maxHR: "0", FTP: "0", dob: "", tileUrl: "https://a.tile.openstreetmap.org/{z}/{x}/{y}.png", maxZoom: "15")
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
    
    static func deleteBike(id: String) {
        let filePath = FileTool.getFileURL(name: "bicycles/" + id, ext: "json")
        do {
            try FileManager.default.removeItem(at: filePath)
        } catch {
            print("Failed to delete JSON data: \(error.localizedDescription)")
        }
    }

    static func newTraining() -> Training {
        return Training(id: UUID().uuidString, name: "", intervals: [Interval(name: "interval 1", hr: "0", power: "0", cadence: "0", duration: "0")])
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

    static func deleteTraining(id: String) {
        let filePath = FileTool.getFileURL(name: "trainings/" + id, ext: "json")
        do {
            try FileManager.default.removeItem(at: filePath)
        } catch {
            print("Failed to delete JSON data: \(error.localizedDescription)")
        }
    }
}

class TrainingInstaller {
    
    static func installAll(maxHr: String, FTP: String) {
        let hr = Int(maxHr) ?? 180
        let ftp = Int(FTP) ?? 200
        installEndurance(hr: hr, FTP: ftp)
        installTempo(hr: hr, FTP: ftp)
    }
    
    static func installFTPTest() {
        var training = MasterDataRepo.newTraining()
        training.id = "FTP_Test"
        training.name = "FTP Test"
        training.hr = "100"
        training.power = "0"
        training.cadence = "80"
        training.duration = "20"
        training.intervals[training.currentInterval].name = "warm up"
        let hc = Interval(name: "100 rpm", hr: "130", power: "0", cadence: "100", duration: "1")
        let pause = Interval(name: "slow down", hr: "130", power: "0", cadence: "80", duration: "1")
        training.intervals.append(hc)
        training.intervals.append(pause)
        training.intervals.append(hc)
        training.intervals.append(pause)
        training.intervals.append(hc)
        training.intervals.append(pause)
        let test = Interval(name: "ftp test", hr: "180", power: "0", cadence: "90", duration: "20")
        training.intervals.append(test)
        let coolDown = Interval(name: "cool down", hr: "130", power: "0", cadence: "80", duration: "15")
        training.intervals.append(coolDown)
        MasterDataRepo.writeTraining(training: training)
    }
    
    static func calcWithInt(v: Int,f: Double) -> String {
        return String(Int(Double(v) * f))
    }
    
    static func getTemplate(name: String, hr: Int, FTP: Int) -> Training {
        var training = MasterDataRepo.newTraining()
        training.id = name.replacingOccurrences(of: " ", with: "_")
        training.name = name
        let lhr = calcWithInt(v: hr, f: 0.6)
        let lp = calcWithInt(v: FTP, f: 0.55)
        training.hr = lhr
        training.power = lp
        training.cadence = "80"
        training.duration = "15"
        training.intervals[training.currentInterval].name = "warm up"
        let coolDown = Interval(name: "cool down", hr: lhr, power: lp, cadence: "80", duration: "15")
        training.intervals.append(coolDown)
        return training
    }
    
    static func installEndurance(hr: Int, FTP: Int) {
        var t = getTemplate(name: "Endurance", hr: hr, FTP: FTP)
        let i = Interval(name: "Endurance", hr: calcWithInt(v: hr, f: 0.76), power: calcWithInt(v: FTP, f: 0.65), cadence: "90", duration: "150")
        t.intervals.insert(i, at: 1)
        MasterDataRepo.writeTraining(training: t)
    }
    
    static func installTempo(hr: Int, FTP: Int) {
        var t = getTemplate(name: "Tempo", hr: hr, FTP: FTP)
        let i = Interval(name: "Tempo", hr: calcWithInt(v: hr, f: 0.9), power: calcWithInt(v: FTP, f: 0.83), cadence: "90", duration: "120")
        t.intervals.insert(i, at: 1)
        MasterDataRepo.writeTraining(training: t)
    }
}
