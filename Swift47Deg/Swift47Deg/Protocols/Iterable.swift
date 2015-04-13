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
Returns an array of Iterables, being the result of grouping chunks of size `n` while traversing through a sliding window of size `windowSize`.
*/
public func sliding<S: Iterable>(source: S, n: Int, windowSize: Int) -> [S] {
    let itemsToAdd = n - windowSize
    let accumulatedItems = n - itemsToAdd
    let totalSize = travSize(source)
    
    return travReduce(source, (index: 0, buffer: S.build(Array<S.ItemType>()), result: Array<S>())) { (data: (index: Int, buffer: S, result: [S]), currentItem: S.ItemType) -> (index: Int, buffer: S, result: [S]) in
        let nextIndex = data.index + 1
        
        // First, we accumulate in the buffer each value
        var nextBuffer : S
        if travSize(data.buffer) == n {
            nextBuffer = S.build(travToArray(travDrop(data.buffer, 1)) + [currentItem])
        } else {
            nextBuffer = S.build(travToArray(data.buffer) + [currentItem])
        }
        
        if (data.index - n + 1) % windowSize == 0 && travSize(nextBuffer) == n {
            // We have to return the buffer as a new result:
            var nextResult = data.result
            nextResult += [nextBuffer]
            return (nextIndex, nextBuffer, nextResult)
        } else if nextIndex == totalSize {
            let restCount = totalSize % windowSize
            var nextResult = data.result
            nextResult += [travTakeRight(nextBuffer, restCount)]
            return (nextIndex, nextBuffer, nextResult)
        } else {
            // We keep our results as they are now
            return (nextIndex, nextBuffer, data.result)
        }
    }.result
}

/**
Returns an array of Iterables, being the result of grouping chunks of size `n` while traversing through a sliding window of size 1.
*/
public func sliding<S: Iterable>(source: S, n: Int) -> [S] {
    return sliding(source, n, 1)
}

/**
Returns an array of Iterables of size `n`, comprising all the elements of the provided Iterable.
*/
public func grouped<S: Iterable>(source: S, n: Int) -> [S] {
    return sliding(source, n, n)
}