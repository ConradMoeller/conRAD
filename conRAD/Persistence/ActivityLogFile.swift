//
//  ActivityLogFile.swift
//  UltimateTriTrainer
//
//  Created by Conrad Moeller on 22.11.18.
//  Copyright © 2018 Conrad Moeller. All rights reserved.
//

import Foundation

class ActivityLogFile: JSONFile {

    private var fileName: String
    private var totals: LogRecord!
    private var records: [LogRecord]

    init(name: String) {
        fileName = name
        records = [LogRecord]()
    }

    func getFileName() -> String {
        return fileName
    }

    func addRecord(record: LogRecord) {
        records.append(record)
    }

    func setTotals(record: LogRecord) {
        totals = record
    }

    func toTCX(id: String) -> String {
        var result = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        result += "<TrainingCenterDatabase xmlns=\"http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2\">"
        result += "<Activities>"
        result += "<Activity Sport=\"Biking\">"
        result += "<Id>" + id + "</Id>"
        result += "<Lap StartTime=\"" + id + "\">"
        result += "<TotalTimeSeconds>" + totals.data[DataCollectionService.METRIC_TIME]! + "</TotalTimeSeconds>"
        result += "<DistanceMeters>" + totals.data[DataCollectionService.METRIC_DIST]! + "</DistanceMeters>"
        result += "<MaximumSpeed>" + totals.data[DataCollectionService.METRIC_SPEED_MAX]! + "</MaximumSpeed>"
        result += "<Calories>" + totals.data[DataCollectionService.METRIC_CALORIES]! + "</Calories>"
        result += "<AverageHeartRateBpm>"
        result += "<Value>" + totals.data[DataCollectionService.METRIC_HR]! + "</Value>"
        result += "</AverageHeartRateBpm>"
        result += "<MaximumHeartRateBpm>"
        result += "<Value>" + totals.data[DataCollectionService.METRIC_HR_MAX]! + "</Value>"
        result += "</MaximumHeartRateBpm>"
        result += "<Intensity>Active</Intensity>"
        result += "<Cadence>" + totals.data[DataCollectionService.METRIC_CAD]! + "</Cadence>"
        result += "<TriggerMethod>Manual</TriggerMethod>"
        result += "<Track>"
        for rec in records {
            result += "<Trackpoint>"
            result += "<Time>" + rec.data[DataCollectionService.METRIC_TIME]! + "</Time>"
            result += "<Position>"
            result += "<LatitudeDegrees>" + rec.data[DataCollectionService.METRIC_LAT]! + "</LatitudeDegrees>"
            result += "<LongitudeDegrees>" + rec.data[DataCollectionService.METRIC_LONG]! + "</LongitudeDegrees>"
            result += "</Position>"
            result += "<AltitudeMeters>" + rec.data[DataCollectionService.METRIC_ALT]! + "</AltitudeMeters>"
            result += "<DistanceMeters>" + rec.data[DataCollectionService.METRIC_DIST]! + "</DistanceMeters>"
            result += "<HeartRateBpm>"
            result += "<Value>" + rec.data[DataCollectionService.METRIC_HR]! + "</Value>"
            result += "</HeartRateBpm>"
            result += "<Cadence>" + rec.data[DataCollectionService.METRIC_CAD]! + "</Cadence>"
            result += "<SensorState>Present</SensorState>"
            result += "<Extensions>"
            result += "<TPX xmlns=\"http://www.garmin.com/xmlschemas/ActivityExtension/v2\">"
            result += "<Watts>" + rec.data[DataCollectionService.METRIC_POWER]! + "</Watts>"
            result += "</TPX>"
            result += "</Extensions>"
            result += "</Trackpoint>"
        }
        result += "</Track>"
        result += "</Lap>"
        result += "<Training xmlns=\"http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2\" VirtualPartner=\"false\">"
        result += "<Plan Type=\"Workout\" IntervalWorkout=\"false\">"
        result += "<Name>Cycling</Name>"
        result += "<Extensions/>"
        result += "</Plan>"
        result += "</Training>"
        result += "<Creator xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:type=\"Device_t\">"
        result += "<Name>conRAD!</Name>"
        result += "<UnitId>0</UnitId>"
        result += "<ProductID>1</ProductID>"
        result += "<Version>"
        result += "<VersionMajor>1</VersionMajor>"
        result += "<VersionMinor>0</VersionMinor>"
        result += "<BuildMajor>0</BuildMajor>"
        result += "<BuildMinor>0</BuildMinor>"
        result += "</Version>"
        result += "</Creator>"
        result += "</Activity>"
        result += "</Activities>"
        result += "<Author xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:type=\"Application_t\">"
        result += "<Name>conRAD!</Name>"
        result += "<Build>"
        result += "<Version>"
        result += "<VersionMajor>1</VersionMajor>"
        result += "<VersionMinor>0</VersionMinor>"
        result += "</Version>"
        result += "</Build>"
        result += "<LangID>EN</LangID>"
        result += "<PartNumber>XXX-XXXXX-XX</PartNumber>"
        result += "</Author>"
        result += "</TrainingCenterDatabase>"
        return result
    }

}
