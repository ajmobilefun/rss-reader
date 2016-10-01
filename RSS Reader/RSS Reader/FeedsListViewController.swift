//
//  FeedsListViewController.swift
//  RSS Reader
//
//  Created by Andrew Johnson on 9/5/16.
//  Copyright © 2016 Andrew Johnson. All rights reserved.
//

import Foundation
import UIKit
import MGSwipeTableCell

/**
    An enum that represents the selectable segments in the FeedListViewcontroller. In addition,
    this enum is used to persist the state into the info.plist to better the user experience.
*/
enum Segment: String {
    case Category, Favorite
    static let list = [Category.rawValue, Favorite.rawValue]
}

/**
    The view controller responsible for displaying a list of the feeds in the user's database.
    The feeds are divided into sections determined by the
*/
final class FeedsListViewController: SearchableTableViewController {

    // MARK: Fields
    
    // Data sources
    fileprivate var feeds: [[Feed]] = []
    fileprivate var sectionTitles: [String] = []
    fileprivate var selectedFeedIds: Set<String> = [] {
        didSet {
            deleteButton.isEnabled = selectedFeedIds.count != 0
        }
    }
    
    // Views
    fileprivate let segmentControl = UISegmentedControl(items: Segment.list)
    fileprivate let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: nil, action: nil)
    fileprivate let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
    fileprivate let settingsButton = UIBarButtonItem(title: "Settings", style: .plain, target: nil, action: nil)
    fileprivate let deleteButton = UIBarButtonItem(title: "Delete", style: .plain, target: nil, action: nil)
    
    // MARK: Selectors
    
    func segmentDidChange() {
        let index = segmentControl.selectedSegmentIndex
        let rawValue = Segment.list[index]
        let currentSegment = Segment(rawValue: rawValue) ?? .Category
        PListService.setSegment(currentSegment)
        loadDataArraysForSelectedSegment()
    }
    
    func addButtonTapped() {
        let controller = EditableFeedViewController(feed: nil)
        let navController = NavigationController(rootViewController: controller)
        present(navController, animated: true, completion: nil)
    }
    
    func editButtonTapped() {
    
        // Toggle state
        tableView.setEditing(!tableView.isEditing, animated: true)
        if !tableView.isEditing { selectedFeedIds = [] }
        
        // Update UI
        searchBar.isUserInteractionEnabled = !tableView.isEditing
        navigationController?.setToolbarHidden(!tableView.isEditing, animated: true)
        editButton.title = tableView.isEditing ? "Cancel" : "Edit"
    }
    
    func deleteButtonTapped() {
    
        promptToolbarAction(titleStr: "Warning", actionStr: "delete", action: { (id) in
        
            return DBService.sharedInstance.delete(objectWithId: id)
        })
    }
    
    
    // MARK: Abstract Method Implementations
    
    override func reloadDataSource() {
        isSearching() ? loadDataArraysForSearch() : loadDataArraysForSelectedSegment()
    }
    
    // MARK: Helper Methods
    
    fileprivate func endEditing() {
        tableView.setEditing(false, animated: true)
        navigationController?.setToolbarHidden(true, animated: true)
        editButton.title = "Edit"
    }
    
    fileprivate func promptToolbarAction(titleStr: String?, actionStr: String, action: @escaping (_ id: String) -> (Bool)) {
    
        // Generate the text
        let dynamicText = selectedFeedIds.count > 1 ? "Are you sure you want to \(actionStr) these \(selectedFeedIds.count) feeds?" : "Are you sure you want to \(actionStr) this feed?"
        
        // Create and prepare the controller
        let alertController = UIAlertController(title: titleStr, message: "Are you sure you want to \(actionStr) \(dynamicText)", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .destructive, handler: { [weak self] (_) in
            guard let controller = self else { return }
            let ids = controller.selectedFeedIds
            let success = ids.reduce(true, { $0 && action($1) })
            controller.selectedFeedIds = []
            success ? controller.endEditing() : SystemUtils.promptError(withMessage: "An error occured editing the feeds.", onController: controller)
        })
        let no = UIAlertAction(title: "No", style: .cancel, handler: { (_) in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        // Add the buttons and prompt the warning
        [yes, no].forEach({ alertController.addAction($0) })
        present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func promptError(_ message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            alertController.dismiss(animated: true, completion: nil)
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func clearDataArrays() {
        sectionTitles = []
        feeds = []
    }
    
    fileprivate func loadDataArraysForSearch() {
        
        // Checks and cleanup
        guard let searchText = searchBar.text else {
            fatalError("\(#function) was called when there was no search text")
        }
        clearDataArrays()
        
        // Get, filter, and sort the feeds
        let filteredFeeds: [Feed] = DBService.sharedInstance.getObjects().filter({
            return $0.matchesSearch(text: searchText)
        })
        let sortedFeeds: [Feed] = filteredFeeds.sorted(by: {
            guard let firstTitle = $0.title?.lowercased(), let secondTitle = $1.title?.lowercased() else {
                return false
            }
            return firstTitle < secondTitle
        })
        
        // Populate the data arrays and reload the table
        feeds = [sortedFeeds]
        sectionTitles = ["Top Matches"]
        tableView.reloadData()
    }
    
    fileprivate func loadDataArraysForSelectedSegment() {
    
        // Cleanup
        clearDataArrays()
        
        // Get the feeds
        let loadedFeeds: [Feed] = DBService.sharedInstance.getObjects()
        
        // Divide the feeds list via categories
        // Loop through the feeds to build the sectioned feeds
        var sectionedFeeds: [String: [Feed]] = [:]
        let currentSegment = PListService.getSegment() ?? .Category
        for feed in loadedFeeds {
            
            // Get the section title
            let section: String = {
                switch currentSegment {
                case .Category: return feed.category ?? "Default"
                case .Favorite: return feed.favorite ? "Favorites" : "Others"
                }
            }()
            
            // Intialize the array if needed
            if sectionedFeeds[section] == nil {
                sectionedFeeds[section] = []
            }
            
            // Add the feed
            sectionedFeeds[section]?.append(feed)
        }
        
        // Convert the dictionary to a list and sort the inner arrays
        var entries: [(title: String, feeds: [Feed])] = []
        for entry in sectionedFeeds {
            let sortedFeeds = entry.1.sorted(by: { $0.title ?? "" < $1.title ?? "" })
            entries.append((entry.0, sortedFeeds))
        }
        
        // Sort the sections
        entries.sort(by: { $0.0.title < $0.1.title })
        
        // Populate the data arrays and reload the table
        for entry in entries {
            feeds.append(entry.feeds)
            sectionTitles.append(entry.title)
        }
        tableView.reloadData()
    }
    
    fileprivate func setupNavBar() {
    
        // Remove the back bar title when navigating forward
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    
        // Configure the add button
        addButton.target = self
        addButton.action = #selector(addButtonTapped)
        navigationItem.rightBarButtonItem = addButton
        
        // Configure the settings button
        
        // Configure the edit button
        editButton.target = self
        editButton.action = #selector(editButtonTapped)
        navigationItem.leftBarButtonItem = editButton
        
        // Configure the title view with the segment control
        let currentSegment = PListService.getSegment() ?? .Category
        segmentControl.selectedSegmentIndex = Segment.list.index(of: currentSegment.rawValue) ?? 0
        segmentControl.tintColor = FlatUIColor.Clouds
        segmentControl.addTarget(self, action: #selector(segmentDidChange), for: .valueChanged)
        segmentControl.frame.size = CGSize(width: 80, height: 24)
        navigationItem.titleView = segmentControl
    }
    
    fileprivate func setupToolBar() {
    
        // Configure the toolbar
        navigationController?.toolbar.barTintColor = FlatUIColor.WetAsphalt
        
        // Configure the delete button
        deleteButton.target = self
        deleteButton.action = #selector(deleteButtonTapped)
        deleteButton.isEnabled = false
        deleteButton.tintColor = FlatUIColor.Clouds
        
        // Add the buttons to the toolbar
        setToolbarItems([deleteButton], animated: false)
    }
    
    
    // MARK: UIViewController LifeCycle Callbacks
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupToolBar()
    }
    
    
    // MARK: UITableView DataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return feeds.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let feed = feeds[indexPath.section][indexPath.row]
        let reuseId = "feed_cell"
        let cell = MGSwipeTableCell(style: .subtitle, reuseIdentifier: reuseId)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = feed.title
        cell.detailTextLabel?.text = feed.subtitle
        cell.delegate = self
        // TODO - Configure the image
        return cell
    }
    
    
    // MARK: UITableView Delegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let feed = feeds[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        if tableView.isEditing {
            selectedFeedIds.insert(feed.id)
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
            let controller = ArticlesListViewController(feed: feed)
            navigationController?.setNavigationBarHidden(false, animated: false)
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard tableView.isEditing else { return }
        let feed = feeds[indexPath.section][indexPath.row]
        selectedFeedIds.remove(feed.id)
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        // Allows multiselect and shows checkboxes on the left along with blue color fill on selection
        return UITableViewCellEditingStyle(rawValue: 3)! // Undocumented API, forced unwrap is safe
    }
}


// MARK: MGSwipeTableCellDelegate

extension FeedsListViewController: MGSwipeTableCellDelegate  {

    func swipeTableCell(_ cell: MGSwipeTableCell!, canSwipe direction: MGSwipeDirection) -> Bool {
        return true
    }
    
    fileprivate func swipeTableCell(_ cell: MGSwipeTableCell!, swipeButtonsFor direction: MGSwipeDirection, swipeSettings: MGSwipeSettings!, expansionSettings: MGSwipeExpansionSettings!) -> [AnyObject]! {
    
        // Get the feed
        guard let indexPath = tableView.indexPath(for: cell) else { return nil }
        var feed = feeds[indexPath.section][indexPath.row]
        
        if direction == .leftToRight {

            // Configure the swipe settings
            swipeSettings.transition = .clipCenter
            swipeSettings.keepButtonsSwiped = false
            expansionSettings.buttonIndex = 0
            expansionSettings.threshold = 1
            expansionSettings.expansionLayout = .center
            expansionSettings.expansionColor = feed.favorite ? FlatUIColor.Carrot : FlatUIColor.Emerald
            expansionSettings.triggerAnimation.easingFunction = .cubicOut
            expansionSettings.fillOnTrigger = false
            
            // Configure the button
            let title = feed.favorite ? "Unfavorite" : "Favorite"
            let button = MGSwipeButton(title: title, backgroundColor: FlatUIColor.Concrete) {
                [weak self] (_) in
                
                feed.favorite = !feed.favorite
                _ = DBService.sharedInstance.save(feed)
                self?.loadDataArraysForSelectedSegment()
                return true
            }
            return [button!]
        } else {
            swipeSettings.enableSwipeBounces = true
            let button = MGSwipeButton(title: "Delete", backgroundColor: FlatUIColor.Alizarin) {
                [weak self] (_) in
                
                // Delete the feed from the database
                guard DBService.sharedInstance.delete(objectWithId: feed.id) else {
                    self?.tableView.setEditing(false, animated: true)
                    self?.promptError("Failed to delete the feed.")
                    return false
                }
                
                // Remove the feed cell from the table view
                self?.tableView.beginUpdates()
                self?.feeds[indexPath.section].remove(at: indexPath.row)
                self?.tableView.deleteRows(at: [indexPath], with: .right)
                self?.tableView.endUpdates()
                return true
            }
            return [button!]
        }
    }
}
