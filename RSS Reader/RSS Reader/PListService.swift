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

    fileprivate static let kSegment = "selected_segment"


    // MARK: Functions
    
    static func setSegment(_ segment: Segment) {
        let preferences = UserDefaults.standard
        preferences.set(segment.rawValue, forKey: kSegment)
    }
    
    static func getSegment() -> Segment? {
        let preferences = UserDefaults.standard
        guard let rawValue = preferences.string(forKey: kSegment) else { return nil }
        return Segment(rawValue: rawValue)
    }
}
