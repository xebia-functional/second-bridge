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

class IterableTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testUtils() {
        let array : TravArray<Int> = [0, 1, 2, 3, 4, 5, 6]
        let groupedResult = grouped(array, 3)
        XCTAssertTrue(groupedResult[0].size() == 3, "Grouped should create an array with groups of n elements")
        XCTAssertTrue(groupedResult.count == 3, "Grouped should create an array with groups of n elements")
        XCTAssertTrue(groupedResult[2].size() == 1, "Grouped should create an array with groups of n elements, except for final elements that should be < n")
        
        let slideResult1 = sliding(array, 3, 1)
        let slideResult2 = sliding(array, 3, 2)
        let slideResult3 = sliding(array, 3, 3)
        let slideResult4 = sliding(array, 3, 4)
        let slideResult5 = sliding(array, 3, 5)
        
        XCTAssertTrue(slideResult1.count == 5, "Sliding should create an array with groups of n elements separated by window-size distance")
        XCTAssertTrue(slideResult2.count == 3, "Sliding should create an array with groups of n elements separated by window-size distance")
        XCTAssertTrue(slideResult5.count == 2, "Sliding should create an array with groups of n elements separated by window-size distance")
        XCTAssertTrue(travSize(slideResult1[0]) == 3, "Sliding should always return groups of elements of size n (except for the last group)")
        XCTAssertTrue(travSize(slideResult1[1]) == 3, "Sliding should always return groups of elements of size n (except for the last group)")
        XCTAssertTrue(travSize(slideResult2[0]) == 3, "Sliding should always return groups of elements of size n (except for the last group)")
        XCTAssertTrue(travSize(slideResult5[0]) == 3, "Sliding should always return groups of elements of size n (except for the last group)")
        XCTAssertTrue(travHead(travDrop(slideResult1.last!, 2)) == 6, "Sliding should create an array with groups of n elements separated by window-size distance")
        
        let arrayOfLetters : TravArray<String> = ["a", "b", "c"]
        let zipResult = zip(array, arrayOfLetters)
        let zipResultFiller1 = zipAll(array, arrayOfLetters, 0, "foo")
        let zipResultFiller2 = zipAll(arrayOfLetters, array, "foo", 0)
        let zipWithIndexResult = zipWithIndex(arrayOfLetters)
        
        XCTAssertTrue(zipResult.count == 3, "Regular zip should return an array with the same size as the smaller Iterable")
        XCTAssertTrue(zipResultFiller1.count == 7, "ZipForAll should return an array with the same size as the bigger Iterable")
        XCTAssertTrue(zipResultFiller1.last!.1 == "foo", "ZipForAll should fill the gaps of the smaller Iterable with the provided default value")
        XCTAssertTrue(zipResultFiller1.last!.0 == 6, "ZipForAll should fill the gaps of the smaller Iterable with the provided default value while keeping the bigger Iterable's values")
        XCTAssertTrue(zipWithIndexResult.last!.1 == 2, "ZipWithIndex should mix items of an Iterable with their corresponding indices")
        XCTAssertTrue(zipWithIndexResult.count == 3, "ZipWithIndex should mix items of an Iterable with their corresponding indices")
        
        XCTAssertTrue(sameElements(array, array), "Iterables should know if they have the same elements in the same order.")
        XCTAssertFalse(sameElements(array, TravArray<Int>([0, 1, 2, 3, 4, 6, 5])), "Iterables should know if they have the same elements in the same order.")
        XCTAssertFalse(sameElements(array, TravArray<Int>([0, 1, 2, 3, 4, 5])), "Iterables should know if they have the same elements in the same order.")
    }
}
