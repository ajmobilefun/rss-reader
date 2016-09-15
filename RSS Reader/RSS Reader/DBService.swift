//
//  DBService.swift
//  RSS Reader
//
//  Created by Andrew Johnson on 9/5/16.
//  Copyright © 2016 Andrew Johnson. All rights reserved.
//
//  This file contains all of the types associates with
//  the DBService along with the DBService itself.
//

import Foundation
import Gloss


/**
    A protocol that encapusulates the information needed for
    an object to interact with the database.
*/
protocol CBLDocument: Glossy {
    var id: String { get }
    var rev: String? { get }
    static var view: CBLView { get }
}


/**
    A type that encapsulates the necessary information to setup a view.
*/
typealias ViewConfig = (view: CBLView, version: UInt, keysPaths: [String], valuesPath: [String])


/**
    An enum that encapsulates the top-level KVP tied to a document.
*/
enum CBLView: String {
    case Feeds, Articles
    static let viewKey = "cbl_view"
}


/**
    A service responsible for managing a Couchbase Lite database.
*/
final class DBService {
    
    // MARK: Fields
    
    static let sharedInstance = DBService()
    private let dbName = "rss_reader"
    private let manager: CBLManager = CBLManager.sharedInstance()
    private let db: CBLDatabase
    
    
    // MARK: Initializers
    
    private init() {
    
        // Open the database
        do { try db = manager.databaseNamed(dbName) }
        catch let _ { fatalError("Failed to instantiate the database") }
        
        // Setup the feeds view
        let feedsViewConfig: ViewConfig = (.Feeds, 0, [], [])
        setupView(feedsViewConfig)
        
        // Setup the articles view
        let articlesViewConfig: ViewConfig = (.Articles, 0, [], [])
        setupView(articlesViewConfig)
    }
    
    
    // MARK: Helper Methods
    
    // NOTE: The values produced from the keys keypaths must not be nil.
    // Forced unwrapping is used by assuming this. This is because we want
    // Our keys array to always be equivalent in size.
    private func setupView(viewConfig: ViewConfig) {
        
        // Get the view
        let viewName = viewConfig.view.rawValue
        let view = db.viewNamed(viewName)
        
        // Set the map/reduce block
        view.setMapBlock({ (doc, emit) in
            
            // Only emit the document if it has the correct value 
            // for the view key
            if let feedViewName = doc[CBLView.viewKey] as? String
            where feedViewName == viewName {
            
                // Get the keys
                let keys: [AnyObject] = viewConfig.keysPaths.map({
                    doc.getValueForKeyPath($0)!
                })
                
                // Get the compact doc
                var values = [String: AnyObject]()
                viewConfig.valuesPath.forEach({
                    let value = doc.getValueForKeyPath($0)
                    values[$0] = value
                })
                
                // Emit the row
                emit(keys, values)
            }
            
        }, reduceBlock: { (keys, values, rereduce) in
        
            // Return the number of documents
            return values.count
            
        }, version: "\(viewConfig.version)")
        // Increment the version when either block is altered
        // after deployment
    }
    
    
    // MARK: Public Methods
    
    func delete(documentWithId id: String) {
        let _ = try? db.deleteLocalDocumentWithID(id)
    }
    
    func get<Object: CBLDocument>(documentWithId id: String) -> Object? {
    
        // Get the document
        guard
        let document = db.existingDocumentWithID(id),
        let dictionary = document.properties
        else { return nil }
        
        // Initialize and return the object
        return Object(json: dictionary)
    }
    
    func getObjects<Object: CBLDocument>() -> [Object] {
        
        // Get the view
        let viewName = Object.view.rawValue
        guard let view = db.existingViewNamed(viewName)
        else { return [] }
        
        // Run the query
        let query = view.createQuery()
        query.prefetch = true
        guard let enumerator = try? query.run()
        else { return [] }
        
        var objects = [Object]()
        while let row = enumerator.nextRow() {
            guard
            let json = row.documentProperties,
            let object = Object(json: json)
            else { continue }
            objects.append(object)
        }
        return objects
    }
}