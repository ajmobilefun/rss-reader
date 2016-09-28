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
    fileprivate static let sharedInstance = NetworkService()
    
    /// The established network session.
    fileprivate let session: URLSession
    
    
    // MARK: Initializers
    
    /// The designated initializer that configures the session.
    fileprivate init() {
        
        // Create the configuration object
        let configuration = URLSessionConfiguration.default
        configuration.httpCookieStorage = HTTPCookieStorage.shared
        configuration.httpCookieAcceptPolicy = HTTPCookie.AcceptPolicy.always
        configuration.httpShouldSetCookies = true
        configuration.httpAdditionalHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        // Create the singleton session with the conguration object
        session = URLSession(configuration: configuration)
    }
    
    
    // MARK: Interface
    
    /// Fetches data from a url string or call backs with nothing if any errors occur.
    func fetchXML(fromUrl url: String, callback: @escaping (_ xml: Data?) -> ()) {
    
        // Assert the URL is valid
        guard let url = URL(string: url) else {
            print("The RSS URL is invalid")
            callback(nil)
            return
        }
        
        // Create and configure a request object
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = TimeInterval(40.0)
        
        let acceptHeaders = ["application/xml", "application/rss+xml", "text/xml"]
        acceptHeaders.forEach({
            request.addValue($0, forHTTPHeaderField: "Accept")
        })

        // Create the task
        let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
        
            guard
            let xmlData = data, // Assert there is data
            let urlResponse = response as? HTTPURLResponse // Assert there was a response
            , urlResponse.statusCode < 400 && error == nil // Assert acceptable status code
            else {
                print("Data: \(data)\nResponse: \(response as? HTTPURLResponse)\nStatus code: \((response as? HTTPURLResponse)?.statusCode)\nError: \(error?.localizedDescription)")
    
                // Callback to the main thread
                DispatchQueue.main.async(execute: { () -> Void in
                    callback(nil)
                })
                return
            }
            
            // Return the xml data onto the main thread
            DispatchQueue.main.async(execute: { () -> Void in
                callback(xmlData)
            })
        }) 
        
        // Run the task
        task.resume()
    }
}
