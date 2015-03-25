//
//  PartialFunctionTests.swift
//  Swift47Deg
//
//  Created by Javier de Silóniz Sandino on 25/3/15.
//  Copyright (c) 2015 47 Degrees. All rights reserved.
//

import UIKit
import XCTest
import Swiftz

class PartialFunctionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPartialFunctions() {
        let doubleEvens = PartialFunction<Int, Int>(function: Function.arr({ $0 * 2 }), isDefinedAt: Function.arr({ $0 % 2 == 0 }))
        let tripleOdds = PartialFunction<Int, Int>(function: Function.arr({ $0 * 3 }), isDefinedAt: Function.arr({ $0 % 2 != 0 }))
        
        let whatToDo = doubleEvens ||-> tripleOdds
        
        XCTAssertEqual(whatToDo.apply(3), 9, "Partial functions should be attachable with orElse conditionals")
        XCTAssertEqual(whatToDo.apply(4), 8, "Partial functions should be attachable with orElse conditionals")
    }
}