//
//  SettingsViewController.swift
//  RSS Reader
//
//  Created by Andrew Johnson on 9/18/16.
//  Copyright © 2016 Andrew Johnson. All rights reserved.
//

import Foundation

final class SettingsViewController: UITableViewController {

    // MARK: Fields
    
    
    // MARK: NestedTypes
    
    enum Section: Int {
        case links, actions, statistics
        enum Link: Int {
            case attribution
        }
        enum Action: Int {
            case resetApp, resetArticles
        }
        enum Statistic: Int {
            case feedCount, articleCount, cacheSize
        }
    }
    
    
    // MARK: UIViewController LifeCycle Callbacks
    
    
    // MARK: UITableView DataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: (indexPath as NSIndexPath).section) else {
            fatalError("\(#file) \(#function) - A section was unaccounted")
        }
        switch section {
        case .links:
            guard let row = Section.Link(rawValue: (indexPath as NSIndexPath).row) else {
                fatalError("\(#file) \(#function) - A row was unaccounted")
            }
            switch row {
            case .attribution:
                let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
                cell.textLabel?.text = "Attributions"
                cell.accessoryType = .disclosureIndicator
                return cell
            }
        case .actions:
            guard let row = Section.Action(rawValue: (indexPath as NSIndexPath).row) else {
                fatalError("\(#file) \(#function) - A row was unaccounted")
            }
            switch row {
            case .resetApp:
                let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
                cell.textLabel?.text = "Erase all content and Settings"
                cell.textLabel?.textColor = UIColor.blue
                return cell
            case .resetArticles:
                let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
                cell.textLabel?.text = "Erase all cached articles"
                cell.textLabel?.textColor = UIColor.blue
                return cell
            }
        case .statistics:
            guard let row = Section.Statistic(rawValue: (indexPath as NSIndexPath).row) else {
                fatalError("\(#file) \(#function) - A row was unaccounted")
            }
            switch row {
            case .articleCount:
                let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
                cell.textLabel?.text = "Articles"
                cell.detailTextLabel?.text = "0" // TODO - Get real count
                return cell
            case .feedCount:
                let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
                cell.textLabel?.text = "Feeds"
                cell.detailTextLabel?.text = "0" // TODO - Get real count
                return cell
            case .cacheSize:
                let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
                cell.textLabel?.text = "Cache"
                cell.detailTextLabel?.text = "0 kb" // TODO - Get real size
                return cell
            }
        }
    }
    
    // MARK: UITableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let section = Section(rawValue: (indexPath as NSIndexPath).section) else { return }
        switch section {
        case .actions:
            guard let row = Section.Action(rawValue: (indexPath as NSIndexPath).row) else {
                fatalError("\(#file) \(#function) - A row was unaccounted")
            }
            switch row {
            case .resetApp:
            
                // Reset the db
                if DBService.sharedInstance.reset() {
                    dismiss(animated: true, completion: nil)
                    return
                    
                // Prompt error message
                } else {
                    let alertController = UIAlertController(title: "Error", message: "Failed to erase content and settings", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Ok", style: .cancel) { _ in
                        alertController.dismiss(animated: true, completion: nil)
                    }
                    alertController.addAction(ok)
                    present(alertController, animated: true, completion: nil)
                }
            case .resetArticles:
                
                // TODO - Clear the articles view
                break
            }
        case .links:
            guard let row = Section.Link(rawValue: (indexPath as NSIndexPath).row) else {
                fatalError("\(#file) \(#function) - A row was unaccounted")
            }
            switch row {
            case .attribution:
                // TODO - Push to controller
                break
            }
        default:
            return
        }
    }
}
