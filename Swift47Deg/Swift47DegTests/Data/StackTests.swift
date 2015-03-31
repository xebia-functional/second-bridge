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

import Foundation
import XCTest

class StackTTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testStackT() {
        var stack = Stack<Int>()
        stack = stack.push(1)
        stack = stack.push(2)
        stack = stack.push(3)
        
        XCTAssertNotNil(stack.top(), "Stacks should have a top when containing items")
        XCTAssertEqual(stack.top()!, 3, "Stacks should be LIFO")
        
        stack = stack.pop().stack
        XCTAssertEqual(stack.top()!, 2, "Stacks should be able to be popped out")
        
        stack = stack.pop().stack
        stack = stack.pop().stack
        
        XCTAssertEqual(stack.size(), 0, "Stacks should know when they're empty")
        XCTAssertNil(stack.pop().item, "When empty, stacks should not be poppable")
    }
}
