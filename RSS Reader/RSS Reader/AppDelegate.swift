//
//  AppDelegate.swift
//  RSS Reader
//
//  Created by Andrew Johnson on 9/4/16.
//  Copyright © 2016 Andrew Johnson. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: Fields

    var window: UIWindow?
    

    // MARK: UIApplicationDelegate
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
        // Configure proxies
        //UISearchBar.appearance().
        
        // Init db
        //DBService.sharedInstance.reset()
        let feeds = MockFactory.generateMockFeeds()
        for feed in feeds {
            _ = DBService.sharedInstance.save(feed) // TODO - Prompt error
        }
        
        // Initialize the starting point of the app
        let rootController = FeedsListViewController(style: .grouped)
        let navController = NavigationController(rootViewController: rootController)
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
        

        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        _ = DBService.sharedInstance.reset() // TODO - Prompt error
    }
}

