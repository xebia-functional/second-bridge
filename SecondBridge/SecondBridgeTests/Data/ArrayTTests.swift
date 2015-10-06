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

class ArrayTTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExtraFunctions() {
        let anArray : ArrayT<Int> = [1, 2, 3, 4, 5, 6]
        let list = anArray.toList()
        
        XCTAssertEqual(sizeT(list), anArray.size(), "Traversable's toList should generate a List with the same number of elements as the source")
        XCTAssertEqual(list[0]!, anArray[0]!, "Traversable's toList should store all the elements of the source")
        
        XCTAssertFalse(anArray.isEmpty(), "Traversable's isEmpty should know if an instance has no elements")
        XCTAssertTrue(anArray.nonEmpty(), "Traversable's nonEmpty should know if an instance has no elements")
        
        XCTAssertEqual(anArray.size(), 6, "Traversables should know to count their elements")
        
        let findNotNil = anArray.find({$0 > 3})
        let findNil = anArray.find({$0 < 0})
        XCTAssertTrue(findNotNil != nil, "Traversables should be able to find elements based on a predicate")
        XCTAssertTrue(findNil == nil, "Traversables should be able to find elements based on a predicate")
        
        let dropResult = anArray.drop(4)
        XCTAssertEqual(dropResult.size(), anArray.size() - 4, "Traversables should be droppable")
        XCTAssertFalse(findT(dropResult, p: { (item: Int) -> Bool in item == 1 }) != nil, "Traversables should be droppable")
        XCTAssertTrue(findT(dropResult, p: { (item: Int) -> Bool in item == 5 }) != nil, "Traversables should be droppable")
        
        let dropRightResult = anArray.dropRight(4)
        XCTAssertFalse(findT(dropRightResult, p: { (item: Int) -> Bool in item == 5 }) != nil, "Traversables should be droppable")
        XCTAssertTrue(findT(dropRightResult, p: { (item: Int) -> Bool in item == 1 }) != nil, "Traversables should be droppable")
        
        let takeResult = anArray.take(2)
        let takeRightResult = anArray.takeRight(2)
        XCTAssertFalse(findT(takeResult, p: { (item: Int) -> Bool in item == 5 }) != nil, "Traversables should be takeable")
        XCTAssertTrue(findT(takeResult, p: { (item: Int) -> Bool in item == 1 }) != nil, "Traversables should be takeable")
        
        XCTAssertTrue(findT(takeRightResult, p: { (item: Int) -> Bool in item == 5 }) != nil, "Traversables should be takeable")
        XCTAssertFalse(findT(takeRightResult, p: { (item: Int) -> Bool in item == 1 }) != nil, "Traversables should be takeable")
        
        let dropWhileResult = anArray.dropWhile() { (item: Int) -> Bool in
            item != 3
        }
        XCTAssertEqual(dropWhileResult[0]!, 3, "Traversables should be droppable with while closure")
        
        let takeWhileResult = anArray.takeWhile() { (item: Int) -> Bool in
            item < 4
        }
        XCTAssertEqual(takeWhileResult.size(), 3, "Traversables should be takeable with while closure")
        XCTAssertEqual(takeWhileResult[0]!, 1, "Traversables should be takeable with while closure")
        XCTAssertEqual(takeWhileResult.last()!, 3, "Traversables should be takeable with while closure")
        
        let headResult = anArray.head()
        XCTAssertTrue(headResult != nil, "Traversables should know where their head is")
        XCTAssertTrue(headResult! == anArray[0]!, "Traversables should know where their head is")
        
        let tailResult = anArray.tail()
        XCTAssertTrue(tailResult.size() == anArray.size() - 1, "Traversables should know where their tail is")
        XCTAssertTrue(tailResult[0]! == anArray[1]!, "Traversables should know where their tail is")
        
        let initResult = anArray.initSegment()
        XCTAssertTrue(initResult.size() == anArray.size() - 1, "Traversables should know where their init segment is")
        XCTAssertTrue(initResult.last()! == 5, "Traversables should know where their init segment is")
        
        let lastResult = anArray.last()
        XCTAssertTrue(lastResult != nil, "Traversables should know their last element")
        XCTAssertTrue(lastResult! == 6, "Traversables should know their last element")
        
        let filterNotResult = anArray.filterNot({ $0 == 1 })
        XCTAssertTrue(filterNotResult.size() == anArray.size() - 1, "Traversables should be filtered with inverted conditions")
        XCTAssertTrue(filterNotResult.head()! == 2, "Traversables should be filtered with inverted conditions")
        
        let splitAtResult = anArray.splitAt(2)
        XCTAssertTrue(splitAtResult.0.size() == 2, "Traversables should be splittable")
        XCTAssertTrue(splitAtResult.1.size() == 4, "Traversables should be splittable")
        
