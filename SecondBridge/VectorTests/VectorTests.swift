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

class VectorTests: XCTestCase {

    var vectorLevelZero : Vector<Int> = Vector()
    var vectorLevelOneMin : Vector<Int> = Vector()
    var vectorLevelOneMax : Vector<Int> = Vector()
    var vectorLevelTwoMin : Vector<Int> = Vector()
    var vectorLevelTwoMax : Vector<Int> = Vector()
    var vectorLevelThreeMin : Vector<Int> = Vector()
    var vectorLevelThreeMax : Vector<Int> = Vector()
    var vectorLevelFourMin : Vector<Int> = Vector()
    var vectorLevelFourMax : Vector<Int> = Vector()
    var vectorLevelFiveMin : Vector<Int> = Vector()
    var vectorLevelFiveMax : Vector<Int> = Vector()
    var vectorLevelSixMin : Vector<Int> = Vector()
    var vectorLevelSixMax : Vector<Int> = Vector()
    
    override func setUp() {
        super.setUp()
    
        for i in 0..<32 {
            vectorLevelZero = vectorLevelZero.append(i)
        }
        
        for i in 0...32 {
            vectorLevelOneMin = vectorLevelOneMin.append(i)
        }
        
        for i in 0..<64 {
            vectorLevelOneMax = vectorLevelOneMax.append(i)
        }
        
        for i in 0...64 {
            vectorLevelTwoMin = vectorLevelTwoMin.append(i)
        }
        
        for i in 0..<(1024 + 32) {
            vectorLevelTwoMax = vectorLevelTwoMax.append(i)
        }
        
        for i in 0...(1024 + 32) {
            vectorLevelThreeMin = vectorLevelThreeMin.append(i)
        }
        
        for i in 0..<(32768 + 32) {
            vectorLevelThreeMax = vectorLevelThreeMax.append(i)
        }
        
        for i in 0...(32768 + 32) {
            vectorLevelFourMin = vectorLevelFourMin.append(i)
        }
        
        for i in 0..<(1048576 + 32) {
            vectorLevelFourMax = vectorLevelFourMax.append(i)
        }
        
        // This tests take a lot to get completed, commented for sanity unless necessary:
        
//
//        for i in 0...(1048576 + 32) {
//            vectorLevelFiveMin = vectorLevelFiveMin.append(i)
//        }
//        
//        for i in 0..<(33554432 + 32) {
//            vectorLevelFiveMax = vectorLevelFiveMax.append(i)
//        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLevels() {
        XCTAssertTrue(vectorLevelZero.debugTrieLevel == .Zero, "Vectors should handle its trie levels OK")
        XCTAssertTrue(vectorLevelOneMin.debugTrieLevel == .One, "Vectors should handle its trie levels OK")
        XCTAssertTrue(vectorLevelOneMax.debugTrieLevel == .One, "Vectors should handle its trie levels OK")
        
        let vectorLevelOneToZero = vectorLevelOneMin.pop()
        let vectorLevelOneToTwo = vectorLevelOneMax.append(666)
        XCTAssertTrue(vectorLevelOneToZero.debugTrieLevel == .Zero, "Vectors should handle its trie levels OK")
        XCTAssertTrue(vectorLevelOneToTwo.debugTrieLevel == .Two, "Vectors should handle its trie levels OK")
        
        XCTAssertTrue(vectorLevelTwoMin.debugTrieLevel == .Two, "Vectors should handle its trie levels OK")
        XCTAssertTrue(vectorLevelTwoMax.debugTrieLevel == .Two, "Vectors should handle its trie levels OK")
        
        let vectorLevelTwoToOne = vectorLevelTwoMin.pop()
        let vectorLevelTwoToThree = vectorLevelTwoMax.append(666)
        XCTAssertTrue(vectorLevelTwoToOne.debugTrieLevel == .One, "Vectors should handle its trie levels OK")
        XCTAssertTrue(vectorLevelTwoToThree.debugTrieLevel == .Three, "Vectors should handle its trie levels OK")
        
        XCTAssertTrue(vectorLevelThreeMin.debugTrieLevel == .Three, "Vectors should handle its trie levels OK")
        XCTAssertTrue(vectorLevelThreeMax.debugTrieLevel == .Three, "Vectors should handle its trie levels OK")
        
        let vectorLevelThreeToTwo = vectorLevelThreeMin.pop()
        let vectorLevelThreeToFour = vectorLevelThreeMax.append(666)
        XCTAssertTrue(vectorLevelThreeToTwo.debugTrieLevel == .Two, "Vectors should handle its trie levels OK")
        XCTAssertTrue(vectorLevelThreeToFour.debugTrieLevel == .Four, "Vectors should handle its trie levels OK")
        
        XCTAssertTrue(vectorLevelFourMin.debugTrieLevel == .Four, "Vectors should handle its trie levels OK")
        XCTAssertTrue(vectorLevelFourMax.debugTrieLevel == .Four, "Vectors should handle its trie levels OK")
        
        let vectorLevelFourToThree = vectorLevelFourMin.pop()
        let vectorLevelFourToFive = vectorLevelFourMax.append(666)
        XCTAssertTrue(vectorLevelFourToThree.debugTrieLevel == .Three, "Vectors should handle its trie levels OK")
        XCTAssertTrue(vectorLevelFourToFive.debugTrieLevel == .Five, "Vectors should handle its trie levels OK")
        

        // This tests take a lot to get completed, commented for sanity unless necessary:
        
//        XCTAssertTrue(vectorLevelFiveMin.debugTrieLevel == .Five, "Vectors should handle its trie levels OK")
//        XCTAssertTrue(vectorLevelFiveMax.debugTrieLevel == .Five, "Vectors should handle its trie levels OK")
//        
//        var vectorLevelFiveToSix = vectorLevelFiveMin.pop()
//        var vectorLevelFiveToFour = vectorLevelFiveMax.append(666)
//        XCTAssertTrue(vectorLevelFiveToSix.debugTrieLevel == .Six, "Vectors should handle its trie levels OK")
//        XCTAssertTrue(vectorLevelFiveToFour.debugTrieLevel == .Four, "Vectors should handle its trie levels OK")
    }
}
