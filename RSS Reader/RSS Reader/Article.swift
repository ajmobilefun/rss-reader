//
//  ArticleSnippet.swift
//  RSS Reader
//
//  Created by Andrew Johnson on 9/4/16.
//  Copyright © 2016 Andrew Johnson. All rights reserved.
//

import Foundation
import Gloss

/**
    An object that encapsulates the 'cared about' information used in
    an XML RSS data.
*/
struct Article: CBLObject {
    
    // MARK: Fields
    
    var title: String?
    var description: String?
    var pubDate: String?
    var author: String?
    var link: String?
    
    
    // MARK: Initializers
    
    init() {
        id = UUID().uuidString
        rev = nil
    }
    
    
    // MARK: CBLObject Implementation
    
    static let view = CBLView.Articles
    let id: String
    let rev: String?
    
    init?(json: JSON) {
    
        // Assert we have an id
        guard let id: String = "_id" <~~ json
        else { return nil }
        
        // Assign the fields
        self.id = id
        rev = "_rev" <~~ json
        title = "title" <~~ json
        description = "description" <~~ json
        pubDate = "pubDate" <~~ json
        author = "author" <~~ json
        link = "link" <~~ json
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            "_id" ~~> id,
            "_rev" ~~> rev,
            "title" ~~> title,
            "description" ~~> description,
            "pubDate" ~~> pubDate,
            "author" ~~> author,
            "link" ~~> link
        ])
    }
}
