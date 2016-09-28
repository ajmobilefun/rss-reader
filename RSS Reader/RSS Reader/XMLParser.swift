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
    
    static func parseToDictionary(_ data: Data, callback: @escaping (_ dict: XMLDictionary) -> ()) {
        guard let qos = DispatchQoS.QoSClass(rawValue: QOS_CLASS_DEFAULT) else {
            return
        }
        let worker = DispatchQueue.global(qos: qos)
        let main = DispatchQueue.main
        worker.async {
            let parser = XMLParser()
            let dict = parser.parseToDictionary(data)
            main.async {
                callback(dict)
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
private final class XMLParser: NSObject, XMLParserDelegate {
    
    // MARK: Fields
    
    /// The XML data provided on initialization.
    fileprivate var data: Data?
    
    /// The current heierarchy of XML element tags being parsed.
    fileprivate var currentTags: [String] = []
    
    /// A flag indicating the data was successfully parsed.
    fileprivate var successful: Bool = true
    
    /// The reutrn dictionary when the object finishes parsing.
    fileprivate var dict: XMLDictionary = [:]
    
    
    // MARK: Helper Methods
    
    // Creates the current key path from the current tags
    fileprivate func currentKeyPath() -> String {
        return currentTags.reduce("", { $1 + $0 })
    }
    
    // MARK: Parsing Method
    
    /// A function that parses XML data to a Swift dictionary. If an error
    /// occurs, the success flag will be false.
    func parseToDictionary(_ data: Data) -> XMLDictionary {
        let parser = Foundation.XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return dict
    }


    // MARK: NSXMLParserDelegate
    
    // Found a new start tag
    @nonobjc func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentTags.append(elementName)
    }
    
    // Found characters for a tag
    @nonobjc func parser(_ parser: XMLParser, foundCharacters string: String) {
    
        let path = currentKeyPath()
    
        // Get the current string or create it
        guard let str = dict.getValueForKeyPath(currentKeyPath()) as? String else {
            dict.setValueForKeyPath(path, value: string as AnyObject?)
            return
        }
        
        // Append the existing string
        let newStr = str + string
        dict.setValueForKeyPath(path, value: newStr as AnyObject?)
    }
    
    // Finished parsing a tag
    @nonobjc func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    
        // Get the index and erase everything there and after from the current tags
        guard let index = currentTags.index(of: elementName) else {
            // TODO - Propagate error message to user?
            fatalError("Start tag was never accounted")
        }
        let tagsCount = currentTags.startIndex.distance(to: index)
        let sliceCount = currentTags.count - tagsCount
        for _ in 0...sliceCount { currentTags.removeLast() }
    }
    
    // Error occured
    @nonobjc func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        // TODO - Propogate error message to user?
        successful = false
        print(parseError.localizedDescription)
    }
}
