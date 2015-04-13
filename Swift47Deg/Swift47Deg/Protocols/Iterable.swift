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

public protocol Iterable : Traversable, SequenceType {
    
}

/**
Returns an array of Iterables, being the result of grouping chunks of size `n` while traversing through a sliding window of size `windowSize`. Note: might return different results for different runs if the underlying collection type is unordered.
*/
public func sliding<S: Iterable>(source: S, n: Int, windowSize: Int) -> [S] {
    let itemsToAdd = n - windowSize
    let accumulatedItems = n - itemsToAdd
    let totalSize = travSize(source)
    
    return travReduce(source, (index: 0, buffer: S.build(Array<S.ItemType>()), result: Array<S>())) { (data: (index: Int, buffer: S, result: [S]), currentItem: S.ItemType) -> (index: Int, buffer: S, result: [S]) in
        let nextIndex = data.index + 1
        
        var nextBuffer : S
        if travSize(data.buffer) == n {
            nextBuffer = S.build(travToArray(travDrop(data.buffer, 1)) + [currentItem])
        } else {
            nextBuffer = S.build(travToArray(data.buffer) + [currentItem])
        }
        
        if (data.index - n + 1) % windowSize == 0 && travSize(nextBuffer) == n {
            var nextResult = data.result
            nextResult += [nextBuffer]
            return (nextIndex, nextBuffer, nextResult)
        } else if nextIndex == totalSize {
            let restCount = totalSize % windowSize
            var nextResult = data.result
            nextResult += [travTakeRight(nextBuffer, restCount)]
            return (nextIndex, nextBuffer, nextResult)
        } else {
            return (nextIndex, nextBuffer, data.result)
        }
    }.result
}

/**
Returns an array of Iterables, being the result of grouping chunks of size `n` while traversing through a sliding window of size 1. Note: might return different results for different runs if the underlying collection type is unordered.
*/
public func sliding<S: Iterable>(source: S, n: Int) -> [S] {
    return sliding(source, n, 1)
}

/**
Returns an array of Iterables of size `n`, comprising all the elements of the provided Iterable. Note: might return different results for different runs if the underlying collection type is unordered.
*/
public func grouped<S: Iterable>(source: S, n: Int) -> [S] {
    return sliding(source, n, n)
}

/**
Returns an array of tuples, each containing the corresponding elements from the provided Iterables. The size of the resulting array will be the same as the smaller source. Note: might return different results for different runs if the underlying collection types are unordered.
*/
public func zip<S: Iterable, T: Iterable where S.Generator.Element == S.ItemType, T.Generator.Element == T.ItemType>(sourceA: S, sourceB: T) -> [(S.ItemType, T.ItemType)] {
    return zipAll(sourceA, sourceB, nil, nil)
}

/**
Returns an array of tuples, each containing an element from the provided Iterable and its index. Note: might return different results for different runs if the underlying collection type is unordered.
*/
public func zipWithIndex<S: Iterable where S.Generator.Element == S.ItemType>(source: S) -> [(S.ItemType, Int)] {
    return zipAll(source, TravArray<Int>([Int](0...travSize(source) - 1)), nil, nil)
}

/**
Returns an array of tuples, each containing the corresponding elements from the provided Iterables. If the two sources aren't the same size, zipAll will fill the gaps by using the provided default items (if any).
*/
public func zipAll<S: Iterable, T: Iterable where S.Generator.Element == S.ItemType, T.Generator.Element == T.ItemType>(sourceA: S, sourceB: T, defaultItemA: S.ItemType?, defaultItemB: T.ItemType?) -> [(S.ItemType, T.ItemType)] {
    let sizeA = travSize(sourceA)
    let sizeB = travSize(sourceB)
    let smallerSize = sizeA < sizeB ? sizeA : sizeB
    let largerSize = sizeA > sizeB ? sizeA : sizeB
    let loopCount = (defaultItemA != nil && defaultItemB != nil) ? largerSize : smallerSize

    var genA = enumerate(sourceA).generate()
    var genB = enumerate(sourceB).generate()
    var resultArray = Array<(S.ItemType, T.ItemType)>()
    
    for _ in 0...loopCount - 1 {
        switch (genA.next(), genB.next(), defaultItemA, defaultItemB) {
        case let (.Some(itemA), .Some(itemB), _, _): resultArray.append((itemA.element, itemB.element))
        case let (.Some(itemA), _, .Some(dItemA), .Some(dItemB)): resultArray.append((itemA.element, dItemB))
        case let (_, .Some(itemB), .Some(dItemA), .Some(dItemB)): resultArray.append((dItemA, itemB.element))
        default: break;
        }
    }
    return resultArray
}

/**
Returns true if the two Iterables contain the same elements in the same order. Note: might return different results for different runs if the underlying collection types are unordered.
*/
public func sameElements<S: Iterable where S.Generator.Element == S.ItemType, S.ItemType : Equatable>(sourceA: S, sourceB: S) -> Bool {
    let sizeA = travSize(sourceA)
    let sizeB = travSize(sourceB)
    if sizeA != sizeB {
        return false
    }
    var genA = enumerate(sourceA).generate()
    var genB = enumerate(sourceB).generate()
    
    for _ in 0...sizeA - 1 {
        switch (genA.next(), genB.next()) {
        case let (.Some(itemA), .Some(itemB)): if itemA.element != itemB.element { return false }
        default: return false
        }
    }
    return true
}