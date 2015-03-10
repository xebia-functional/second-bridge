//
//  MapTests.swift
//  Swift47Deg
//
//  Created by Javier de Silóniz Sandino on 9/3/15.
//  Copyright (c) 2015 47 Degrees. All rights reserved.
//

import UIKit
import XCTest

class MapTests : XCTestCase {
    
    // MARK: - Map tests
    
    func testTypedMapCreation() {
        let map : Map<Int> = ["a" : 1, 2 : 2, 4.5: 3]
        XCTAssertEqual(map.count, 3, "Maps should have all elements added")
        XCTAssertNotNil(map["a"], "Map elements with String keys should be added")
        XCTAssertNotNil(map[2], "Maps elements with Int keys should be added")
        XCTAssertNotNil(map[4.5], "Maps elements with Double keys should be added")
        
        XCTAssertEqual(map["a"]!, 1, "Maps elements with String keys should be added")
        XCTAssertEqual(map[2]!, 2, "Maps elements with Int keys should be added")
        XCTAssertEqual(map[4.5]!, 3, "Maps elements with Double keys should be added")
    }
    
    func testTypedMapEnumeration() {
        let map : Map<Int> = ["a" : 1, 2 : 2, 3 : 3, 4.5 : 4]
        
        var loops = 0
        for (index, value) in map {
            switch index {
            case "a": XCTAssertEqual(map[index]!, value, "Map elements should be iterable")
            case 2: XCTAssertEqual(map[index]!, value, "Map elements should be iterable")
            case 3: XCTAssertEqual(map[index]!, value, "Map elements should be iterable")
            case 4.5: XCTAssertEqual(map[index]!, value, "Map elements should be iterable")
            default: break
            }
            loops++
        }
        XCTAssertEqual(loops, 4, "Map elements should be iterable")
    }
    
    func testTypedMapAddition() {
        var map : Map<Int> = [:]
        map = map + ["a" : 1]
        XCTAssertNotNil(map["a"], "Map addition with another Map should work")
        XCTAssertEqual(map["a"]! as Int, 1, "Map addition with another map should work")
        
        let addingMap : Map<Int> = [2 : 2]
        map += addingMap
        XCTAssertNotNil(map[2], "Map addition with another Map should work")
        XCTAssertEqual(map[2]! as Int, 2, "Map addition with another map should work")
        
        map = map + (4.5, 4)
        XCTAssertNotNil(map[4.5], "Map addition with a tuple should work")
        XCTAssertEqual(map[4.5]!, 4, "Map addition with a tuple should work")
        
        map += ("b", 5)
        XCTAssertNotNil(map["b"], "Map addition with a tuple should work")
        XCTAssertEqual(map["b"]!, 5, "Map addition with a tuple should work")
        
        map += [("foo", 7), ("bar", 8)]
        XCTAssertNotNil(map["foo"], "Map addition with a tuple array should work")
        XCTAssertEqual(map["foo"]!, 7, "Map addition with a tuple array should work")
        XCTAssertNotNil(map["bar"], "Map addition with a tuple array should work")
        XCTAssertEqual(map["bar"]!, 8, "Map addition with a tuple array should work")
    }
    
    func testTypedMapSubstraction() {
        var map : Map<Int> = ["a" : 1, "b" : 2, "c" : 3, "d" : 4, "e" : 5, "f" : 6]
        
        map = map - "a"
        XCTAssertNil(map["a"], "Map keys should be removable")
        
        map -= "b"
        XCTAssertNil(map["b"], "Map keys should be removable")
        
        map = map -- ["c", "d", "h"]
        XCTAssertNil(map["c"], "Map keys should be removable")
        XCTAssertNil(map["d"], "Map keys should be removable")
        
        map --= ["e", "f"]
        XCTAssertNil(map["e"], "Map keys should be removable")
        XCTAssertNil(map["f"], "Map keys should be removable")
        
        XCTAssertEqual(map.count, 0, "Map keys should be removable")
    }
    
    func testTypedMapHigherOrderFunctions() {
        let map : Map<Int> = ["a" : 1, "b" : 2, "c" : 3, "d" : 4, "e" : 5, "f" : 6]
        
        let filteredMap = map.filter({ (value) -> Bool in
            (value as Int) < 3})
        XCTAssertEqual(filteredMap.count, 2, "Maps should be filterable with valid conditions")
        
        let filteredMapByKeyAndValue = map.filter { (element: (key: HashableAny, value: Int)) -> Bool in
            return element.key != "f" && element.value as Int != 1
        }
        XCTAssertEqual(filteredMapByKeyAndValue.count, 4, "Maps should be filterable with conditions based on keys and values")
        
        let filteredMapByKey = map.filterKeys { (key: HashableAny) -> Bool in
            key != "f"
        }
        XCTAssertEqual(filteredMapByKey.count, 5, "Maps should be filterable with conditions based on keys alone")
        XCTAssertNil(filteredMapByKey["f"], "Maps should be filterable with conditions based on keys alone")
        
        let filteredNotMap = map.filterNot { (item: (HashableAny, Int)) -> Bool in
            item.0 == "a" || item.1 == 6
        }
        XCTAssertEqual(filteredNotMap.count, 4, "Maps should be filterable with conditions based on NOT conditions")
        XCTAssertNil(filteredNotMap["a"], "Maps should be filterable with conditions based on NOT conditions")
        XCTAssertNil(filteredNotMap["f"], "Maps should be filterable with conditions based on NOT conditions")
        XCTAssertNotNil(filteredNotMap["b"], "Maps should be filterable with conditions based on NOT conditions")
        
        let mappedMap = map.map({(Int) -> Int in 2 })
        XCTAssertEqual(mappedMap["a"]! as Int, 2, "Maps should be mappable")
        
        let reducedResult = map.reduce(0, combine: +)
        XCTAssertEqual(reducedResult, 21, "Maps should be reducible")
        
        let reducedByKeyValueResult = map.reduceByKeyValue(0, combine: { (total: Int, currentItem: (key: HashableAny, value: Int)) -> Int in
            if currentItem.key != "f" {
                return total + currentItem.value
            }
            return total
        })
        XCTAssertEqual(reducedByKeyValueResult, 15, "Maps should be reducible taking into account both values and keys")
        
        let findResult = map.find { (key: HashableAny, value: Int) -> Bool in
            key == "f"
        }
        XCTAssertTrue(findResult != nil, "Maps should support find function")
        XCTAssertEqual(findResult!.0, "f" as HashableAny, "Maps should support find function")
    }
    
