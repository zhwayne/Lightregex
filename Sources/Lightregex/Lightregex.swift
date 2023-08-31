//
//  Lightregx.swift
//  Lightregx
//
//  Created by Wayne on 2018/6/26.
//  Copyright © 2018 Wayne. All rights reserved.
//

import Foundation

/// While the regular expression module in iOS is remarkably powerful, utilizing it can be quite intricate.
/// Often, implementing even a basic requirement necessitates crafting convoluted code. To streamline the process,
/// this framework encapsulates `NSRegularExpression`, aiming to simplify regular expression usage for developers.
public struct Lightregx: Equatable {
    
    /// The regular expression pattern.
    public var pattern: String {
        return regularExpression.pattern
    }
    
    private let regularExpression: NSRegularExpression
    
    public init(_ pattern: String) throws {
        let options: NSRegularExpression.Options = [.dotMatchesLineSeparators, .anchorsMatchLines]
        regularExpression = try NSRegularExpression(pattern: pattern, options: options)
    }
}

extension Lightregx: ExpressibleByStringLiteral {
    
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: StringLiteralType) {
        try! self.init(value)
    }
}

extension Lightregx {
    
    public struct Match: Equatable {
        
        public let string: String
        public let groups: [String]
        
        init(string: String, groups: [String] = []) {
            self.string = string
            self.groups = groups
        }
    }
    
    /// Checks whether the regular expression matches a given string.
    ///
    /// - Parameter string: The string to be matched.
    /// - Returns: Returns true if the string matches the regular expression.
    public func match(in string: String) -> Bool {
        
        let range = NSRange(location: 0, length: string.count)
        return !regularExpression.matches(in: string, options: [], range: range).isEmpty
    }
    
    /// Retrieves all matching results. Each result includes the matched string and
    /// the captured groups based on the regular expression pattern.
    /// For instance:
    ///
    ///     let regx = Lightregx("(\\d{3})-(\\d{3,8})")!
    ///     let res = regx.wholeMatch(in: "Tel: 010-12345 & 027-12345678")
    ///
    ///     print(res.map { $0.string })
    ///     /// Prints: ["010-12345", "027-12345678"]
    ///
    ///     print(res.map { $0.groups })
    ///     /// Prints: [["010", "12345"], ["027", "12345678"]]
    ///
    /// - Parameter string: The string to be matched.
    /// - Returns: An array of matching results.
    public func wholeMatch(in string: String) -> [Match]? {
        
        let range = NSRange(location: 0, length: string.count)
        let res = regularExpression.matches(in: string, options: [], range: range).compactMap({ result -> Match? in
            guard let range = Range(result.range), let matchText = string[range]?.string, !matchText.isEmpty else {
                return nil
            }
            let groups = (0..<result.numberOfRanges).reduce([], { (res, idx) -> [String] in
                if idx > 0, let text = string[Range(result.range(at: idx))!]?.string {
                    return res + [text]
                }
                return res
            })
            
            return Match(string: matchText, groups: groups)
        })
        return res.isEmpty ? nil : res
    }
    
    /// Sometimes, retrieving the first matching result is sufficient. This method facilitates that.
    ///
    /// - Parameter string: The string to be matched.
    /// - Returns: The first matching result, if found.
    public func firstMatch(in string: String) -> Match? {
        
        let range = NSRange(location: 0, length: string.count)
        guard let result = regularExpression.firstMatch(in: string, options: [], range: range) else { return nil }
        guard let r = Range(result.range), let matchText = string[r]?.string, !matchText.isEmpty else {
            return nil
        }
        let groups = (0..<result.numberOfRanges).reduce([], { (res, idx) -> [String] in
            if idx > 0, let text = string[Range(result.range(at: idx))!]?.string {
                return res + [text]
            }
            return res
        })
        
        return Match(string: matchText, groups: groups)
    }
    