        let partitionResult = anArray.partition({ $0 == 1 })
        XCTAssertTrue(partitionResult.0.size() == 1, "Traversables should be partitionable")
        XCTAssertTrue(partitionResult.1.size() == 5, "Traversables should be partitionable")
        
        let spanResult = anArray.span({ $0 <= 2 })
        
        XCTAssertTrue(spanResult.0.size() == 2, "Traversables should be spanable")
        XCTAssertTrue(spanResult.1.size() == 4, "Traversables should be spanable")
        
        let groupByResult = anArray.groupBy(∫{(item: Int) -> HashableAny in
            if item % 2 == 0 {
                return "Evens"
            } else {
                return "Odds"
            }
            })
        XCTAssertTrue(groupByResult["Odds"]!.size() == 3, "Traversable should be groupable by using functions")
        XCTAssertTrue(groupByResult["Evens"]!.size() == 3, "Traversable should be groupable by using functions")
        XCTAssertTrue(groupByResult["Odds"]![0]! % 2 > 0, "Traversable should be groupable by using functions")
        XCTAssertTrue(groupByResult["Evens"]![0]! % 2 == 0, "Traversable should be groupable by using functions")
        
        let forAllResult = anArray.forAll({ (item) -> Bool in item > 0 })
        let forAllFalseResult = anArray.forAll({ (item) -> Bool in item > 3 })
        XCTAssertTrue(forAllResult, "Traversables should be certain if all their elements satisfy a given predicate")
        XCTAssertFalse(forAllFalseResult, "Traversables should be certain if all their elements satisfy a given predicate")
        
        let existsResult = anArray.exists({ (item) -> Bool in item == 5 })
        let existsFalseResult = anArray.exists({ (item) -> Bool in item < 0 })
        XCTAssertTrue(existsResult, "Traversables should be certain if one of their elements satisfy a given predicate")
        XCTAssertFalse(existsFalseResult, "Traversables should be certain if one of their elements satisfy a given predicate")
        
        let countResult = anArray.count({ (item) -> Bool in item >= 4 })
        XCTAssertTrue(countResult == 3, "Traversables should be able to count the elements which satisfy a given predicate")
        
        let array = ArrayT<Int>([1, 2, 3])
        let mappedConserveArray = mapConserveT(array, transform: {$0 * 2})
        XCTAssertEqual(sizeT(mappedConserveArray), sizeT(array), "Map-conserved traversable should be the same size as their origin")
        XCTAssertEqual(array[0]! * 2, mappedConserveArray[0]!, "Map-conserved traversable should apply the transformation provided to all their elements")
        
        let stringResult1 = mkStringT(array)
        let stringResult2 = mkStringT(array, separator: " ")
        let stringResult3 = mkStringT(array, start: "<", separator: ",", end: ">")
        XCTAssertEqual(stringResult1, "123", "Traversable should be able to be represented as Strings")
        XCTAssertEqual(stringResult2, "1 2 3", "Traversable should be able to be represented as Strings")
        XCTAssertEqual(stringResult3, "<1,2,3>", "Traversable should be able to be represented as Strings")
        
        let sliceResult1 = sliceT(array, from: 0, until: 1)
        let sliceResult3 = sliceT(array, from: 0, until: 3)
        let sliceResult13 = sliceT(array, from: 1, until: 3)
        XCTAssertTrue(sizeT(sliceResult1) == 1, "Traversable should be sliceable")
        XCTAssertEqual(headT(sliceResult1)!, 1, "Traversable should be sliceable")
        XCTAssertTrue(sizeT(sliceResult3) == 3, "Traversable should be sliceable")
        XCTAssertTrue(sizeT(sliceResult13) == 2, "Traversable should be sliceable")
        XCTAssertEqual(headT(sliceResult13)!, 2, "Traversable should be sliceable")
        XCTAssertEqual(lastT(sliceResult13)!, 3, "Traversable should be sliceable")
        
        let reverseArray = ArrayT([3, 2, 1])
        let sortedResult = sortWithT(reverseArray, p: { $1 > $0 })
        XCTAssertTrue(sizeT(sortedResult) == sizeT(reverseArray), "Traversable should be sortable by predicate")
        XCTAssertEqual(headT(sortedResult)!, lastT(reverseArray)!, "Traversable should be sortable by predicate")
        
        let unionResult = unionT(array, b: reverseArray)
        XCTAssertTrue(sizeT(unionResult) == sizeT(reverseArray) + sizeT(array), "Traversable should be unitable")
        XCTAssertTrue(unionResult[sizeT(array) - 1] == unionResult[sizeT(array)], "Traversable should be unitable")
    }

}
