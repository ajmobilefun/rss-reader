//
//  PListService.swift
//  RSS Reader
//
//  Created by Andrew Johnson on 9/17/16.
//  Copyright © 2016 Andrew Johnson. All rights reserved.
//

import Foundation

/**
    A service that provides convenience for writing and
    retrieving on the info.plist file.
*/
struct PListService {

    // MARK: Fields

    private static let kSegment = "selected_segment"


    // MARK: Functions
    
    static func setSegment(segment: Segment) {
        let preferences = NSUserDefaults.standardUserDefaults()
        preferences.setObject(segment.rawValue, forKey: kSegment)
    }
    
    static func getSegment() -> Segment? {
        let preferences = NSUserDefaults.standardUserDefaults()
        guard let rawValue = preferences.stringForKey(kSegment) else { return nil }
        return Segment(rawValue: rawValue)
    }
}