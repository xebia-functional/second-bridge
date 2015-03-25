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


class ListTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testListEqual() {
        
        let a = List(1,2,3)
        let b = List(1,2,3)
        XCTAssert({a == b}(), "Should be identical lists of int")
        
        let c = List("1","2","3")
        let d =  List("1","2","3")
        XCTAssert({c == d}(), "Should be identical lists of string")
        
    }
    
    
    func testListEqualDiferentTypes() {
        
        let a : List<String> = []
        let b : List<Int> = []
        XCTAssert({a == b}(), "Should be identical")
        
        let c : List<String> = ["1"]
        let d : List<Int> = []
        XCTAssertFalse({c == d}(), "Shouldn't be identical, but different types")
        
        let e : List<String> = ["1"]
        let f : List<Int> = [1]
        XCTAssertFalse({c == d}(), "Shouldn't be identical, but different types")
        
    }
    
    func testAccessed(){
        
        let a = List(1,2,3)
        
        //Head
        XCTAssert({a.head() == 1}(), "Should be 1 head")
        
        //Tail
        if let t = a.tail(){
            XCTAssert({t == List(2,3)}(), "Should be List(2,3) tail")
        }
        
        let b = List("1","2","3")
        XCTAssert({b.head() == "1"}(), "Should be \"1\" head")
        
        //Tail
        if let tailString = b.tail(){
            XCTAssert({tailString == List("2","3")}(), "Should be \"List(2,3)\" tail")
        }
        
    }
    
    func testMethods(){
        
        let a = List(1,2,3)
        let b = List ("1","2","3")
        
        //Lenght
        XCTAssert({a.length() == 3}(), "List should have all elements type int")
        XCTAssert({b.length() == 3}(), "List should have all elements type string")
        
        //Reverse
        XCTAssert({a.reverse() == List(3,2,1)}(),"Applied reverse, should be List(3,2,1)")
        XCTAssert({b.reverse() == List("3","2","1")}(),"Applied reverse, should be \"List(\"3\",\"2\",\"1\")\"")
        
        //Description
        XCTAssert({a.description == "[1, 2, 3]"}(),"Description should be \"[1, 2, 3]\"")
        XCTAssert({b.description == "[1, 2, 3]"}(),"Description should be \"[1, 2, 3]\"")
        
        //Map
        XCTAssert({ a.map({$0 * 2}) == List(2,4,6)}(), "Applied reverse with type Int, should be List(2,4,6)")
        XCTAssert({ b.map({$0 + "2"}) == List("12","22","32")}(), "Applied reverse with type String, should be List(12,22,23)")
        
        //Filter
        XCTAssert({ a.filter({$0 % 2 != 0}) == List(1,3)}(), "Applied filter with type Int, should be List(1,3)")
        XCTAssert({ b.filter({$0 != "2"}) == List("1","3")}(), "Applied filter with type string, should be List(1,3)")
        
    }
    
    
    func testReduce(){
        
        let a = List(1,3,5,7)
        XCTAssert({a.reduce(+) == 16 }(),"Should be 16")
        
        let b = List("1","3","5","7")
        XCTAssert({b.reduce(+) == "1357" }(),"Should be 1357")
        
    }
    
    func testReduceWithInitial(){
        
        let a = List(1,3,5,7)
        let result = a.reduce({(total, number) in (total + number)}, initial: 0)
        XCTAssert({result == 16 }(),"Should be 16, reduce with initial")
        
        let result2 = a.reduce({(total, number) in (total + number)}, initial: 20)
        XCTAssert({result2 == 36 }(),"Should be 16, reduce with initial")
        
        let b = List("1","3","5","7")
        let result3 = b.reduce({(total, number) in (total + number)}, initial: "")
        XCTAssert({result3 == "1357" }(),"Should be 1357")
        
        let result4 = b.reduce({(total, number) in (total + number)}, initial: "Test")
        XCTAssert({result4 == "Test1357" }(),"Should be Test1357")
        
    }
    
    
    func testReduceRigth(){
        
        let a = List(1, 3, 5, 7)
        XCTAssert({a.reduceRight(+) == 16 }(),"Applied reduceRight with type int, should be 16")
        
        let b = List("1","3","5","7")
        XCTAssert({b.reduceRight(+) == "7531" }(),"Applied reduceRight with type string, should be 7531")
        
    }
    
    func testReduceRigthInitial(){
        
        let a = List(1, 3, 5, 7)
        let result = a.reduceRight(+, initial: 0)
        XCTAssert({result == 16 }(),"Applied reduceRight with initial the type int, should be 16")
        
        let result2 = a.reduceRight(+, initial: 20)
        XCTAssert({result2 == 36 }(),"Applied reduceRight with initial the type int, should be 36")
        
        let b = List("1","3","5","7")
        let result3 = b.reduceRight(+, initial: "")
        XCTAssert({result3 == "7531" }(),"Applied reduceRight with initial the type string, Should be 7531")
        
        let result4 = b.reduceRight(+, initial: "Test")
        XCTAssert({result4 == "Test7531" }(),"Applied reduceRight with initial the type string, Should be Test7531")
        
    }
    
    
    func testFold(){
        
        let a = List(1,3,5,7)
        let result = a.fold(+, initial: 0)
        XCTAssert({result == 16 }(),"Applied fold, should be 16")
        XCTAssert({a.fold(+, initial: 10) == 26 }(),"Applied fold, should be 26")
        
        let b = List("1","3","5","7")
        let result1 = b.fold(+, initial: "")
        XCTAssert({result1 == "1357" }(),"Applied fold, should be 1357")
        XCTAssert({b.fold(+, initial: "Test") == "Test1357" }(),"Applied fold, should be Test1357")
        
    }
    
    func testFoldRight(){
        
        let a = List(1,3,5,7)
        let result = a.foldRight(+, initial: 0)
        XCTAssert({result == 16 }(),"Applied fold, should be 16")
        XCTAssert({a.foldRight(+, initial: 10) == 26 }(),"Applied fold, should be 26")
        
        let b = List("1","3","5","7")
        let result1 = b.foldRight(+, initial: "")
        XCTAssert({result1 == "7531" }(),"Applied fold, should be 7531")
        XCTAssert({b.foldRight(+, initial: "Test") == "Test7531" }(),"Applied fold, should be Test7531")
        
    }
    
}