//
//  Searchable.swift
//  RSS Reader
//
//  Created by Andrew Johnson on 10/1/16.
//  Copyright © 2016 Andrew Johnson. All rights reserved.
//

import Foundation

/**
    An interface used for searching for an object by its exposed property values.
*/
protocol Searchable {

    /// Returns a list of searchable texts.
    func getSearchables() -> [String]
}

extension Searchable {
    
    /// Convenient function for checking if the object matches a search text.
    func matchesSearch(text: String) -> Bool {
        let searchText = text.lowercased()
        return getSearchables().reduce(false, {
            $0 || $1.lowercased().contains(searchText)
        })
    }
}
