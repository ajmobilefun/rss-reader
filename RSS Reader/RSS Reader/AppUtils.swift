//
//  SystemUtils.swift
//  RSS Reader
//
//  Created by Andrew Johnson on 9/5/16.
//  Copyright © 2016 Andrew Johnson. All rights reserved.
//

import Foundation
import UIKit

/**
    A static class responsible for supplying utility functions
    associated with the application. These functions include,
    but are not limited to, keyboard prompters/dismissers, segues, etc.
*/
struct AppUtils {
    
    static func popup(toController: UIViewController, fromController: UIViewController) {
        let navController = UINavigationController(rootViewController: toController)
        navController.navigationBar.tintColor = FlatUIColor.Clouds
        navController.navigationBar.barTintColor = FlatUIColor.WetAsphalt
        fromController.presentViewController(navController, animated: true, completion: nil)
    }
}