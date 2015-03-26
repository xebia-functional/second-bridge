/*
* Copyright (C) 2015 47 Degrees, LLC http://47deg.com hello@47deg.com
*
* Licensed under the Apache License, Version 2.0 (the "License"); you may
* not use this file except in compliance with the License. You may obtain
* a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

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
        let doubleEvens = =>{ $0 % 2 == 0 } |-> =>{ $0 * 2 }
        let tripleOdds = =>{ $0 % 2 != 0 } |-> =>({ $0 * 3 })
        let addFive = =>(+5)
        
        let opOrElseOp = doubleEvens |||> tripleOdds
        let opOrElseAndThenOp = doubleEvens |||> tripleOdds >>> addFive
        
        XCTAssertEqual(opOrElseOp.apply(3), 9, "Partial functions should be attachable with orElse conditionals")
        XCTAssertEqual(opOrElseOp.apply(4), 8, "Partial functions should be attachable with orElse conditionals")
        
        XCTAssertEqual(opOrElseAndThenOp.apply(3), 14, "Partial functions should be attachable with orElse and andThen conditionals")
        XCTAssertEqual(opOrElseAndThenOp.apply(4), 13, "Partial functions should be attachable with orElse and andThen conditionals")
        
        let printEven = =>({ (value : Int) -> Bool in value % 2 == 0}) |-> =>({ (Int) -> String in return "Even"})
        let printOdd = =>({ (value : Int) -> Bool in value % 2 != 0}) |-> =>({ (Int) -> String in return "Odd"})
        
        let complexOp = doubleEvens |||> tripleOdds >>> (printEven |||> printOdd)
        XCTAssertEqual(complexOp.apply(3), "Odd", "Partial functions should be attachable with orElse and andThen conditionals")
        XCTAssertEqual(complexOp.apply(4), "Even", "Partial functions should be attachable with orElse and andThen conditionals")
    }
    
    func testCollect() {
        let map : Map<Double> = ["a" : -1, "b" : 0, "c" : 1, "d" : 2, "e" : 3, "f" : 4]
        // Sometimes type inference won't work while creating arrows with complex types using the => operator, so we need to be explicit:
        let squareRoot = =>({ $0.1 >= 0 }) |-> Function<(HashableAny, Double), (HashableAny, Double)>.arr({ ($0.0, sqrt(Double($0.1))) })
        let collectResult = map.collect(squareRoot)
        
        XCTAssertNil(collectResult["a"], "Collect function should obbey to its partial function's restrictions")
        XCTAssertEqual(collectResult["b"]!, 0, "Collect function should execute its function to all allowed members of the Traversable")
        XCTAssertEqual(collectResult["f"]! * collectResult["f"]!, map["f"]!, "Collect function should execute its function to all allowed members of the Traversable")
    }
}