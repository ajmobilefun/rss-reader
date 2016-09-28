//
//  ArticlesListViewController.swift
//  RSS Reader
//
//  Created by Andrew Johnson on 9/5/16.
//  Copyright © 2016 Andrew Johnson. All rights reserved.
//

import Foundation
import UIKit

final class ArticlesListViewController: UITableViewController {
    
    // MARK: Fields
    
    var feed: Feed
    var articles: [ArticleSnippet] = []
    
    
    // MARK: Initializers
    
    init(feed: Feed) {
        self.feed = feed
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) should not be used")
    }
    
    
    // MARK: Helper Methods
    
    
    
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt     indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // TODO - Go to article
    }
}
