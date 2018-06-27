//
//  LightregxTests.swift
//  LightregxTests
//
//  Created by Wayne on 2018/6/26.
//  Copyright © 2018年 Wayne. All rights reserved.
//

import XCTest
@testable import Lightregx

class LightregxTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        XCTAssertEqual(Lightregx(regx: "^1[3|4|5|6|7|8][0-9]\\d{4,8}$")!.match(in: "17012345678"), true)

        XCTAssertEqual(Lightregx(regx: "\\d")!.replace(in: "abc12ded7t8asdf45gsg", apply: { (str) -> String in
            return "\((Int(str) ?? 0) * 2)"
        }), "abc24ded14t16asdf810gsg")
        
        XCTAssertEqual(Lightregx(regx: "\\d+")!.replace(in: "abc12ded7t8asdf45gsg", apply: { (str) -> String in
            return "\((Int(str) ?? 0) * 2)"
        }), "abc24ded14t16asdf90gsg")
        
        
        let regx: Lightregx = "(\\d{3})-(\\d{3,8})"
        let res = regx.fetchAll(in: "Tel: 010-12345 & 027-12345678")
        XCTAssertEqual(res.map { $0.groups }, [["010", "12345"], ["027", "12345678"]])
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
