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

class BinarySearchTreeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBSTCreation() {
        
        let tree = BinarySearchTree.Node(2, left: BinarySearchTree.Empty, right: BinarySearchTree.Empty)
        XCTAssertNotNil(tree.getHead(), "")
        
        let tree2 = tree.add(4).add(8).add(5).add(1).add(3).add(7).add(10)
        XCTAssertEqual(tree2.count(), 8, "Tree should have all elements added")
        
        let tree3 = tree.add(4).add(8).add(5).add(1).add(3).add(7).add(10)
        XCTAssertEqual(tree3.count(), tree2.count(), "Tree3 and Tree2 should have all elements added")
        
        let tree4 = tree3.remove(8)
        XCTAssertEqual(tree4?.count(), tree3.count()-1, "Tree4 shoulh have one less element")
        
        let tree5 = tree.add(4).add(8)
        let tree6 = tree.add(4).add(8)
        XCTAssertTrue(tree5 == tree6, "Trees should be equal")
        
        let tree7 = tree.add(4).add(8).add(5).add(1).add(3).add(7)
         XCTAssertTrue(tree7.search(8) == true, "Trees should contains value 8")
         XCTAssertTrue(tree7.search(10) == false, "Trees should contains value 8")
    }


}
