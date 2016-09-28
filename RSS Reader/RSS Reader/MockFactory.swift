//
//  MockFactory.swift
//  RSS Reader
//
//  Created by Andrew Johnson on 9/17/16.
//  Copyright © 2016 Andrew Johnson. All rights reserved.
//

import Foundation

struct MockFactory {

    static func generateMockFeeds() -> [Feed] {
        
        let titles = ["Space Station", "Agriculture", "Biosynthesis", "KOTR"]
        let subtitles = ["NASA", "FDA", "NIMH", "Thrasher"]
        let categories = ["Government", "Government", "Government", "Skateboarding"]
        let favorite = [true, false, false, true]
        
        var ret = [Feed]()
        for i in 0...3 {
            var feed = Feed()
            feed.title = titles[i]
            feed.subtitle = subtitles[i]
            feed.category = categories[i]
            feed.favorite = favorite[i]
            feed.url = URL(string: "https://www.google.com")
            ret.append(feed)
        }
        return ret
    }
}
