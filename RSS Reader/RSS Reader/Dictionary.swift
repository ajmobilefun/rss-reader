//
//  Dictionary.swift
//  RSS Reader
//
//  Created by Andrew Johnson on 9/4/16.
//  Copyright © 2016 Andrew Johnson. All rights reserved.
//

import Foundation

extension Dictionary {

    /// A method that generates a set of all the key paths existing in the
    /// dictionary.
    func allKeyPaths() -> Set<String> {
    
        // Container for keypaths
        var keyPaths = Set<String>()
        
        // Recursive function
        func allKeyPaths(forDictionary dict: Dictionary<Key, Value>, previousKeyPath path: String?) {
        
            // Loop through the dictionary keys
            for key in dict.keys {
            
                // Define the new keyPath
                let keyPath = path != nil ? "\(path!).\(key)" : key as! String
                
                // Recurse if the value for the key is another dictionary
                if let nextDict = dict[key] as? Dictionary {
                    allKeyPaths(forDictionary: nextDict, previousKeyPath: keyPath)
                    continue
                }
                
                // End the recursion and append the keyPath
                keyPaths.insert(keyPath)
            }
        }
        allKeyPaths(forDictionary: self, previousKeyPath: nil)
        return keyPaths
    }

    func getValueForKeyPath(path: String) -> Value? {
    
        func recursion(keys: [String]) -> Value? {
        
            var keys = keys
            guard let key = keys.first! as? Key else { return nil }
            let keysRemain = keys.count > 1
            
            // Recurse if the value is a dictionary and there is more than one key left
            if let dict = self[key] as? Dictionary where keysRemain {
                let _ = keys.removeFirst()
                return dict.getValueForKeyPath(keys.joinWithSeparator("."))
            } else if keysRemain { return nil }
            else { return self[key] }
        }
        return recursion(path.componentsSeparatedByString("."))
    }
    
    /// A function that sets the value for a keypath with a
    /// '.' delimiter. This function will apply the path and value
    /// under all conditions, if and only if, the dictionary is
    /// JSON.
    mutating func setValueForKeyPath(path: String, value: AnyObject?) {
    
        // Assert the type parameters
        guard (String.self == Key.self) && (AnyObject?.self == Value.self)
        else { return }
        
        // Beak the path into individual keys
        let keys = path.componentsSeparatedByString(".")
        
        // Generate the subpaths and exlude the final key
        // e.g. "test.path.one.two" -> ["test.path.one", "test.path", "test"]
        var subPaths = [String]()
        for i in 0...keys.count - 1 { // -1 exludes last
            let endIndex = keys.count - i
            let slice = keys[0..<endIndex]
            let subPath = slice.reduce("", combine: { $0 + ".\($1)" })
            subPaths.append(subPath)
        }
        
        // TODO - Possibly use currying function instead of array storage
        // passing refering to values
        
        // Loop through the subpaths and create the sub-dictionaries
        var dicts = [Dictionary]()
        for subPath in subPaths {
            
            // Define optional dict now for cleaner syntax
            let dict = getValueForKeyPath(subPath) as? Dictionary
            
            // Get the current key
            // Type checked at the beginning of the function
            guard let key = subPath.componentsSeparatedByString(".").last as? Key
            else { return }
            
            // If this is the first dictionary set the value
            if dicts.count == 0 {
            
                // If a dictionary exists set the new value
                // Otherwise, create a new dictionary with the new value
                if var dict = dict {
                    dict[key] = value as? Value
                    dicts.append(dict)
                } else {
                    var newDict = Dictionary()
                    newDict[key] = value as? Value
                    dicts.append(newDict)
                }
            } else {
            
                // If a dictionary exists set the last dictionary
                // in the dicts array, otherwise create a new dictionary
                let value = dicts.last as? Value
                if var dict = dict {
                    dict[key] = value
                    dicts.append(dict)
                } else {
                
                    // Create a new dictionary and set the current key
                    // with the prior dictionary in the list
                    var newDict = Dictionary()
                    newDict[key] = value
                    dicts.append(newDict)
                }
            }
        }
        
        // Get the last dictionary in the list which is the new value
        guard let newValue = dicts.last, key = keys.first as? Key else { return }
        self[key] = newValue as? Value
    }
}