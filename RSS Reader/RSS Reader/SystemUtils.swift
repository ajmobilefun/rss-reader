//
//  SystemUtils.swift
//  RSS Reader
//
//  Created by Andrew Johnson on 9/29/16.
//  Copyright © 2016 Andrew Johnson. All rights reserved.
//

import Foundation
import UIKit

/**
    A utilities for global operations.
*/
struct SystemUtils {
    
    /**
        Displays an error message on a controller.
    */
    static func promptError(withMessage message: String, onController controller: UIViewController) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .cancel) {(_) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(ok)
        controller.present(alert, animated: true, completion: nil)
    }
}
