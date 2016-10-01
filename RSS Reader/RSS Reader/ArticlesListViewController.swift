//
//  ArticlesListViewController.swift
//  RSS Reader
//
//  Created by Andrew Johnson on 9/5/16.
//  Copyright © 2016 Andrew Johnson. All rights reserved.
//

import Foundation
import UIKit

final class ArticlesListViewController: SearchableTableViewController {
    
    // MARK: Fields
    
    var feed: Feed
    var articles: [Article] = []
    
    
    // MARK: Initializers
    
    init(feed: Feed) {
        self.feed = feed
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) should not be used")
    }
    
    // MARK: Abstract Method Implementations
    
    override func reloadDataSource() {
        isSearching() ? loadArticlesForSearchText() : loadAllArticles()
    }
    
    
    // MARK: Helper Methods
    
    func loadAllArticles() {
    
    }
    
    func loadArticlesForSearchText() {
//        guard let searchText = searchB
//        articles = DBService.sharedInstance.getObjects().filter({
//            $0.
//        })
    }
    
    // MARK: UIViewController LifeCycle Callbacks
    
    
    
    // MARK: UITableView DataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let article = articles[(indexPath as NSIndexPath).row]
        let reuseId = "article_cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId) ?? UITableViewCell(style: .subtitle, reuseIdentifier: reuseId)
        cell.textLabel?.text = article.title
        cell.detailTextLabel?.text = article.description
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    
    // MARK: UITableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let article = articles[indexPath.row]
        // TODO - Go to article
    }
}


// MARK: UISearchBar Delegate

extension ArticlesListViewController {
    
    
}
