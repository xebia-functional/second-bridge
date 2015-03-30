//
//  TraversableTests.swift
//  Swift47Deg
//
//  Created by Javier de Silóniz Sandino on 30/3/15.
//  Copyright (c) 2015 47 Degrees. All rights reserved.
//

import Foundation
import XCTest

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
        
        let traversalityTestMap = aMap.buildFromTraversable(aMap)
        XCTAssertTrue(traversalityTestMap == aMap, "Maps should be traversable and be able to be built from other Traversables")
        
        var mapFromArrayTrav = Map<Int>()
        mapFromArrayTrav = Map<Int>.build([("a", 1), ("b", 2), ("c", 3)])
        XCTAssertEqual(mapFromArrayTrav.size, 3, "Maps should be traversable and built from an array of valid tuples")
    }
    
    func testExtraFunctions() {
        let aMap : Map<Int> = ["a" : 1, "c" : 3, "d" : 4, "e" : 5, "f" : 6,  "b" : 2]
        let list = travToList(aMap)
        
        XCTAssertEqual(Int(list.length()), aMap.size, "Traversable's toList should generate a List with the same number of elements as the source")
        XCTAssertEqual(list[0].1, aMap[list[0].0]!, "Traversable's toList should store all the elements of the source")
        
        XCTAssertFalse(travIsEmpty(aMap), "Traversable's isEmpty should know if an instance has no elements")
        XCTAssertTrue(travNonEmpty(aMap), "Traversable's nonEmpty should know if an instance has no elements")
        
        XCTAssertEqual(travSize(aMap), 6, "Traversables should know to count their elements")
        
        let findNotNil = travFind(aMap, { (item) -> Bool in item.0 == "a" })
        let findNil = travFind(aMap, { (item) -> Bool in item.0 == "foo" })
        XCTAssertTrue(findNotNil != nil, "Traversables should be able to find elements based on a predicate")
        XCTAssertTrue(findNil == nil, "Traversables should be able to find elements based on a predicate")
        
        let dropResult = travDrop(aMap, 4)
        XCTAssertEqual(dropResult.size, aMap.size - 4, "Traversables should be droppable")
        XCTAssertFalse(travFind(dropResult, { (item: (HashableAny, Int)) -> Bool in item.0 == aMap.keys[0] }) != nil, "Traversables should be takeable")
        XCTAssertTrue(travFind(dropResult, { (item: (HashableAny, Int)) -> Bool in item.0 == aMap.keys[4] }) != nil, "Traversables should be takeable")
        XCTAssertTrue(travFind(dropResult, { (item: (HashableAny, Int)) -> Bool in item.0 == aMap.keys[5] }) != nil, "Traversables should be takeable")
        
        let dropRightResult = travDropRight(aMap, 4)
        XCTAssertEqual(dropRightResult.size, aMap.size - 4, "Traversables should be droppable")
        XCTAssertFalse(travFind(dropRightResult, { (item: (HashableAny, Int)) -> Bool in item.0 == aMap.keys[5] }) != nil, "Traversables should be takeable")
        XCTAssertTrue(travFind(dropRightResult, { (item: (HashableAny, Int)) -> Bool in item.0 == aMap.keys[0] }) != nil, "Traversables should be takeable")
        XCTAssertTrue(travFind(dropRightResult, { (item: (HashableAny, Int)) -> Bool in item.0 == aMap.keys[1] }) != nil, "Traversables should be takeable")
        
        let takeResult = travTake(aMap, 2)
        let takeRightResult = travTakeRight(aMap, 2)
        XCTAssertFalse(travFind(takeResult, { (item: (HashableAny, Int)) -> Bool in item.0 == aMap.keys[5] }) != nil, "Traversables should be takeable")
        XCTAssertTrue(travFind(takeResult, { (item: (HashableAny, Int)) -> Bool in item.0 == aMap.keys[0] }) != nil, "Traversables should be takeable")
        XCTAssertTrue(travFind(takeResult, { (item: (HashableAny, Int)) -> Bool in item.0 == aMap.keys[1] }) != nil, "Traversables should be takeable")
        
        XCTAssertFalse(travFind(takeRightResult, { (item: (HashableAny, Int)) -> Bool in item.0 == aMap.keys[0] }) != nil, "Traversables should be takeable")
        XCTAssertTrue(travFind(takeRightResult, { (item: (HashableAny, Int)) -> Bool in item.0 == aMap.keys[4] }) != nil, "Traversables should be takeable")
        XCTAssertTrue(travFind(takeRightResult, { (item: (HashableAny, Int)) -> Bool in item.0 == aMap.keys[5] }) != nil, "Traversables should be takeable")
        
        let dropWhileResult = travDropWhile(aMap) { (key: HashableAny, value: Int) -> Bool in
            key != aMap.keys[2]
        }
        XCTAssertEqual(dropWhileResult.keys[0], aMap.keys[2], "Traversables should be droppable with while closure")
        
        let takeWhileResult = travTakeWhile(aMap) { (key: HashableAny, value: Int) -> Bool in
            key != aMap.keys[2]
        }
        XCTAssertEqual(takeWhileResult.size, 2, "Traversables should be takeable with while closure")
        XCTAssertEqual(takeWhileResult.keys[0], aMap.keys[0], "Traversables should be takeable with while closure")
        XCTAssertEqual(takeWhileResult.keys[1], aMap.keys[1], "Traversables should be takeable with while closure")
        
        let headResult = travHead(aMap)
        XCTAssertTrue(headResult != nil, "Traversables should know where their head is")
        XCTAssertTrue(headResult!.0 == aMap.keys[0], "Traversables should know where their head is")
        
        let tailResult = travTail(aMap)
        XCTAssertTrue(tailResult.size == aMap.size - 1, "Traversables should know where their tail is")
        XCTAssertTrue(tailResult[aMap.keys[0]] == nil, "Traversables should know where their tail is")
        
        let initResult = travInit(aMap)
        XCTAssertTrue(initResult.size == aMap.size - 1, "Traversables should know where their init segment is")
        XCTAssertTrue(initResult[aMap.keys[5]] == nil, "Traversables should know where their init segment is")
        
        let filterNotResult = travFilterNot(aMap, { (item) -> Bool in item.0 == "a" })
        XCTAssertTrue(filterNotResult.size == aMap.size - 1, "Traversables should be filtered with inverted conditions")
        XCTAssertTrue(filterNotResult["a"] == nil, "Traversables should be filtered with inverted conditions")
    }
}