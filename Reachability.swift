//
//  Reachability.swift
//  HelloWorld
//
//  Created by Kunal Thacker on 1/5/17.
//  Copyright © 2017 Kunal Thacker. All rights reserved.
//

import Foundation

import Foundation
public class Reachability {
    
    // Rights to userdefaults- 0 if checking, 1 if connected and -1 if not connnected
    class func isConnectedToNetwork(){
        UserDefaults.standard.set(0, forKey: "NetworkAvailable")
        let url = NSURL(string: "http://google.com/")
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "HEAD"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 10.0
        
        URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (_, response, error) in
            
            if error == nil {
                UserDefaults.standard.set(1, forKey: "NetworkAvailable")
            } else {
                UserDefaults.standard.set(-1, forKey: "NetworkAvailable")
            }
        }).resume()
    }
}
