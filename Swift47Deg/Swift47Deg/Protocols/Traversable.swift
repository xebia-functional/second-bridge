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

protocol Traversable {
    typealias ItemType
    
    func foreach(f: (ItemType) -> ())
}

// MARK: - Global functions
// These functions are available for all Traversable-conforming types

/**
Returns the result of repeatedly calling combine with an accumulated value initialized to `initial` and each element (taking also into account the key) of the current traversable.
*/
func travReduce<S: Traversable, U>(source: S, initialValue: U, combine: (U, S.ItemType) -> U) -> U {
    var result = initialValue
    source.foreach { (item: S.ItemType) -> () in
        result = combine(result, item)
        return ()
    }
    return result
}

/**
Returns an array containing the results of mapping `transform` over its elements.
*/
func travMap<S: Traversable, U>(source: S, transform: (S.ItemType) -> U) -> [U] {
    return travReduce(source, Array<U>()) { (total, item) -> [U] in
        total + [transform(item)]
    }
}

/**
Returns an array containing all the values from the current traversable that satisfy the `includeElement` closure.
*/
func travFilter<S: Traversable>(source: S, includeElement: (S.ItemType) -> Bool) -> [S.ItemType] {
    return travReduce(source, Array<S.ItemType>()) { (filtered, item) -> [S.ItemType] in
        includeElement(item) ? filtered + [item] : filtered
    }
}

/**
Returns the result of applying `transform` on each element of the traversable, and then flattening the results into an array.
*/
func travFlatMap<S: Traversable, U>(source: S, transform: (S.ItemType) -> [U]) -> [U] {
    return travReduce(source, Array<U>()) { (total, item) -> [U] in
        total + transform(item)
    }
}

/**
Returns a traversable with elements in inverse order. Note: it won't produce a correct result when applied to non-ordered traversables.
*/
func travReverse<S: Traversable>(source: S) -> [S.ItemType] {
    return travReduce(source, Array<S.ItemType>(), { (total, item) -> [S.ItemType] in
        [item] + total
    })
}