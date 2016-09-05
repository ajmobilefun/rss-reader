//
//  XMLParser.swift
//  RSS Reader
//
//  Created by Andrew Johnson on 9/4/16.
//  Copyright © 2016 Andrew Johnson. All rights reserved.
//

import Foundation


// MARK: Global Types

/// A type that defines the XML tree.
typealias XMLDictionary = [String: AnyObject]

//// A type that pairs a tag name with its value.
typealias XMLElement = (tagName: String, value: String)


/**
    A service that assists analyzing XML data.
    
    - author: Andrew Johnson
*/
struct XMLService {
    
    static func parseToDictionary(data: NSData, callback: (dict: XMLDictionary) -> ()) {
    
        let worker = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        let main = dispatch_get_main_queue()
        dispatch_async(worker) {
            let parser = XMLParser()
            let dict = parser.parseToDictionary(data)
            dispatch_async(main) {
                callback(dict: dict)
            }
        }
    }
}


/**
    A private singleton class that parses XML from NSData to a dictionary. The generated dictionary
    resembles the same hierarchy defined by the XML elements. This class is used only on a worker thread
    in the XMLService.
    
    - author: Andrew Johnson
*/
private final class XMLParser: NSObject, NSXMLParserDelegate {
    
    // MARK: Fields
    
    /// The XML data provided on initialization.
    private var data: NSData?
    
    /// The current heierarchy of XML element tags being parsed.
    private var currentTags: [String] = []
    
    /// A flag indicating the data was successfully parsed.
    private var successful: Bool = true
    
    /// The reutrn dictionary when the object finishes parsing.
    private var dict: XMLDictionary = [:]
    
    
    // MARK: Helper Methods
    
    // Creates the current key path from the current tags
    private func currentKeyPath() -> String {
        return currentTags.reduce("", combine: { $1 + $0 })
    }
    
    // MARK: Parsing Method
    
    /// A function that parses XML data to a Swift dictionary. If an error
    /// occurs, the success flag will be false.
    func parseToDictionary(data: NSData) -> XMLDictionary {
        let parser = NSXMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return dict
    }


    // MARK: NSXMLParserDelegate
    
    // Found a new start tag
    @objc func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentTags.append(elementName)
    }
    
    // Found characters for a tag
    @objc func parser(parser: NSXMLParser, foundCharacters string: String) {
    
        let path = currentKeyPath()
    
        // Get the current string or create it
        guard let str = dict.getValueForKeyPath(currentKeyPath()) as? String else {
            dict.setValueForKeyPath(path, value: string)
            return
        }
        
        // Append the existing string
        let newStr = str + string
        dict.setValueForKeyPath(path, value: newStr)
    }
    
    // Finished parsing a tag
    @objc func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    
        // Get the index and erase everything there and after from the current tags
        guard let index = currentTags.indexOf(elementName) else {
            // TODO - Propagate error message to user?
            fatalError("Start tag was never accounted")
        }
        let tagsCount = currentTags.startIndex.distanceTo(index)
        let sliceCount = currentTags.count - tagsCount
        for _ in 0...sliceCount { currentTags.removeLast() }
    }
    
    // Error occured
    @objc func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        // TODO - Propogate error message to user?
        successful = false
        print(parseError.localizedDescription)
    }
}