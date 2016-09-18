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
        super.init(style: .Default, reuseIdentifier: nil)
        setup()
    }
    
    init(reuseId: String?) {
        super.init(style: .Default, reuseIdentifier: reuseId)
        setup()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        fatalError("\(#function) should not be used!")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) should not be used!")
    }
    
    
    // MARK: Helper Functions
    
    private func setup() {
    
        // Configure the views
        textField.borderStyle = .None
        selectionStyle = .None
    }
    
    
    // MARK: UIView Callbacks
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Set the constraints
        let constraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-margin-[textField]-margin-|",
            options: .AlignAllCenterY,
            metrics: ["margin": 8],
            views: ["textField": textField]
        )
        contentView.addSubview(textField)
        contentView.addConstraints(constraints)
        textField.translatesAutoresizingMaskIntoConstraints = false
    }
}