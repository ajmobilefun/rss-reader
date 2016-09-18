//
//  FeedsListViewController.swift
//  RSS Reader
//
//  Created by Andrew Johnson on 9/5/16.
//  Copyright © 2016 Andrew Johnson. All rights reserved.
//

import Foundation
import UIKit


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
    
    private var feeds: [[Feed]] = []
    private var sectionTitles: [String] = []
    private var searchBar = UISearchBar(frame: CGRect.null)
    private var segmentControl = UISegmentedControl(items: Segment.list)
    private var addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: nil, action: nil)
    private var currentSegment: Segment = .Category
    
    
    // MARK: Helper Methods
    
    func addButtonTapped() {
        let controller = EditableFeedViewController(feed: nil)
        AppUtils.popup(controller, fromController: self)
    }
    
    private func loadFeeds() {
    
        // Clear the data arrays
        sectionTitles = []
        feeds = []
        
        // Load and filter the feeds by search text
        var loadedFeeds: [Feed] = MockFactory.generateMockFeeds()// DBService.sharedInstance.getObjects()
        if let text = searchBar.text where text != "" {
            loadedFeeds = loadedFeeds.filter({
                let title = $0.title ?? ""
                let subtitle = $0.subtitle ?? ""
                let searchableText = "\(title) \(subtitle)"
                return searchableText.containsString(text)
            })
        }
        
        // Loop through the feeds to build the sectioned feeds
        var sectionedFeeds: [String: [Feed]] = [:]
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
            let sortedFeeds = entry.1.sort({ $0.title ?? "" < $1.title ?? "" })
            entries.append((entry.0, sortedFeeds))
        }
        
        // Sort the sections
        entries.sortInPlace({ $0.0.title < $0.1.title })
        
        // Populate the data arrays
        for entry in entries {
            feeds.append(entry.feeds)
            sectionTitles.append(entry.title)
        }
        
        tableView.reloadData()
    }
    
    private func setupNavBar() {
    
        // Configure the add button
        addButton.target = self
        addButton.action = #selector(addButtonTapped)
        navigationItem.rightBarButtonItem = addButton
        
        // Set the title
        navigationItem.title = "Feeds"
    }
    
    private func setupTable() {
        
        tableView.backgroundColor = FlatUIColor.TableLight
        
        // Setup the table header
        // Configure the subviews
        currentSegment = PListService.getSegment() ?? .Category
        segmentControl.selectedSegmentIndex = Segment.list.indexOf(currentSegment.rawValue) ?? 0
        segmentControl.tintColor = FlatUIColor.WetAsphalt
        searchBar.searchBarStyle = .Minimal
        
        // Create a container for the subviews
        let intrinsicHeight: CGFloat = 90
        let container: UIView = UIView(frame: CGRect(
            x: tableView.frame.origin.x,
            y: tableView.frame.origin.y - intrinsicHeight,
            width: tableView.frame.size.width,
            height: intrinsicHeight
        ))
        
        // Add the subviews
        [searchBar, segmentControl].forEach({
            container.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        // Create the constraints
        let views = ["segmentedControl" : segmentControl, "searchBar": searchBar]
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-8-[segmentedControl]-8-[searchBar]-8-|",
            options: .AlignAllCenterX,
            metrics: nil,
            views: views
        )
        
        let hSegConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-16-[segmentedControl]-16-|",
            options: [],
            metrics: nil,
            views: views
        )
        
        let hSearchConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-8-[searchBar]-8-|",
            options: [],
            metrics: nil,
            views: views
        )
        
        // Add the constraints
        container.addConstraints(vConstraints + hSegConstraints + hSearchConstraints)
        tableView.tableHeaderView = container
    }
    
    
    // MARK: UIViewController LifeCycle Callbacks
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupTable()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadFeeds()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        let _ = searchBar.resignFirstResponder()
    }
    
    
    // MARK: UITableView DataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return feeds.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds[section].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let feed = feeds[indexPath.section][indexPath.row]
        let reuseId = "feed_cell"
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: reuseId)
        cell.accessoryType = .DisclosureIndicator
        cell.textLabel?.text = feed.title
        cell.detailTextLabel?.text = feed.subtitle
        // TODO - Configure the image
        return cell
    }
    
    
    // MARK: UITableView Delegate
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let feed = feeds[indexPath.section][indexPath.row]
        // TODO - Navigate to the feed view controller
    }
}