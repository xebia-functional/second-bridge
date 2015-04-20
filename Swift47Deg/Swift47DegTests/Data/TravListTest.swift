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


class TravListTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testListTravBasicFunctions() {
        
        var list : TravList<Int> = []
        XCTAssertTrue(list.isEmpty(), "List should know if they're empty")
        XCTAssertTrue(travIsEmpty(list), "List should know if they're empty")
        
        var anotherList : TravList<Int> = [1,2,3,4]
        XCTAssertTrue(anotherList.head() == 1, "Should be 1 head")
        XCTAssertTrue(travHead(anotherList) == 1, "Should be 1 head")
        
        let tailList : TravList<Int> = [2,3,4]
        XCTAssertTrue(anotherList.tail() == tailList, "")
        XCTAssertTrue(travTail(anotherList) == tailList, "")
        
        
    }

    func testAccessed() {

        let a: TravList<Int> = [1, 2, 3]
        let b: TravList<Int> = [2, 3]

        //Head
        XCTAssert({travHead(a) == 1}(), "Should be 1 head")

        //Tail
        XCTAssertEqual(travTail(a), b, "Equatable")

    }


}