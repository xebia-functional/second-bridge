//
//  MapTests.swift
//  Swift47Deg
//
//  Created by Javier de Silóniz Sandino on 5/3/15.
//  Copyright (c) 2015 47 Degrees. All rights reserved.
//

import UIKit
import XCTest

class MapTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMapCreation() {
        let map = ["a" : 1, 2 : 2, 3 : "c", 4.5 : 4.5]
        XCTAssertEqual(map.count, 4, "Map should have all elements added")
        XCTAssertNotNil(map["a"], "Map elements with String keys should be added")
        XCTAssertNotNil(map[2], "Map elements with Int keys should be added")
        XCTAssertNotNil(map[4.5], "Map elements with Double keys should be added")
        XCTAssertEqual(map["a"]!, 1, "Map elements with String keys should be added")
        XCTAssertEqual(map[3]!, "c", "Map elements with Int keys should be added")
        XCTAssertEqual(map[4.5]!, 4.5, "Map elements with Double keys should be added")
    }
}


