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
import Swiftz

class TraversableTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
   
    func testMapTraversability() {
        let aMap : Map<Int> = ["a" : 1, "c" : 3, "d" : 4, "e" : 5, "f" : 6,  "b" : 2]
        
        var count = 0
        aMap.foreach { (item) -> () in
            count++; return ()
        }
        XCTAssertEqual(count, aMap.size, "Maps should be traversable and have a foreach function")
        
        let traversalityTestMap = Map<Int>.buildFromTraversable(aMap)
        XCTAssertTrue(traversalityTestMap == aMap, "Maps should be traversable and be able to be built from other Traversables")
        
        var mapFromArrayTrav = Map<Int>()
        mapFromArrayTrav = Map<Int>.build([("a", 1), ("b", 2), ("c", 3)])
        XCTAssertEqual(mapFromArrayTrav.size, 3, "Maps should be traversable and built from an array of valid tuples")
    }
    
    func testExtraFunctions() {
        let aMap : Map<Int> = ["a" : 1, "c" : 3, "d" : 4, "e" : 5, "f" : 6,  "b" : 2]
        let list = toListT(aMap)
        
        XCTAssertEqual(sizeT(list), aMap.size, "Traversable's toList should generate a List with the same number of elements as the source")
        XCTAssertEqual(list[0]!.1, aMap[list[0]!.0]!, "Traversable's toList should store all the elements of the source")
        
        XCTAssertFalse(isEmptyT(aMap), "Traversable's isEmpty should know if an instance has no elements")
        XCTAssertTrue(nonEmptyT(aMap), "Traversable's nonEmpty should know if an instance has no elements")
        
        XCTAssertEqual(sizeT(aMap), 6, "Traversables should know to count their elements")
        
        let findNotNil = findT(aMap, p: { (item) -> Bool in item.0 == "a" })
        let findNil = findT(aMap, p: { (item) -> Bool in item.0 == "foo" })
        XCTAssertTrue(findNotNil != nil, "Traversables should be able to find elements based on a predicate")
        XCTAssertTrue(findNil == nil, "Traversables should be able to find elements based on a predicate")
        
        let dropResult = dropT(aMap, n: 4)
        XCTAssertEqual(dropResult.size, aMap.size - 4, "Traversables should be droppable")
        XCTAssertFalse(findT(dropResult, p: { (item: (HashableAny, Int)) -> Bool in item.0 == aMap.keys[0] }) != nil, "Traversables should be takeable")
        XCTAssertTrue(findT(dropResult, p: { (item: (HashableAny, Int)) -> Bool in item.0 == aMap.keys[4] }) != nil, "Traversables should be takeable")
        XCTAssertTrue(findT(dropResult, p: { (item: (HashableAny, Int)) -> Bool in item.0 == aMap.keys[5] }) != nil, "Traversables should be takeable")
        
        let dropRightResult = dropRightT(aMap, n: 4)
        XCTAssertEqual(dropRightResult.size, aMap.size - 4, "Traversables should be droppable")
        XCTAssertFalse(findT(dropRightResult, p: { (item: (HashableAny, Int)) -> Bool in item.0 == aMap.keys[5] }) != nil, "Traversables should be takeable")
        XCTAssertTrue(findT(dropRightResult, p: { (item: (HashableAny, Int)) -> Bool in item.0 == aMap.keys[0] }) != nil, "Traversables should be takeable")
        XCTAssertTrue(findT(dropRightResult, p: { (item: (HashableAny, Int)) -> Bool in item.0 == aMap.keys[1] }) != nil, "Traversables should be takeable")
        
        let takeResult = takeT(aMap, n: 2)
        let takeRightResult = takeRightT(aMap, n: 2)
        XCTAssertFalse(findT(takeResult, p: { (item: (HashableAny, Int)) -> Bool in item.0 == aMap.keys[5] }) != nil, "Traversables should be takeable")
        XCTAssertTrue(findT(takeResult, p: { (item: (HashableAny, Int)) -> Bool in item.0 == aMap.keys[0] }) != nil, "Traversables should be takeable")
        XCTAssertTrue(findT(takeResult, p: { (item: (HashableAny, Int)) -> Bool in item.0 == aMap.keys[1] }) != nil, "Traversables should be takeable")
        
        XCTAssertFalse(findT(takeRightResult, p: { (item: (HashableAny, Int)) -> Bool in item.0 == aMap.keys[0] }) != nil, "Traversables should be takeable")
        XCTAssertTrue(findT(takeRightResult, p: { (item: (HashableAny, Int)) -> Bool in item.0 == aMap.keys[4] }) != nil, "Traversables should be takeable")
        XCTAssertTrue(findT(takeRightResult, p: { (item: (HashableAny, Int)) -> Bool in item.0 == aMap.keys[5] }) != nil, "Traversables should be takeable")
        
        let dropWhileResult = dropWhileT(aMap) { (key: HashableAny, value: Int) -> Bool in
            key != aMap.keys[2]
        }
        XCTAssertEqual(dropWhileResult.keys[0], aMap.keys[2], "Traversables should be droppable with while closure")
        
        let takeWhileResult = takeWhileT(aMap) { (key: HashableAny, value: Int) -> Bool in
            key != aMap.keys[2]
        }
        XCTAssertEqual(takeWhileResult.size, 2, "Traversables should be takeable with while closure")
        XCTAssertEqual(takeWhileResult.keys[0], aMap.keys[0], "Traversables should be takeable with while closure")
        XCTAssertEqual(takeWhileResult.keys[1], aMap.keys[1], "Traversables should be takeable with while closure")
        
        let headResult = headT(aMap)
        XCTAssertTrue(headResult != nil, "Traversables should know where their head is")
        XCTAssertTrue(headResult!.0 == aMap.keys[0], "Traversables should know where their head is")
        
        let tailResult = tailT(aMap)
        XCTAssertTrue(tailResult.size == aMap.size - 1, "Traversables should know where their tail is")
        XCTAssertTrue(tailResult[aMap.keys[0]] == nil, "Traversables should know where their tail is")
        
        let initResult = initT(aMap)
        XCTAssertTrue(initResult.size == aMap.size - 1, "Traversables should know where their init segment is")
        XCTAssertTrue(initResult[aMap.keys[5]] == nil, "Traversables should know where their init segment is")
        
        let lastResult = lastT(aMap)
        XCTAssertTrue(lastResult != nil, "Traversables should know their last element")
        XCTAssertTrue(lastResult!.0 == aMap.keys[5], "Traversables should know their last element")
        
        let filterNotResult = filterNotT(aMap, excludeElement: { (item) -> Bool in item.0 == "a" })
        XCTAssertTrue(filterNotResult.size == aMap.size - 1, "Traversables should be filtered with inverted conditions")
        XCTAssertTrue(filterNotResult["a"] == nil, "Traversables should be filtered with inverted conditions")
        
        let splitAtResult = splitAtT(aMap, n: 2)
        XCTAssertTrue(splitAtResult.0.size == 2, "Traversables should be splittable")
        XCTAssertTrue(splitAtResult.1.size == 4, "Traversables should be splittable")
        
        let partitionResult = partitionT(aMap, p: { (item) -> Bool in item.0 == "a" })
        XCTAssertTrue(partitionResult.0.size == 1, "Traversables should be partitionable")
        XCTAssertTrue(partitionResult.1.size == 5, "Traversables should be partitionable")
        
        let spanResult = spanT(aMap, p: { (item) -> Bool in item.0 != aMap.keys[2] })
        XCTAssertTrue(spanResult.0.size == 2, "Traversables should be spanable")
        XCTAssertTrue(spanResult.1.size == 4, "Traversables should be spanable")
        
        let groupByResult = groupByT(aMap, f: ∫{(item: (HashableAny, Int)) -> HashableAny in
            if item.1 % 2 == 0 {
                return "Evens"
            } else {
                return "Odds"
            }
        })
        XCTAssertTrue(groupByResult["Odds"]!.size == 3, "Traversable should be groupable by using functions")
        XCTAssertTrue(groupByResult["Evens"]!.size == 3, "Traversable should be groupable by using functions")
        XCTAssertNil(groupByResult["Odds"]!["b"], "Traversable should be groupable by using functions")
        XCTAssertNotNil(groupByResult["Evens"]!["b"], "Traversable should be groupable by using functions")
        
        let firstCase = ∫{ (item: (HashableAny, Int)) -> Bool in item.1 < 2 } |-> ∫{ (item: (HashableAny, Int)) -> HashableAny in "Less than 2" }
        let secondCase = ∫{ (item: (HashableAny, Int)) -> Bool in item.1 >= 2} |-> ∫{ (item: (HashableAny, Int)) -> HashableAny in "More or same than 2"}
        let thirdCase = ∫{ (item: (HashableAny, Int)) -> Bool in item.1 >= 5 } |-> ∫{ (item: (HashableAny, Int)) -> HashableAny in "More or same than 5"}
        let fourthCase = ∫{ (item: (HashableAny, Int)) -> Bool in (item.1 >= 2 && item.1 < 5)} |-> ∫{ (item: (HashableAny, Int)) -> HashableAny in "More or same than 2 but less than 5"}
        
        let complexGroupByResult = groupByT(aMap, f: firstCase |||> secondCase)
        XCTAssertTrue(complexGroupByResult["Less than 2"]!.size == 1, "Traversable should be groupable by using partial functions-based expressions")
        XCTAssertTrue(complexGroupByResult["More or same than 2"]!.size == 5, "Traversable should be groupable by using partial functions-based expressions")
        XCTAssertNil(complexGroupByResult["Less than 2"]!["b"], "Traversable should be groupable by using partial functions-based expressions")
        XCTAssertNotNil(complexGroupByResult["More or same than 2"]!["b"], "Traversable should be groupable by using partial functions-based expressions")
        
        let moreComplexGroupByResult = groupByT(aMap, f: match(firstCase, fourthCase, thirdCase))
        XCTAssertTrue(moreComplexGroupByResult["Less than 2"]!.size == 1, "Traversable should be groupable by using partial pattern matching")
        XCTAssertTrue(moreComplexGroupByResult["More or same than 2 but less than 5"]!.size == 3, "Traversable should be groupable by using partial pattern matching")
        XCTAssertTrue(moreComplexGroupByResult["More or same than 5"]!.size == 2, "Traversable should be groupable by using partial pattern matching")
        XCTAssertNil(moreComplexGroupByResult["Less than 2"]!["b"], "Traversable should be groupable by using partial pattern matching")
        XCTAssertNotNil(moreComplexGroupByResult["More or same than 2 but less than 5"]!["b"], "Traversable should be groupable by using partial pattern matching")
        XCTAssertNotNil(moreComplexGroupByResult["More or same than 5"]!["f"], "Traversable should be groupable by using partial pattern matching")
        
        let forAllResult = forAllT(aMap, p: { (item) -> Bool in item.1 > 0 })
        let forAllFalseResult = forAllT(aMap, p: { (item) -> Bool in item.1 > 3 })
        XCTAssertTrue(forAllResult, "Traversables should be certain if all their elements satisfy a given predicate")
        XCTAssertFalse(forAllFalseResult, "Traversables should be certain if all their elements satisfy a given predicate")
        
        let existsResult = existsT(aMap, p: { (item) -> Bool in item.1 == 5 })
        let existsFalseResult = existsT(aMap, p: { (item) -> Bool in item.1 < 0 })
        XCTAssertTrue(existsResult, "Traversables should be certain if one of their elements satisfy a given predicate")
        XCTAssertFalse(existsFalseResult, "Traversables should be certain if one of their elements satisfy a given predicate")
        
        let countResult = countT(aMap, p: { (item) -> Bool in item.1 >= 4 })
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
        
        let mapA : Map<Int> = ["a" : 1, "b" : 2]
        let mapB : Map<Int> = ["c" : 2, "b" : 4]
        let unionResultMap = unionT(mapA, b: mapB)
        XCTAssertTrue(sizeT(unionResultMap) == sizeT(mapA) + sizeT(mapB) - 1, "Traversables based on keys should be unitable, but no key should be repeated")
        XCTAssertTrue(unionResultMap["b"]! == 4, "Traversables based on keys should be unitable, but no key should be repeated")
    }
}