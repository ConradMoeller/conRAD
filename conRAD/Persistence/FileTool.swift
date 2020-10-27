//
//  FileTool.swift
//  UltimateTriTrainer
//
//  Created by Conrad Moeller on 22.11.18.
//  Copyright © 2018 Conrad Moeller. All rights reserved.
//

import Foundation

protocol JSONFile: Encodable, Decodable {

}

class KeyValueFile: JSONFile {

    var data = [String: String]()
}

class LogRecord: Encodable, Decodable {

    var data = [String: String]()
}

class FileTool {

    static func createFolder(name: String) -> Bool {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectoryURL = urls.first!
        let directoryURL = documentDirectoryURL.appendingPathComponent(name)
        if !FileManager.default.fileExists(atPath: directoryURL.path) {
            do {
                try FileManager.default.createDirectory(atPath: directoryURL.path, withIntermediateDirectories: true, attributes: nil)
                return true
            } catch let error as NSError {
                print(error)
                return false
            }
        }
        return false
    }

    static func getDir() -> URL {
        let dir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return dir
    }

    static func getDir(name: String) -> URL {
        let dir = getDir()
        let file = dir.appendingPathComponent(name)
        return file
    }
    
    static func getFileURL(name: String, ext: String) -> URL {
        let dir = getDir()
        let file = dir.appendingPathComponent(name).appendingPathExtension(ext)
        return file
    }

    static func readJSON(name: String) -> KeyValueFile {
        do {
            let input = try Data(contentsOf: getFileURL(name: name, ext: "json"))
            return try JSONDecoder().decode(KeyValueFile.self, from: input)
        } catch let error as NSError {
            print(error)
        }
        return KeyValueFile()
    }

    static func writeJSON(name: String, data: KeyValueFile) {
        let json = try? JSONEncoder().encode(data)
        let filePath = getFileURL(name: name, ext: "json")
        do {
            try json!.write(to: filePath)
        } catch {
            print("Failed to write JSON data: \(error.localizedDescription)")
        }
    }

    static func writeJSON(name: String, data: ActivityLogFile) {
        let json = try? JSONEncoder().encode(data)
        let filePath = getFileURL(name: name, ext: "json")
        do {
            try json!.write(to: filePath)
        } catch {
            print("Failed to write JSON data: \(error.localizedDescription)")
        }
    }

    static func write(name: String, data: String, ext: String) {
        let filePath = getFileURL(name: name, ext: ext)
        do {
            try data.write(to: filePath, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Failed to write data: \(error.localizedDescription)")
        }
    }

    static func append(filename: String, ext: String, data: String) {
        let logFile = FileTool.getFileURL(name: filename, ext: ext)
        if let fileUpdater = try? FileHandle(forUpdating: logFile) {
            fileUpdater.seekToEndOfFile()
            fileUpdater.write(data.data(using: .utf8)!)
            fileUpdater.closeFile()
        } else {
            do {
                try data.write(to: logFile, atomically: true, encoding: .utf8)
            } catch {
                print("Failed to write log data: \(error.localizedDescription)")
            }
        }
    }

}
