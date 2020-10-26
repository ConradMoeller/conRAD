//
//  StravaAuthenticationViewController.swift
//  UltimateTriTrainer
//
//  Created by Conrad Moeller on 24.12.18.
//  Copyright © 2018 Conrad Moeller. All rights reserved.
//

import UIKit

class StravaAuthenticationNavigation: UINavigationController {

    var authenticationView: StravaAuthenticationViewController!

    convenience init() {
        let v = StravaAuthenticationViewController()
        self.init(rootViewController: v)
        self.authenticationView = v
    }

    func completion(didLoginSucceed: @escaping (() -> Void)) {
        authenticationView.didLoginSucceed = didLoginSucceed
    }

}

class StravaAuthenticationViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!

    private var strava = Strava.getInstance()

    var didLoginSucceed: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        let dismissButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(StravaAuthenticationViewController.done(button:)))
        self.navigationItem.rightBarButtonItem = dismissButton
        UserDefaults.standard.register(defaults: ["UserAgent": "conRAD!"])
        self.webView.loadRequest(URLRequest(url: Strava.getInstance().makeAuthURL()!))
        self.webView.delegate = self
    }

    @objc func done(button: UIBarButtonItem = UIBarButtonItem()) {
        self.dismiss(animated: true, completion: nil)
    }

    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let url = request.mainDocumentURL {
            if url.absoluteString.starts(with: strava.domain) {
                let params = url.absoluteString.split(separator: "&")
                for p in params {
                    if p.starts(with: "code") {
                        strava.code = String(p.split(separator: "=")[1])
                    }
                }
                self.dismiss(animated: true, completion: didLoginSucceed)
                return false
            }
        }
        return true
    }

}
