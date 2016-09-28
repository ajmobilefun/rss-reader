//
//  Theme.swift
//  RSS Reader
//
//  Created by Andrew Johnson on 9/18/16.
//  Copyright © 2016 Andrew Johnson. All rights reserved.
//

import Foundation

private var theme: Theme = AmethystBlack()

protocol Theme {
    var primaryDark: UIColor { get }
    var secondaryDark: UIColor { get }
    var primaryLight: UIColor { get }
    var secondaryLight: UIColor { get }
}

extension Theme {

    static func setTheme(_ newTheme: Theme) {
        theme = newTheme
    }

    static func get() -> Theme {
        return theme
    }
}



// Add themes below as needed

struct AmethystBlack: Theme {
    let primaryDark: UIColor = UIColor.darkGray
    let secondaryDark: UIColor = FlatUIColor.Concrete
    let primaryLight: UIColor = FlatUIColor.Clouds
    let secondaryLight: UIColor = FlatUIColor.Silver
}
