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


class ListTTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testListTravBasicFunctions() {
        
        var listEmpty : ListT<Int> = []
        XCTAssertTrue(listEmpty.isEmpty(), "List should know if they're empty")
        
        var list : ListT<Int> = [1,2,3,4]
        XCTAssertTrue(list.head() == 1, "Should be 1 head")
        
        let tailList : ListT<Int> = [2,3,4]
        XCTAssertTrue(list.tail() == tailList, "")
        
        XCTAssert(listEmpty.size() == 0, "List should know if they're empty")
        XCTAssert(list.size() == 4, "")
        XCTAssert(list.length() == 4, "")
    
        //Reverse
        let reverseList : ListT<Int> = [4,3,2,1]
        XCTAssert({list.reverse() == reverseList }(),"Applied reverse, should be ListT(4,3,2,1)")
        

        //Description
        XCTAssert({list.mkString() == "1234"}(),"Description should be 1234")
        
        //Map
        let mapList : ListT<Int> = [2, 4, 6, 8]
        println(list.map({$0 * 2}))
//        XCTAssert({ list.map({$0 * 2} == mapList) }(),"")
        
        //Filter
        let filterList : ListT<Int> = [1, 3]
        XCTAssert({ list.filter({$0 % 2 != 0}) == filterList}(), "Applied filter with type Int, should be List(1,3)")
        
    }
    
    
    func testReduce(){
        
        let a : ListT <Int> = [1,3,5,7]
        XCTAssert({a.reduce(+) == 16 }(),"Should be 16")
        
        let b : ListT <String> = ["1","3","5","7"]
        XCTAssert({b.reduce(+) == "1357" }(),"Should be 1357")
        
    }
    
    func testReduceRight(){
        
        let a : ListT <Int> = [1,3,5,7]
        XCTAssert({a.reduceRight(+) == 16 }(),"Applied reduceRight with type int, should be 16")
        
        let b : ListT <String> = ["1","3","5","7"]
        XCTAssert({b.reduceRight(+) == "7531" }(),"Applied reduceRight with type string, should be 7531")
        
    }
    
    func testFold(){
        
        let a : ListT <Int> = [1,3,5,7]
        let result = a.fold(+, initial: 0)
        XCTAssert({result == 16 }(),"Applied fold, should be 16")
        XCTAssert({a.fold(+, initial: 10) == 26 }(),"Applied fold, should be 26")
        
        let b : ListT <String> = ["1","3","5","7"]
        let result1 = b.fold(+, initial: "")
        XCTAssert({result1 == "1357" }(),"Applied fold, should be 1357")
        XCTAssert({b.fold(+, initial: "Test") == "Test1357" }(),"Applied fold, should be Test1357")
        
    }
    
    func testFoldRight(){
        
        let a : ListT <Int> = [1,3,5,7]
        let result = a.foldRight(+, initial: 0)
        XCTAssert({result == 16 }(),"Applied fold, should be 16")
        XCTAssert({a.foldRight(+, initial: 10) == 26 }(),"Applied fold, should be 26")
        
        let b : ListT <String> = ["1","3","5","7"]
        let result1 = b.foldRight(+, initial: "")
        XCTAssert({result1 == "7531" }(),"Applied fold, should be 7531")
        XCTAssert({b.foldRight(+, initial: "Test") == "Test7531" }(),"Applied fold, should be Test7531")
        
    }
    

}