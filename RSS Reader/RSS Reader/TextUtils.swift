//
//  TextUtils.swift
//  RSS Reader
//
//  Created by Andrew Johnson on 9/16/16.
//  Copyright © 2016 Andrew Johnson. All rights reserved.
//

import Foundation

struct TextUtils {

    static func boldSearchResult(searchString: String?, resultString: String?, size: CGFloat?) -> NSMutableAttributedString {
        guard let searchString = searchString, let resultString = resultString else { return NSMutableAttributedString() }
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: resultString)
        let pattern: String = searchString.lowercaseString
        let range: NSRange = NSMakeRange(0, resultString.characters.count)
        guard let regex: NSRegularExpression = try? NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions())
        else { return NSMutableAttributedString(string: resultString) }
        regex.enumerateMatchesInString(resultString.lowercaseString, options: NSMatchingOptions(), range: range) { (textCheckingResult, matchingFlags, stop) -> Void in
            let subRange = textCheckingResult?.range
            attributedString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(size ?? 12), range: subRange!)
        }
        return attributedString
    }
}