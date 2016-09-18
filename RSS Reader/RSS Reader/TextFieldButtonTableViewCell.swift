//
//  TextFieldButtonTableViewCell.swift
//  RSS Reader
//
//  Created by Andrew Johnson on 9/16/16.
//  Copyright © 2016 Andrew Johnson. All rights reserved.
//

import Foundation
import UIKit

final class TextFieldButtonTableViewCell: UITableViewCell {
    
    // MARK: Fields
    
    var addButton = UIButton(frame: CGRect.null)
    var textField = UITextField(frame: CGRect.null)
    
    
    // MARK: Initializers
    
    init() {
        super.init(style: .Default, reuseIdentifier: nil)
    }
    
    init(reuseId: String?) {
        super.init(style: .Default, reuseIdentifier: reuseId)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        fatalError("\(#function) should not be used!")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) should not be used!")
    }
    
    
    // MARK: UIView Callbacks
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Configure the views
        selectionStyle = .None
        addButton.layer.cornerRadius = 6
        addButton.layer.backgroundColor = FlatUIColor.BelizeHole.CGColor
        textField.borderStyle = .None
        
        // Set the constraints
        let metrics = ["margin": 8]
        let views = ["textField": textField, "addButton": addButton]
        
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-[addButton(35)]-|",
            options: [],
            metrics: metrics,
            views: views
        )
        
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-margin-[textField]-margin-[addButton(50)]-margin-|",
            options: [],
            metrics: metrics,
            views: views
        )
        [textField, addButton].forEach({ contentView.addSubview($0) })
        contentView.addConstraints(vConstraints + hConstraints)
    }
}


