//
//  ViewController.swift
//  HelloWorld
//
//  Created by Kunal Thacker on 12/28/16.
//  Copyright © 2016 Kunal Thacker. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var progressView: UIProgressView!
    
    var timer = Timer()
    var loadComplete = false
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setupWebview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.openedFromNotification), name: NSNotification.Name(rawValue: "remoteNotification"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Web view delegate
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.loadComplete = true
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        self.timer = Timer.scheduledTimer(timeInterval: 0.01667, target: self, selector: #selector(ViewController.updateProgressB), userInfo: nil, repeats: true)
        self.loadComplete = false
        self.progressView.isHidden = false
        self.progressView.progress = 0.0
        self.isLoading = true
    }
    
    // MARK: Setup methods
    
    func updateProgressB() {
        DispatchQueue.main.async {
            if self.isLoading {
                if self.loadComplete {
                    if self.progressView.progress >= 1.0 {
                        self.progressView.isHidden = true
                        self.timer.invalidate()
                        self.isLoading = false
                    } else {
                        self.progressView.progress += 0.1
                    }
                } else {
                    self.progressView.progress += 0.01
                    if self.progressView.progress >= 0.4 {
                        self.progressView.progress = 0.4
                    }
                }
            }
        }
    }
    
    func loadRequest(request: URLRequest) {
        Reachability.isConnectedToNetwork()
        while (UserDefaults.standard.integer(forKey: "NetworkAvailable") == 0) {
        }
        if UserDefaults.standard.integer(forKey: "NetworkAvailable") == 1 {
            self.webView.loadRequest(request)
        } else {
            self.progressView.isHidden = true
            let alert = UIAlertController(title: "Oops!", message: "Please check if you have a working internet connection", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Try Again", style: .default , handler: { (_) in
                alert.dismiss(animated: false, completion: nil)
                self.loadRequest(request: request)
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
                alert.dismiss(animated: false, completion: nil)
            }))
            self.present(alert, animated: false, completion: nil)
        }
    }
    
    func setupWebview() {
        // Hide navbar
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Setup Loading process
        self.progressView.progress = 0.0
        webView.delegate = self
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
        
        var request = URLRequest(url: URL(string: "http://www.just-off.co.uk/")!)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        self.loadRequest(request: request)
        
        
        // Setup gesture recognizers
        let swipeGestureL = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.swipe))
        swipeGestureL.direction = .left
        
        let swipeGestureR = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.swipe))
        swipeGestureR.direction = .right
        
        webView.addGestureRecognizer(swipeGestureL)
        webView.addGestureRecognizer(swipeGestureR)
    }

    func swipe(sender: UISwipeGestureRecognizer) {
        if sender.direction == .left {
            if self.webView.canGoForward {
                self.webView.goForward()
            }
        }
        if sender.direction == .right {
            if self.webView.canGoBack {
                self.webView.goBack()
            }
        }
    }
    
    func openedFromNotification(notification: Notification) {
        if let additionalData = notification.userInfo {
            if let url = additionalData["url"] as? String {
                if url != "" {
                    self.webView.stopLoading()
                    let request = URLRequest(url: URL(string: url)!)
                    self.loadRequest(request: request)
                }
            }
        }
    }
}

