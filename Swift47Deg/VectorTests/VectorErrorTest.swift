//
//  VectorErrorTest.swift
//  Swift47Deg
//
//  Created by Javier de Silóniz Sandino on 29/4/15.
//  Copyright (c) 2015 47 Degrees. All rights reserved.
//

import UIKit
import XCTest

class VectorErrorTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        let vector = Vector<Int>(array: [Int](0..<65))
        
        
        for (index, value) in enumerate(vector) {
            println("value: \(value)")
            XCTAssertTrue(vector[index] == value, "Vectors should be enumerable")
        }
        println("lel")
    }

}
