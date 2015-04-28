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

class VectorTraversability: XCTestCase {
    
    var arraySmall = Array<Int>()
    var arrayBig = Array<Int>()
    
    override func setUp() {
        super.setUp()
        
        for i in 0..<64 {
            arraySmall.append(i)
        }
        
        for i in 0..<(32768 + 32) {
            arrayBig.append(i)
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testTraversability() {
        let vectorFromArraySmall = Vector<Int>.build(arraySmall)
        let vectorFromArrayBig = Vector<Int>.build(arrayBig)
        XCTAssertEqual(vectorFromArraySmall.count, arraySmall.count, "Traversability should allow to create vectors from arrays")
        XCTAssertEqual(vectorFromArraySmall[10], arraySmall[10], "Traversability should allow to create vectors from arrays")
        XCTAssertEqual(vectorFromArrayBig.count, arrayBig.count, "Traversability should allow to create vectors from arrays")
        XCTAssertEqual(vectorFromArrayBig[1000], arrayBig[1000], "Traversability should allow to create vectors from arrays")
    }
}
