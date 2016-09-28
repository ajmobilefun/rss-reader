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
final class FeedsListViewController: UITableViewController {

    // MARK: Fields
    
    // Data sources
    fileprivate var feeds: [[Feed]] = []
    fileprivate var sectionTitles: [String] = []
    fileprivate var selectedFeedIds: Set<String> = [] {
        didSet {
            favoriteButton.isEnabled = selectedFeedIds.count != 0
            deleteButton.isEnabled = selectedFeedIds.count != 0
        }
    }
    
    // Views
    fileprivate let searchBar = UISearchBar(frame: CGRect.null)
    fileprivate let segmentControl = UISegmentedControl(items: Segment.list)
    fileprivate let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: nil, action: nil)
    fileprivate let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
    fileprivate let settingsButton = UIBarButtonItem(title: "Settings", style: .plain, target: nil, action: nil)
    fileprivate let deleteButton = UIBarButtonItem(title: "Delete", style: .plain, target: nil, action: nil)
    fileprivate let favoriteButton = UIBarButtonItem(title: "Favorite", style: .plain, target: nil, action: nil)
    
    // MARK: Selectors
    
    func segmentDidChange() {
        let index = segmentControl.selectedSegmentIndex
        let rawValue = Segment.list[index]
        let currentSegment = Segment(rawValue: rawValue) ?? .Category
        PListService.setSegment(currentSegment)
        loadFeeds()
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
        
        searchBar.barTintColor = FlatUIColor.Emerald
        navigationController?.setToolbarHidden(!tableView.isEditing, animated: true)
        editButton.title = tableView.isEditing ? "Cancel" : "Edit"
    }
    
    func deleteButtonTapped() {
        
        // Prompt warning
        promptDelete()
        
        
        // Remove rows
    }
    
    func favoriteButtonTapped() {
        
    }
    
    
    // MARK: Helper Methods
    
    fileprivate func promptDelete() {
    
        // Generate the text
        let dynamicText = selectedFeedIds.count > 1 ? "Are you sure you want to delete these \(selectedFeedIds.count) items?" : "Are you sure you want to delete this item?"
        
        // Create and prepare the controller
        let alertController = UIAlertController(title: "Warning", message: "Are you sou you want to delete \(dynamicText)", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .destructive, handler: { [weak self] (_) in
            guard let ids = self?.selectedFeedIds else { return }
            for id in ids {
                _ = DBService.sharedInstance.delete(objectWithId: id) // TODO - Prompt error
            }
            self?.selectedFeedIds = []
        })
        let no = UIAlertAction(title: "No", style: .cancel, handler: { _ in
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
    
    fileprivate func loadFeeds() {
    
        // Clear the data arrays
        sectionTitles = []
        feeds = []
        
        // Load and filter the feeds by search text
        var loadedFeeds: [Feed] = DBService.sharedInstance.getObjects()
        if let text = searchBar.text, text != "" {
            loadedFeeds = loadedFeeds.filter({
                let title = $0.title ?? ""
                let subtitle = $0.subtitle ?? ""
                let searchableText = "\(title) \(subtitle)"
                return searchableText.contains(text)
            })
        }
        
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
        
        // Populate the data arrays
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
    
    func setupToolBar() {
        
        // Configure the delete button
        deleteButton.target = self
        deleteButton.action = #selector(deleteButtonTapped)
        deleteButton.isEnabled = false
        
        // Configure the favorite button
        favoriteButton.target = self
        favoriteButton.action = #selector(favoriteButtonTapped)
        favoriteButton.isEnabled = false
        
        // Add the buttons to the toolbar
        navigationController?.setToolbarItems([deleteButton, favoriteButton], animated: false)
    }
    
    fileprivate func setupTable() {
        
        // Configure the table
        tableView.backgroundColor = FlatUIColor.TableLight
        tableView.allowsMultipleSelectionDuringEditing = true
        
        // Configure the table header search bar
        searchBar.searchBarStyle = .minimal
        searchBar.tintColor = FlatUIColor.MidnightBlue
        searchBar.frame.size = CGSize(width: tableView.frame.width, height: 45)
        searchBar.delegate = self
        tableView.tableHeaderView = searchBar
    }
    
    
    // MARK: UIViewController LifeCycle Callbacks
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        setupNavBar()
        setupToolBar()
        setupTable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadFeeds()
        
        // Configure the starting position
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let _ = searchBar.resignFirstResponder()
    }
    
    
    // MARK: UITableView DataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return feeds.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let feed = feeds[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
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
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard tableView.isEditing else { return }
        let feed = feeds[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
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
    
    private func swipeTableCell(_ cell: MGSwipeTableCell!, swipeButtonsFor direction: MGSwipeDirection, swipeSettings: MGSwipeSettings!, expansionSettings: MGSwipeExpansionSettings!) -> [AnyObject]! {
    
        // Get the feed
        guard let indexPath = tableView.indexPath(for: cell) else { return nil }
        var feed = feeds[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        
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
                self?.loadFeeds()
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
                self?.feeds[(indexPath as NSIndexPath).section].remove(at: (indexPath as NSIndexPath).row)
                self?.tableView.deleteRows(at: [indexPath], with: .right)
                self?.tableView.endUpdates()
                return true
            }
            return [button!]
        }
    }
}


// MARK: UISearchBar Delegate

extension FeedsListViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        navigationController?.setNavigationBarHidden(true, animated: true)
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        tableView.isUserInteractionEnabled = true
        navigationController?.setNavigationBarHidden(false, animated: true)
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        loadFeeds()
    }
}
