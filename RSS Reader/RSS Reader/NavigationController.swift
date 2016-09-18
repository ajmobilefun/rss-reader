//
//  NavigationController.swift
//  RSS Reader
//
//  Created by Andrew Johnson on 9/18/16.
//  Copyright © 2016 Andrew Johnson. All rights reserved.
//

import Foundation

class NavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: FlatUIColor.Clouds]
        navigationBar.tintColor = FlatUIColor.Clouds
        navigationBar.barTintColor = FlatUIColor.WetAsphalt
        navigationBar.translucent = false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}