//
//  VectorTests.swift
//  Swift47Deg
//
//  Created by Javier de Silóniz Sandino on 23/4/15.
//  Copyright (c) 2015 47 Degrees. All rights reserved.
//

import UIKit
import XCTest

class VectorTests: XCTestCase {

    var vectorMillion : Vector<Int> = Vector()
    
    override func setUp() {
        super.setUp()
    
        for i in 0...1000 {
            vectorMillion = vectorMillion.append(i)
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
//        var vector = Vector<Int>()
//        vector = vector.append(1)
//        println("Vector: \(vector)")
//        println("Vector[0]: \(vector[0])")
    }
    
    func testMillion() {
        XCTAssertTrue(vectorMillion.count == 1000, "Vector should be able to hold lots of info")
        println("Vector [0]: \(vectorMillion[0])")
        println("Vector [0]: \(vectorMillion[10])")
        println("Vector [0]: \(vectorMillion[100])")
        println("Vector [0]: \(vectorMillion[999])")
    }
}
