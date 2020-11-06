//
//  StravaAuthenticationViewController.swift
//  UltimateTriTrainer
//
//  Created by Conrad Moeller on 24.12.18.
//  Copyright © 2018 Conrad Moeller. All rights reserved.
//

import WebKit

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

class StravaAuthenticationViewController: UIViewController, WKNavigationDelegate {

    
    var webView: WKWebView!
    
    private var strava = Strava.getInstance()

    var didLoginSucceed: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        let dismissButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(StravaAuthenticationViewController.done(button:)))
        self.navigationItem.rightBarButtonItem = dismissButton
        UserDefaults.standard.register(defaults: ["UserAgent": "conRAD!"])
        if self.webView == nil {
            self.webView = WKWebView()
        }
        self.view = webView
        self.webView.load(URLRequest(url: Strava.getInstance().makeAuthURL()!))
        webView.navigationDelegate = self
    }

    @objc func done(button: UIBarButtonItem = UIBarButtonItem()) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        if let url = webView.url {
            if url.absoluteString.starts(with: strava.domain) {
                let params = url.absoluteString.split(separator: "&")
                for p in params {
                    if p.starts(with: "code") {
                        strava.code = String(p.split(separator: "=")[1])
                    }
                }
                decisionHandler(.cancel)
                self.dismiss(animated: true, completion: didLoginSucceed)
                return
            }
        }
        decisionHandler(.allow)
    }
}
