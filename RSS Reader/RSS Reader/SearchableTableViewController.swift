//
//  SearchableTableViewController.swift
//  RSS Reader
//
//  Created by Andrew Johnson on 10/1/16.
//  Copyright © 2016 Andrew Johnson. All rights reserved.
//

import Foundation
import UIKit

/**
    An abstract base class that provides behavior for a UISearchBar
    in a UITableView.
*/
class SearchableTableViewController: UITableViewController {

    // MARK: Fields
    
    let searchBar = UISearchBar(frame: CGRect.null)
    
    
    // MARK: Initializers
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("\(#function) should not be used")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) should not be used")
    }
    
    // MARK: Abstract Methods
    
    func reloadDataSource() {
        fatalError("\(#function) should not be used")
    }
    
    
    // MARK: Helper Methods
    
    func isSearching() -> Bool {
        let notNil = searchBar.text != nil
        let notEmpty = searchBar.text != ""
        return notNil && notEmpty
    }
    
    fileprivate func setTableEnabled(enabled: Bool) {
        tableView.allowsSelection = enabled
        // TODO - Shadow table
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
        setupTable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(isSearching(), animated: true)
        reloadDataSource()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Dismiss keyboard if needed
        searchBar.resignFirstResponder()
    }
    
    // MARK: UIScrollView Delegate
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
}


// MARK: UISearchBar Delegate

extension SearchableTableViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        navigationController?.setNavigationBarHidden(true, animated: true)
        searchBar.setShowsCancelButton(true, animated: true)
        setTableEnabled(enabled: isSearching())
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    
        // Reset the searchBar state
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = nil
        
        // Show the navBar and enable the table
        navigationController?.setNavigationBarHidden(false, animated: true)
        setTableEnabled(enabled: true)
        
        // Reload the data
        reloadDataSource()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        setTableEnabled(enabled: isSearching())
        reloadDataSource()
    }
}
