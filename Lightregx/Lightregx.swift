//
//  Lightregx.swift
//  Lightregx
//
//  Created by Wayne on 2018/6/26.
//  Copyright © 2018年 Wayne. All rights reserved.
//

import Foundation



/// The regular expression module in iOS is very powerful, but it is also very
/// difficult to use. If you want to implement a requirement, you may need to
/// write a lot of obscure code. So, this framework is the encapsulation of
/// `NSRegularExpression`. The intention is to simplify the actions when using
/// regular expressions for developers.
public struct Lightregx {
    
    /// The regular expression string.
    public let regx: String
    
    private let regexp: NSRegularExpression
    
    public init?(regx: String) {
        
        self.regx = regx
        let options: NSRegularExpression.Options = [.dotMatchesLineSeparators, .anchorsMatchLines]
        guard let exp = try? NSRegularExpression(pattern: regx, options: options) else {
            return nil
        }
        
        regexp = exp
    }
}

extension Lightregx: ExpressibleByStringLiteral {
    
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: StringLiteralType) {
        self.init(regx: value)!
    }
}

public extension Lightregx {
    
    public struct Result {
        
        let string: String
        let groups: [String]
        
        init(string: String, groups: [String] = []) {
            self.string = string
            self.groups = groups
        }
    }

    /// Checks if the regular expression matches a string.
    ///
    /// - Parameter string: A string to be matchd.
    /// - Returns: Return true if match a string.
    public func match(in string: String) -> Bool {
        
        let range = NSRange(location: 0, length: string.count)
        return !regexp.matches(in: string, options: [], range: range).isEmpty
    }
    
    /// Get all matching results. The result contains the matching string and
    /// the grouping information in the regular expression
    ///  For example:
    ///
    ///     let regx = Lightregx(regx: "(\\d{3})-(\\d{3,8})")!
    ///     let res = regx.fetchAll(in: "Tel: 010-12345 & 027-12345678")
    ///
    ///     print(res.map { $0.string })
    ///     /// Prints: ["010-12345", "027-12345678"]
    ///
    ///     print(res.map { $0.groups })
    ///     /// Prints: [["010", "12345"], ["027", "12345678"]]
    ///
    /// - Parameter string: A string to be matchd.
    /// - Returns: An Array type objcet.
    public func fetchAll(in string: String) -> [Result] {
        
        let range = NSRange(location: 0, length: string.count)
        return regexp.matches(in: string, options: [], range: range).map({ (result) -> Result in
            let matchText = string[Range(result.range)!]!.string
            let groups = (0..<result.numberOfRanges).reduce([], { (res, idx) -> [String] in
                if idx > 0 {
                    let text = string[Range(result.range(at: idx))!]!.string
                    return res + [text]
                }
                return res
            })
            
            return Result(string: matchText, groups: groups)
        })
    }
    
    /// Well, maby you just wanna get the first result. This method will help
    /// you.
    ///
    /// - Parameters:
    /// - Parameter string: A string to be matchd.
    /// - Returns: A Result type objcet.
    public func fetchOne(in string: String) -> Result? {
        
        let range = NSRange(location: 0, length: string.count)
        guard let result = regexp.firstMatch(in: string, options: [], range: range) else { return nil }
        let matchText = string[Range(result.range)!]!.string
        
        let groups = (0..<result.numberOfRanges).reduce([], { (res, idx) -> [String] in
            if idx > 0 {
                let text = string[Range(result.range(at: idx))!]!.string
                return res + [text]
            }
            return res
        })
        
        return Result(string: matchText, groups: groups)
    }
    
    
    /// This method replaces the matched substring with a template string.
    /// For example, I want to replace all the numbers in a string with `*`, and
    /// I can do this:
    ///
    ///     let text = "I bought this pair of shoes for $50 this afternoon at 3pm."
    ///     let regx = Lightregx(regx: "\\d")!
    ///     let res = regx.replace(in: text, using: "*")
    ///     print(res)
    ///     /// Prints: "I bought this pair of shoes for $** this afternoon at *pm."
    ///
    /// - Parameters:
    ///   - string: A string to be matchd.
    ///   - template: A template string.
    /// - Returns: New string.
    public func replace(in string: String, using template: String) -> String {
        
        let range = NSRange(location: 0, length: string.count)
        return regexp.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: template)
    }
    
    
    
    /// Sometimes we don't simply want to replace one substring with another. We
    /// may want to do some extra operations on the matched string, such as
    /// doubling the number in a string. Now you can do this thing simply:
    ///
    ///     let regx = Lightregx(regx: "\\d")!
    ///     let res = regx.replace(in: "A1B23C45D678E") { "\(Int($0)! * 2)" }
    ///     print(res)
    ///     /// Prints: "A2B46C810D121416E"
    ///
    ///     let regx = Lightregx(regx: "\\d+")!
    ///     let res = regx.replace(in: "A1B23C45D678E") { "\(Int($0)! * 2)" }
    ///     print(res)
    ///     /// Prints: "A2B46C90D1356E"
    ///
    /// - Parameters:
    ///   - string: string: A string to be matchd.
    ///   - apply: A method for transform string.
    /// - Returns: New string.
    public func replace(in string: String, apply: (String) -> String?) -> String {
        
        let range = NSRange(location: 0, length: string.count)
        return regexp.matches(in: string, options: .reportProgress, range: range).reversed().reduce(string, { (str, result) -> String in
            let range = Range.init(result.range, in: str)!
            var strCopy = str
            strCopy.replaceSubrange(range, with: apply(str[range].string) ?? "")
            return strCopy
        })
    }
}


fileprivate extension String {
    
    fileprivate subscript(range: Range<Int>) -> Substring? {
        guard let left = index(startIndex, offsetBy: range.lowerBound, limitedBy: endIndex) else { return nil }
        guard let right = index(left, offsetBy: range.upperBound - range.lowerBound, limitedBy: endIndex) else { return nil }
        return self[left..<right]
    }
}

fileprivate extension Substring {
    
    fileprivate var string: String { return String(self) }
}



public extension String {
    
    public func match(regx: String) -> Bool {
        return Lightregx(regx: regx)?.match(in: self) ?? false
    }
    
    public func fetchAll(regx: String) -> [String] {
        return Lightregx(regx: regx)?.fetchAll(in: self).map { $0.string } ?? []
    }
    
    public func fetchOne(regx: String) -> String? {
        return Lightregx(regx: regx)?.fetchOne(in: self)?.string
    }
    
    public func replace(regx: String, using template: String) -> String {
        return Lightregx(regx: regx)?.replace(in: self, using: template) ?? self
    }
    
    public func replace(regx: String, apply: (String) -> String?) -> String {
        return Lightregx(regx: regx)?.replace(in: self, apply: apply) ?? self
    }
}
