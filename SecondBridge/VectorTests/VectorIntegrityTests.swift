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

import XCTest

class VectorIntegrityTests: XCTestCase {

    var extraBigVector = Vector<Int>()
    
    override func setUp() {
        super.setUp()
    }

    func testIntegrity() {
        // Like in the Vector's level tests, the highest value for the integrity tests is commented out for sanity.
        // You can play with the different Thresh values (i.e.: 32 << 5, 32 << 10, 32 << 15, 32 << 20 or 32 << 25),
        // but the latest two will take hours to complete!
        // let dataSize = 32 << 25
        let dataSize = 32 << 10

        for i in 0..<dataSize {
            extraBigVector = extraBigVector.append(i)
            print("Integrity Test \((Float(i) / Float(dataSize)) * 100)%")
            XCTAssert(extraBigVector[i] == i, "There are inconsistencies in Vector internal data")
        }
    }
}