    /// This method replaces the matched substrings with a provided template string.
    /// For example, to replace all numbers in a string with `*`, you can do the following:
    ///
    ///     let text = "I bought this pair of shoes for $50 this afternoon at 3pm."
    ///     let regx = Lightregx("\\d")
    ///     let res = regx.replacing(in: text, with: "*")
    ///     print(res)
    ///     /// Prints: "I bought this pair of shoes for $** this afternoon at *pm."
    ///
    /// - Parameters:
    ///   - string: The string to be matched.
    ///   - replacement: The template string to replace matches.
    /// - Returns: The new string with replacements.
    public func replacing(in string: String, with replacement: String) -> String {
        
        let range = NSRange(location: 0, length: string.count)
        return regularExpression.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: replacement)
    }
    
    /// Sometimes, you may require more complex operations on the matched substrings, such as doubling numbers in a string.
    /// This method facilitates such transformations:
    ///
    ///     let regx = Lightregx("\\d")
    ///     let res = regx.replacing(in: "A1B23C45D678E") { "\(Int($0)! * 2)" }
    ///     print(res)
    ///     /// Prints: "A2B46C810D121416E"
    ///
    ///     let regx = Lightregx("\\d+")
    ///     let res = regx.replacing(in: "A1B23C45D678E") { "\(Int($0)! * 2)" }
    ///     print(res)
    ///     /// Prints: "A2B46C90D1356E"
    ///
    /// - Parameters:
    ///   - string: The string to be matched.
    ///   - apply: A closure to transform the matched substrings.
    /// - Returns: The new string with applied transformations.
    public func replacing(in string: String, transform apply: (String) -> String?) -> String {
        
        let range = NSRange(location: 0, length: string.count)
        return regularExpression
            .matches(in: string, options: .reportProgress, range: range)
            .reversed()
            .reduce(string, { (str, result) -> String in
                let range = Range.init(result.range, in: str)!
                var strCopy = str
                strCopy.replaceSubrange(range, with: apply(str[range].string) ?? "")
                return strCopy
            })
    }
}



extension String {
    
    public subscript(range: Range<Int>) -> Substring? {
        guard let left = index(startIndex, offsetBy: range.lowerBound, limitedBy: endIndex) else { return nil }
        guard let right = index(left, offsetBy: range.upperBound - range.lowerBound, limitedBy: endIndex) else { return nil }
        return self[left..<right]
    }
}

extension Substring {
    
    fileprivate var string: String { return String(self) }
}

extension String {
    
    /// Checks if the string contains a match for the provided regular expression.
    ///
    /// - Parameter regex: The regular expression pattern to be checked.
    /// - Returns: Returns true if a match is found.
    public func contains(_ regex: String) -> Bool {
        (try? Lightregx(regex).match(in: self)) ?? false
    }
    
    /// Retrieves all whole matching results based on the provided regular expression.
    ///
    /// - Parameter regex: The regular expression pattern to be matched.
    /// - Returns: An array of matching results, each containing the matched string and its groups.
    public func wholeMatch(_ regex: String) -> [Lightregx.Match]? {
        try? Lightregx(regex).wholeMatch(in: self)
    }
    
    /// Retrieves the first matching result based on the provided regular expression.
    ///
    /// - Parameter regex: The regular expression pattern to be matched.
    /// - Returns: The first matching result, if found.
    public func firstMatch(_ regex: String) -> Lightregx.Match? {
        try? Lightregx(regex).firstMatch(in: self)
    }
    
    /// Replaces substrings that match the provided regular expression with the specified replacement string.
    ///
    /// - Parameters:
    ///   - regex: The regular expression pattern to be matched.
    ///   - replacement: The template string for replacements.
    /// - Returns: The modified string with replacements.
    public func replacing(_ regex: String, with replacement: String) -> String {
        let str = try? Lightregx(regex).replacing(in: self, with: replacement)
        return str ?? self
    }
    
    /// Replaces substrings that match the provided regular expression with the result of applying the provided closure.
    ///
    /// - Parameters:
    ///   - regex: The regular expression pattern to be matched.
    ///   - apply: A closure that takes a matched substring and returns a transformed string.
    /// - Returns: The modified string with applied transformations.
    public func replacing(_ regex: String, transform apply: (String) -> String?) -> String {
        let str = try? Lightregx(regex).replacing(in: self, transform: apply)
        return str ?? self
    }
}
