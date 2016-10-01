//
//  ArticleViewController.swift
//  RSS Reader
//
//  Created by Andrew Johnson on 9/5/16.
//  Copyright © 2016 Andrew Johnson. All rights reserved.
//

import Foundation
import UIKit

final class ArticleViewController: UIViewController {

    // MARK: Fields
    
    var article: Article
    
    init(article: Article) {
        self.article = article
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
