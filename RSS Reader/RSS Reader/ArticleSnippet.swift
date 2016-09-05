//
//  ArticleSnippet.swift
//  RSS Reader
//
//  Created by Andrew Johnson on 9/4/16.
//  Copyright © 2016 Andrew Johnson. All rights reserved.
//

import Foundation

/**
    An object that encapsulates the 'cared about' information used in
    an XML RSS data.
*/
struct ArticleSnippet {
    
    // MARK: Fields
    
    var title: String?
    var description: String?
    var pubDate: String?
    var author: String?
    var link: String?
}