    func testTypedMapBasicFunctions() {
        var map : Map<Int> = [:]
        XCTAssertTrue(map.isEmpty(), "Maps should know if they're empty")
        
        let addingMap : Map<Int> = ["a": 1, "b": 2]
        map += addingMap
        XCTAssertEqual(map.values(), [1, 2], "Maps should know their values")
        XCTAssertEqual(map.keys, ["a", "b"], "Maps should know their keys")
        XCTAssertTrue(map.contains("a"), "Maps should figure out if they contain a key")
        XCTAssertFalse(map.contains("c"), "Maps should figure out if they contain a key")
        
        let anotherMap : Map<Int> = ["a" : 1, "b" : 2, "c" : 3, "d" : 4, "e" : 5, "f" : 6]
        let droppedMap = anotherMap.drop(2)
        XCTAssertEqual(droppedMap.count, 4, "Maps should be droppable")
        XCTAssertEqual(droppedMap.keys.first!, anotherMap.keys[2], "Maps should be droppable")
        
        let droppedRightMap = anotherMap.dropRight(2)
        XCTAssertEqual(droppedRightMap.count, 4, "Maps should be droppable")
        XCTAssertEqual(droppedRightMap.keys.last!, anotherMap.keys[3], "Maps should be droppable")
        
        let droppedWhileMap = anotherMap.dropWhile { (key: HashableAny, value: Int) -> Bool in
            key != anotherMap.keys[2]
        }
        XCTAssertEqual(droppedWhileMap.keys[0], anotherMap.keys[2], "Maps should be droppable with while closure")
        
        XCTAssertTrue(anotherMap.exists({ $0.0 == "a" }), "Maps should work with exists function")
        XCTAssertFalse(anotherMap.exists({ $0.1 > 7 }), "Maps should work with exists function")
        
        if let max = anotherMap.maxBy({ $0 }) {
            XCTAssertEqual(max.1, 6, "Maps' maxBy function should work OK")
        } else {
            XCTFail("Maps' maxBy function should work OK")
        }
        
        if let head = anotherMap.head() {
            XCTAssertEqual(head.0, anotherMap.keys[0], "Maps should have their heads accessible, even if they're not ordered")
        } else {
            XCTFail("Maps should have their heads accessible, even if they're not ordered")
        }
        XCTAssertNil(Map().head()?.1, "Empty maps shouldn't have a head")
        
        
        let initSegment = anotherMap.initSegment()
        XCTAssertEqual(initSegment.count, anotherMap.count - 1, "Maps' initSegment should return all elements but the last one")
        XCTAssertEqual(initSegment.keys.last!, anotherMap.keys[anotherMap.count - 2], "Maps' initSegment should return all elements but the last one")
        
        if let lastElement = anotherMap.last() {
            XCTAssertEqual(lastElement.0, anotherMap.keys[anotherMap.count - 1], "Non empty maps should have a last element")
        } else {
            XCTFail("Non empty maps should have a last element")
        }
    }
    
    
    func testTypedMapEquality() {
        let aMap : Map<Int> = ["a" : 1, "c" : 3, "d" : 4, "e" : 5, "f" : 6,  "b" : 2]
        let anotherMap : Map<Int> = ["a" : 1, "b" : 2, "c" : 3, "d" : 4, "e" : 5, "f" : 6]
        XCTAssertTrue(aMap == anotherMap, "Maps should support equality")
        
        let droppedMap = anotherMap.drop(1)
        XCTAssertFalse(aMap == droppedMap, "Maps should support equality")
        
        XCTAssertFalse(aMap == Map<Int>(), "Maps should support equality")
    }
    
    func testAnyObjectMap() {
        let itemA = 2
        let itemB = 4.5
        let itemC = "a"
        let itemD : Map<Int> = ["a": 1]
        
        let map : Map<Any> = ["a": itemA, "b": itemB, "c": itemC, 4: itemD]
        XCTAssertEqual(map.count, 4, "Maps should support any type by using the Any protocol")
        XCTAssertNotNil(map["a"] as Int, "Maps should support any type by using the Any protocol")
        XCTAssertNotNil(map["b"] as Double, "Maps should support any type by using the Any protocol")
        XCTAssertNotNil(map["c"] as String, "Maps should support any type by using the Any protocol")
        
        if let storedMap = map[4] as? Map<Int> {
            XCTAssertNotNil(storedMap["a"], "Maps should support any type by using the Any protocol")
            XCTAssertEqual(storedMap["a"]!, 1, "Maps should support any type by using the Any protocol")
        } else {
            XCTFail("Maps should support any type by using the Any protocol")
        }
    }
}