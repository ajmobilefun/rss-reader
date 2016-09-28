//
//  EditableFeedViewController.swift
//  RSS Reader
//
//  Created by Andrew Johnson on 9/5/16.
//  Copyright © 2016 Andrew Johnson. All rights reserved.
//

import Foundation
import UIKit

/**
    A view controller responsible for editing and creating feeds. This controller is segued via modal and
    should be embedded inside of a navigation controller. The save button does not become enabled until
    a change is made and the required fields are satisfied.
*/
final class EditableFeedViewController: UITableViewController {

    // MARK: Fields
    
    var saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: nil)
    var cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
    var feed: Feed {
        didSet {
            let validTitle = feed.title != nil || feed.title != ""
            let validUrl = feed.url != nil
            saveButton.isEnabled = validTitle && validUrl
        }
    }


    // Initializers
    
    init(feed: Feed?) {
        self.feed = feed ?? Feed()
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: UIViewController LifeCycle Callbacks
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the cancel button
        cancelButton.target = self
        cancelButton.action = #selector(cancelTapped(_:))
        navigationItem.leftBarButtonItem = cancelButton
        
        // Setup the save button
        saveButton.target = self
        saveButton.action = #selector(saveTapped(_:))
        saveButton.isEnabled = false
        navigationItem.rightBarButtonItem = saveButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    // MARK: Button Actions
    
    func cancelTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func saveTapped(_ sender: UIBarButtonItem) {
        guard feed.url != nil && feed.title != nil else { return }
        _ = DBService.sharedInstance.save(feed) // TODO - prompt error
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: UITableView DataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // Text fields and selection field
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        if section == 0 {
            return 3 // Title, subtitle, url
        } else {
            return 1 // Category
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        // Text fields
        if (indexPath as NSIndexPath).section == 0 {
            let reuseId = "text_field_cell"
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseId) as? TextFieldTableViewCell ?? TextFieldTableViewCell(reuseId: reuseId)
            let rep: (placeholder: String, text: String?) = {
                switch (indexPath as NSIndexPath).row {
                case 0: return ("Title", feed.title)
                case 1: return ("Subtitle", feed.subtitle)
                case 2: return ("Url", feed.url?.absoluteString)
                default: return ("", nil)
                }
            }()
            cell.textField.placeholder = rep.placeholder
            cell.textField.text = rep.text
            cell.textField.autocapitalizationType = .none
            cell.textField.autocorrectionType = .no
            return cell
            
        // Selection fields
        } else {
            let reuseId = "selection_cell"
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseId) ?? UITableViewCell(style: .value1, reuseIdentifier: reuseId)
            cell.selectionStyle = .blue
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = "Category"
            cell.detailTextLabel?.text = feed.category
            return cell
        }
    }
    
    
    // MARK: UITableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        tableView.deselectRow(at: indexPath, animated: true) // Button click effect
        
        // Selection fields
        if (indexPath as NSIndexPath).section == 1 {
            // TODO
        }
    }
}
