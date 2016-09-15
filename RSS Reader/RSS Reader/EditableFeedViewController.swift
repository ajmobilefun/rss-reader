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
    
    var saveButton = UIBarButtonItem(barButtonSystemItem: .Save, target: nil, action: nil)
    var cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: nil, action: nil)
    var feed: Feed {
        didSet {
            let validTitle = feed.title != nil || feed.title != ""
            let validUrl = feed.url != nil
            saveButton.enabled = validTitle && validUrl
        }
    }


    // Initializers
    
    init(feed: Feed?) {
        self.feed = feed ?? Feed()
        super.init(nibName: nil, bundle: nil)
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
        saveButton.enabled = false
        navigationItem.rightBarButtonItem = saveButton
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    // MARK: Button Actions
    
    func cancelTapped(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveTapped(sender: UIBarButtonItem) {
        guard feed.url != nil && feed.title != nil else { return }
        // TODO - Save
    }
    
    
    // MARK: UITableView DataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2 // Text fields and selection field
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        if section == 0 {
            return 3 // Title, subtitle, url
        } else {
            return 1 // Category
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        // Text fields
        if indexPath.section == 0 {
            let reuseId = "text_field_cell"
            let cell = tableView.dequeueReusableCellWithIdentifier(reuseId) as? TextFieldTableViewCell ?? TextFieldTableViewCell(reuseId: reuseId)
            let rep: (placeholder: String, text: String?) = {
                switch indexPath.row {
                case 0: return ("Title", feed.title)
                case 1: return ("Subtitle", feed.subtitle)
                case 2: return ("Url (e.g. http://blogs.nasa.gov/stationreport/feed)", feed.url?.absoluteString)
                }
            }()
            cell.textField.placeholder = rep.placeholder
            cell.textField.text = rep.text
            return cell
            
        // Selection fields
        } else {
            let reuseId = "selection_cell"
            let cell = tableView.dequeueReusableCellWithIdentifier(reuseId) ?? UITableViewCell(style: .Value2, reuseIdentifier: reuseId)
            cell.selectionStyle = .Blue
            cell.accessoryType = .DisclosureIndicator
            cell.textLabel?.text = "Category"
            cell.detailTextLabel?.text = feed.category
            return cell
        }
    }
    
    
    // MARK: UITableView Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
        tableView.deselectRowAtIndexPath(indexPath, animated: true) // Button click effect
        
        // Selection fields
        if indexPath.section == 1 {
            // TODO
        }
    }
}