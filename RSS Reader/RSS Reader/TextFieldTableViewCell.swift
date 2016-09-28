//
//  TextFieldTableViewCell.swift
//  RSS Reader
//
//  Created by Andrew Johnson on 9/15/16.
//  Copyright © 2016 Andrew Johnson. All rights reserved.
//

import Foundation
import UIKit

/**
    A UITableViewCell that contains only a single text field.
*/
final class TextFieldTableViewCell: UITableViewCell {
    
    // MARK: Fields
    
    let textField = UITextField(frame: CGRect.null)
    
    
    // MARK: Initializers
    
    init() {
        super.init(style: .default, reuseIdentifier: nil)
        setup()
    }
    
    init(reuseId: String?) {
        super.init(style: .default, reuseIdentifier: reuseId)
        setup()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        fatalError("\(#function) should not be used!")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) should not be used!")
    }
    
    
    // MARK: Helper Functions
    
    fileprivate func setup() {
    
        // Configure the views
        textField.borderStyle = .none
        selectionStyle = .none
        
        // Add the subviews
        contentView.addSubview(textField)
        
        // Set the constraints
        let constraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-18-[textField]-8-|",
            options: .alignAllCenterY,
            metrics: nil,
            views: ["textField": textField]
        )
        let centered = NSLayoutConstraint(item: textField, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0)
        contentView.addConstraints(constraints + [centered])
        textField.translatesAutoresizingMaskIntoConstraints = false
    }
}
