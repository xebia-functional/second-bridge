//
//  MapTests.swift
//  Swift47Deg
//
//  Created by Javier de Silóniz Sandino on 5/3/15.
//  Copyright (c) 2015 47 Degrees. All rights reserved.
//

import UIKit
import XCTest

class MapTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMapCreation() {
        let map : Map = ["a" : 1, 2 : 2, 3 : "c", 4.5 : 4.5]
        XCTAssertEqual(map.count, 4, "Map should have all elements added")
        XCTAssertNotNil(map["a"], "Map elements with String keys should be added")
        XCTAssertNotNil(map[2], "Map elements with Int keys should be added")
        XCTAssertNotNil(map[4.5], "Map elements with Double keys should be added")
        
        XCTAssertEqual(map["a"]! as Int, 1, "Map elements with String keys should be added")
        XCTAssertEqual(map[3]! as String, "c", "Map elements with Int keys should be added")
        XCTAssertEqual(map[4.5]! as Double, 4.5, "Map elements with Double keys should be added")
    }
    
    func testMapEnumeration() {
        let map : Map = ["a" : 1, 2 : 2, 3 : "c", 4.5 : 4.5]
        
        var loops = 0
        for (index, value) in map {
            switch index {
            case "a": XCTAssertEqual(map[index]! as Int, value as Int, "Map elements should be iterable")
            case 2: XCTAssertEqual(map[index]! as Int, value as Int, "Map elements should be iterable")
            case 3: XCTAssertEqual(map[index]! as String, value as String, "Map elements should be iterable")
            case 4.5: XCTAssertEqual(map[index]! as Double, value as Double, "Map elements should be iterable")
            default: break
            }
            loops++
        }
        XCTAssertEqual(loops, 4, "Map elements should be iterable")
    }
    
    func testMapAddition() {
        var map : Map = [:]
        map = map + ["a" : 1]
        XCTAssertNotNil(map["a"], "Map addition with another map should work")
        XCTAssertEqual(map["a"]! as Int, 1, "Map addition with another map should work")
        
        let addingMap : Map = [2 : 2]
        map += addingMap
        XCTAssertNotNil(map[2], "Map addition with another map should work")
        XCTAssertEqual(map[2]! as Int, 2, "Map addition with another map should work")
        
        map = map + (4.5, 4.5)
        XCTAssertNotNil(map[4.5], "Map addition with a tuple should work")
        XCTAssertEqual(map[4.5]! as Double, 4.5, "Map addition with a tuple should work")
        
        map += ("a", "b")
        XCTAssertNotNil(map["a"], "Map addition with a tuple should work")
        XCTAssertEqual(map["a"]! as String, "b", "Map addition with a tuple should work")
        
        map += [("foo", "bar"), ("bar", "foo")]
        XCTAssertNotNil(map["foo"], "Map addition with a tuple array should work")
        XCTAssertEqual(map["foo"]! as String, "bar", "Map addition with a tuple array should work")
        XCTAssertNotNil(map["bar"], "Map addition with a tuple array should work")
        XCTAssertEqual(map["bar"]! as String, "foo", "Map addition with a tuple array should work")
    }
    
    func testMapSubstraction() {
        var map : Map = ["a" : 1, "b" : 2, "c" : 3, "d" : 4, "e" : 5, "f" : 6]
        
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
    
    func testMapHigherOrderFunctions() {
        let map : Map = ["a" : 1, "b" : 2, "c" : 3, "d" : 4, "e" : 5, "f" : 6]
        
        let filteredMap = map.filter({ (value) -> Bool in
            (value as Int) < 3})
        XCTAssertEqual(filteredMap.count, 2, "Maps should be filterable with valid conditions")
        
        let filteredMapByKeyAndValue = map.filter { (element: (key: HashableAny, value: AnyObject)) -> Bool in
            return element.key != "f" && element.value as Int != 1
        }
        XCTAssertEqual(filteredMapByKeyAndValue.count, 4, "Maps should be filterable with conditions based on keys and values")
        
        let filteredMapByKey = map.filterKeys { (key: HashableAny) -> Bool in
            key != "f"
        }
        XCTAssertEqual(filteredMapByKey.count, 5, "Maps should be filterable with conditions based on keys alone")
        XCTAssertNil(filteredMapByKey["f"], "Maps should be filterable with conditions based on keys alone")
        
        let filteredNotMap = map.filterNot { (item: (HashableAny, AnyObject)) -> Bool in
            item.0 == "a" || item.1 as Int == 6
        }
        XCTAssertEqual(filteredNotMap.count, 4, "Maps should be filterable with conditions based on NOT conditions")
        XCTAssertNil(filteredNotMap["a"], "Maps should be filterable with conditions based on NOT conditions")
        XCTAssertNil(filteredNotMap["f"], "Maps should be filterable with conditions based on NOT conditions")
        XCTAssertNotNil(filteredNotMap["b"], "Maps should be filterable with conditions based on NOT conditions")
        
        let mappedMap = map.map({(AnyObject) -> AnyObject in 2 })
        XCTAssertEqual(mappedMap["a"]! as Int, 2, "Maps should be mappable")
        
        let hetMap : Map = [1: "a", 2: "b", 3: 4, 4: 5, "e": "c"]
        let intMap = hetMap.filter({ $0 is Int })
        let reduceResult = intMap.reduce(0, combine: { (currentTotal, currentElement) -> AnyObject in
            (currentTotal as Int) + (currentElement as Int)
        }) as Int
        XCTAssertEqual(reduceResult, 9, "Maps should be reducible")
        
        let findResult = map.find { (key: HashableAny, value: AnyObject) -> Bool in
            key == "f"
        }
        XCTAssertTrue(findResult != nil, "Maps should support find function")
        XCTAssertEqual(findResult!.0, "f" as HashableAny, "Maps should support find function")        
    }
    
    func testMapBasicFunctions() {
        var map : Map = [:]
        XCTAssertTrue(map.isEmpty(), "Maps should know if they're empty")
        
        let addingMap : Map = ["a": "a", "b": "b"]
        map += addingMap
        XCTAssertEqual(map.values() as [String], ["a", "b"], "Maps should know their values")
        XCTAssertEqual(map.keys, ["a", "b"], "Maps should know their keys")
        XCTAssertTrue(map.contains("a"), "Maps should figure out if they contain a key")
        XCTAssertFalse(map.contains("c"), "Maps should figure out if they contain a key")
        
        let test = map.addString("")
        XCTAssertEqual(map.addString(""), "ab", "Map's addString function should work OK")
        
        map += ["c": 1]
        let test2 = map.addString(" ")
        XCTAssertEqual(map.addString(""), "ab1", "Map's addString function should work OK")
        
        
        let anotherMap : Map = ["a" : 1, "b" : 2, "c" : 3, "d" : 4, "e" : 5, "f" : 6]
        let droppedMap = anotherMap.drop(2)
        XCTAssertEqual(droppedMap.count, 4, "Maps should be droppable")
        XCTAssertEqual(droppedMap.keys.first!, anotherMap.keys[2], "Maps should be droppable")
        
        let droppedRightMap = anotherMap.dropRight(2)
        XCTAssertEqual(droppedRightMap.count, 4, "Maps should be droppable")
        XCTAssertEqual(droppedRightMap.keys.last!, anotherMap.keys[3], "Maps should be droppable")
        
        let droppedWhileMap = anotherMap.dropWhile { (key: HashableAny, value: AnyObject) -> Bool in
            key != anotherMap.keys[2]
        }
        XCTAssertEqual(droppedWhileMap.keys[0], anotherMap.keys[2], "Maps should be droppable with while closure")
        
        XCTAssertTrue(anotherMap.exists({ $0.0 == "a" }), "Maps should work with exists function")
        XCTAssertFalse(anotherMap.exists({ $0.1 as Int > 7 }), "Maps should work with exists function")
    }
    
    func testMapEquality() {
        let aMap : Map = ["a" : 1, "c" : 3, "d" : 4, "e" : 5, "f" : 6,  "b" : 2]
        let anotherMap : Map = ["a" : 1, "b" : 2, "c" : 3, "d" : 4, "e" : 5, "f" : 6]
        let equalityChecker = { (lhs: AnyObject, rhs: AnyObject) -> Bool in
            (lhs as Int) == (rhs as Int)
        }
        XCTAssertTrue(aMap.equals(anotherMap, equals: equalityChecker), "Maps should support assisted equality")
        
        let droppedMap = anotherMap.drop(1)
        XCTAssertFalse(aMap.equals(droppedMap, equals: equalityChecker), "Maps should support equality")
        
        XCTAssertFalse(aMap.equals(Map(), equals: equalityChecker), "Maps should support equality")
    }
    
}


