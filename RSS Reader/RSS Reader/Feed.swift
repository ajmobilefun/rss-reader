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
struct Feed: CBLObject {

    // MARK: Fields

    var category: String?
    var subtitle: String?
    var title: String?
    var url: URL?
    var favorite: Bool = false
    
    
    // MARK: Initializers
    
    init() {
        id = UUID().uuidString
        rev = nil
    }
    
    
    // MARK: CBLObject Implementation
    
    static let view = CBLView.Feeds
    let id: String
    let rev: String?
    
    init?(json: JSON) {
        
        // Assert the required fields exist
        guard
        let title: String = "title" <~~ json,
        let url: URL = "url" <~~ json,
        let id: String = "_id" <~~ json
        else { return nil }
        
        // Assign the fields
        self.id = id
        self.title = title
        self.url = url
        rev = "_rev" <~~ json
        category = ("category" <~~ json) ?? ""
        subtitle = "subtitle" <~~ json ?? ""
        favorite = "favorite" <~~ json ?? false
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            "_rev" ~~> rev,
            "category" ~~> category,
            "subtitle" ~~> subtitle,
            "title" ~~> title,
            "url" ~~> url,
            "favorite" ~~> favorite
        ])
    }
}
