//
//  Feed.swift
//  RSS Reader
//
//  Created by Andrew Johnson on 9/5/16.
//  Copyright © 2016 Andrew Johnson. All rights reserved.
//

import Foundation
import Gloss

/**
    A model for an RSS feed that includes meta data for the feed.
*/
struct Feed {

    // MARK: Fields

    var category: String = ""
    var subtitle: String = ""
    var title: String = ""
    var url: NSURL = NSURL()
    var favorite: Bool = false
}


// MARK: Glossy Implementation

extension Feed: Glossy {

    // Decodable Implementation
    init?(json: JSON) {
        category = "category" <~~ json ?? ""
        subtitle = "subtitle" <~~ json ?? ""
        title = "title" <~~ json ?? ""
        url = "url" <~~ json ?? NSURL()
        favorite = "favorite" <~~ json ?? false
    }
    
    // Encodeable Implementation
    func toJSON() -> JSON? {
        return jsonify([
            "category" ~~> category,
            "subtitle" ~~> subtitle,
            "title" ~~> title,
            "url" ~~> url,
            "favorite" ~~> favorite
        ])
    }
}