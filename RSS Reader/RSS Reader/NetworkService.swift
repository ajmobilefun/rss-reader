//
//  NetworkService.swift
//  RSS Reader
//
//  Created by Andrew Johnson on 9/4/16.
//  Copyright © 2016 Andrew Johnson. All rights reserved.
//

import Foundation

/**
    A service responsible for fetching XML data from a URL.
    
    - author: Andrew Johnson
*/
final class NetworkService {
    
    // MARK: Fields
    
    /// A shared instance for fetching XML data under the same
    /// conditions.
    private static let sharedInstance = NetworkService()
    
    /// The established network session.
    private let session: NSURLSession
    
    
    // MARK: Initializers
    
    /// The designated initializer that configures the session.
    private init() {
        
        // Create the configuration object
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        configuration.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicy.Always
        configuration.HTTPShouldSetCookies = true
        configuration.HTTPAdditionalHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        // Create the singleton session with the conguration object
        session = NSURLSession(configuration: configuration)
    }
    
    
    // MARK: Interface
    
    /// Fetches data from a url string or call backs with nothing if any errors occur.
    func fetchXML(fromUrl url: String, callback: (xml: NSData?) -> ()) {
    
        // Assert the URL is valid
        guard let url = NSURL(string: url) else {
            print("The RSS URL is invalid")
            callback(xml: nil)
            return
        }
        
        // Create and configure a request object
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.timeoutInterval = NSTimeInterval(40.0)
        
        let acceptHeaders = ["application/xml", "application/rss+xml", "text/xml"]
        acceptHeaders.forEach({
            request.addValue($0, forHTTPHeaderField: "Accept")
        })

        // Create the task
        let task = session.dataTaskWithRequest(request) {(data, response, error) in
        
            guard
            let xmlData = data, // Assert there is data
            let urlResponse = response as? NSHTTPURLResponse // Assert there was a response
            where urlResponse.statusCode < 400 && error == nil // Assert acceptable status code
            else {
                print("Data: \(data)\nResponse: \(response as? NSHTTPURLResponse)\nStatus code: \((response as? NSHTTPURLResponse)?.statusCode)\nError: \(error?.localizedDescription)")
    
                // Callback to the main thread
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    callback(xml: nil)
                })
                return
            }
            
            // Return the xml data onto the main thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                callback(xml: xmlData)
            })
        }
        
        // Run the task
        task.resume()
    }
}
