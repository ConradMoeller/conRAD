//
//  Strava.swift
//  UltimateTriTrainer
//
//  Created by Conrad Moeller on 23.12.18.
//  Copyright © 2018 Conrad Moeller. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class Strava {

    private static var strava = Strava()

    public static func getInstance() -> Strava {
        return strava
    }

    private var headers: HTTPHeaders {
        get {
            return [
                "Authorization": token,
                "Accept": "application/json"
            ]
        }
    }

    private let clientId = 30711
    private let secret = "56db69055a6ec11c8d14bbce44912c4dbb3c8545"

    let domain = "http://localhost/exchange_token"

    private let baseURL = "https://www.strava.com"
    private let loginURL = "/oauth/authorize"
    private let tokenURL = "/oauth/token"
    private let apiPath = "/api/v3/"

    private var athlete = ""
    var code = ""
    var token = ""

    func makeAuthURL() -> URL? {
        let url = baseURL + loginURL + "?response_type=code&client_id=\(clientId)&redirect_uri=http://localhost/exchange_token&approval_prompt=force&scope=activity%3Awrite"
        return URL(string: url)
    }

    func requestToken() {
        var params = [String: Any]()
        params["client_id"] = String(clientId)
        params["client_secret"] = secret
        params["code"] = code
        Alamofire.request(baseURL + tokenURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: 200 ..< 300)
            .responseJSON { response in
                let json = JSON(response.value as Any)
                if json["access_token"].exists() {
                    self.token = json["token_type"].string! + " " + json["access_token"].string!
                }
                if json["athlete"].exists() {
                    if let athl = json["athlete"].dictionary {
                        for (key, sub): (String, JSON) in athl where key == "id" {
                            self.athlete = "\(sub)"
                        }
                    }
                }
        }
    }

    func upload(file: URL, fileName: String, success: @escaping (() -> Void), error: @escaping (() -> Void)) {
        var params = [String: Any]()
        params["client_id"] = String(clientId)
        params["client_secret"] = secret
        params["code"] = code
        Alamofire.request(baseURL + tokenURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
         .validate(statusCode: 200 ..< 300)
         .responseJSON { response in
                let json = JSON(response.value as Any)
                if json["access_token"].exists() {
                    self.token = json["token_type"].string! + " " + json["access_token"].string!
                }
                if json["athlete"].exists() {
                    if let athl = json["athlete"].dictionary {
                        for (key, sub): (String, JSON) in athl where key == "id" {
                            self.athlete = "\(sub)"
                        }
                    }
                }
                var params = [String: Data]()
                params["name"] = fileName.data(using: .utf8, allowLossyConversion: false)
                params["description"] = "".data(using: .utf8, allowLossyConversion: false)
                params["data_type"] = "tcx".data(using: .utf8, allowLossyConversion: false)
                params["private"] = "1".data(using: .utf8, allowLossyConversion: false)
                params["trainer"] = "0".data(using: .utf8, allowLossyConversion: false)
                params["commute"] = "0".data(using: .utf8, allowLossyConversion: false)
                params["external_id"] = fileName.data(using: .utf8, allowLossyConversion: false)
            self.upload(file: file, withKey: "file", withName: fileName, toUrl: "uploads", parameters: params, success: success, error: error)
            }
    }

    private func upload(file: URL, withKey key: String, withName name: String, toUrl url: String, parameters: [String: Data], success: @escaping (() -> Void), error: @escaping (() -> Void)) {
        Alamofire.upload(
            multipartFormData: {
                multipartFormData in
                parameters.forEach {
                        key, value in multipartFormData.append(value, withName: key)
                }
                multipartFormData.append(file, withName: key, fileName: name, mimeType: "multipart/form-data")
            },
            to: baseURL + apiPath + url,
            method: .post,
            headers: headers,
            encodingCompletion: {
                encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.validate(statusCode: 200 ..< 300).responseJSON {
                        response in
                        if response.error != nil {
                            error()
                        } else {
                            success()
                        }
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
            }
        )
    }

}
