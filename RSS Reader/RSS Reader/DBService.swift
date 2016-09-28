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
protocol CBLObject: Glossy {
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
    fileprivate let dbName = "rss_reader"
    fileprivate let manager: CBLManager = CBLManager.sharedInstance()
    fileprivate let db: CBLDatabase
    
    
    // MARK: Initializers
    
    fileprivate init() {
    
        // Open the database
        do { try db = manager.databaseNamed(dbName) }
        catch _ { fatalError("Failed to instantiate the database") }
        
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
    fileprivate func setupView(_ viewConfig: ViewConfig) {
        
        // Get the view
        let viewName = viewConfig.view.rawValue
        let view = db.viewNamed(viewName)
        
        // Set the map/reduce block
        view.setMapBlock({ (doc, emit) in
            
            // Only emit the document if it has the correct value 
            // for the view key
            if let feedViewName = doc[CBLView.viewKey] as? String, feedViewName == viewName {
            
                // Get the keys
                let keys: [AnyObject] = viewConfig.keysPaths.map({
                    doc.getValueForKeyPath($0) as AnyObject
                })
                
                // Get the compact doc
                var values = [String: AnyObject]()
                viewConfig.valuesPath.forEach({
                    let value = doc.getValueForKeyPath($0)
                    values[$0] = value as AnyObject?
                })
                
                // Emit the row
                emit(keys, nil)
            }
            
        }, reduce: { (keys, values, rereduce) in
        
            // Return the number of documents
            return values.count
            
        }, version: "\(viewConfig.version)")
        // Increment the version when either block is altered
        // after deployment
    }
    
    
    // MARK: Destructors
    
    func delete(objectWithId id: String) -> Bool {
        guard let _ = try? db.deleteLocalDocument(withID: id) else {
            print("\(#file) \(#function) - Failed to delete a document with id: \(id)")
            return false
        }
        return true
    }
    
    func reset() -> Bool {
        guard let _ = try? db.delete() else {
            print("\(#file) \(#function) - Failed to delete the database")
            return false
        }
        return true
    }
    
    
    // MARK: Getters
    
    func get<Object: CBLObject>(objectWithId id: String) -> Object? {
    
        // Get the document
        guard let document = db.existingDocument(withID: id) else {
            print("\(#file) \(#function) - A document does not exist for id: \(id)")
            return nil
        }
        
        // Get the properties
        guard let dictionary = document.properties else {
            print("\(#file) \(#function) - The document does not have any properties")
            return nil
        }
        
        // Initialize and return the object
        return Object(json: dictionary as JSON)
    }
    
    func getObjects<Object: CBLObject>() -> [Object] {
        
        // Get the view
        let viewName = Object.view.rawValue
        guard let view = db.existingViewNamed(viewName)
        else {
            print("\(#file) \(#function) - A view does not exist for name \(viewName)")
            return []
        }
        
        print(view.totalRows)
        
        // Run the query
        let query = view.createQuery()
        query.prefetch = true
        query.mapOnly = true
        guard let enumerator = try? query.run()
        else {
            print("\(#file) \(#function) - Failed to run the query")
            return []
        }
        
        // Loop through the view
        var objects = [Object]()
        while let row = enumerator.nextRow() {
            
            // Get the properties
            guard let json = row.documentProperties else {
                print("\(#file) \(#function) - There are no properties for the document")
                continue
            }
            
            // Instantiate and add the object
            guard let object = Object(json: json as JSON) else {
                print("\(#file) \(#function) - Failed to instantiate the object")
                continue
            }
            objects.append(object)
        }
        return objects
    }
    
    
    // MARK: Savers
    
    func save<Object: CBLObject>(_ object: Object) -> Bool {
    
        // Convert the object in to json
        guard var json = object.toJSON() else {
            print("\(#file) \(#function) -  Unable to produce json from the passed object")
            return false
        }
        
        // Get the document and overwrite it
        let document = db.document(withID: object.id)
        json[CBLView.viewKey] = Object.view.rawValue as AnyObject?
        guard let _ = try? document?.putProperties(json) else {
            print("\(#file) \(#function) - Failed to put properties onto document with id \(object.id)")
            return false
        }
        
        return true
    }
}



