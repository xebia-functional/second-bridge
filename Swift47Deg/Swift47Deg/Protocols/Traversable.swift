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

/**
Datatypes conforming to this protocol should expose certain functions that allow to traverse through them, and also being built from other Traversable types (although the latter has some limitations due to Swift type constraints restrictions). All Traversable instances have access to the following methods: `travReduce`, `travMap`, `travFilter`, `travFlatMap`, `travReverse`, `travFoldRight`, `travFoldLeft`, and `travToArray`.
*/
protocol Traversable {
    typealias ItemType
    
    /** 
    Traverse all items of the instance, and call the provided function on each one.
    */
    func foreach(f: (ItemType) -> ())
    
    /**
    Build a new instance of the same Traversable type with the elements contained in the `elements` array (i.e.: returned from the trav*** functions).
    */
    func build(elements: [ItemType]) -> Self
    
    /**
    Build a new instance of the same Traversable type with the elements contained in the provided Traversable instance. Users calling this function are responsible of transforming the data of each item to a valid ItemType suitable for the current Traversable class.
    */
    func buildFromTraversable<U where U : Traversable>(traversable: U) -> Self
}

// MARK: - Global functions
// These functions are available for all Traversable-conforming types

/**
Returns the result of repeatedly calling combine with an accumulated value initialized to `initial` and each element of the current traversable.
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

/**
Returns the result of repeatedly calling combine with an accumulated value initialized to `initial` and each element of the current traversable from left to right. Equivalent to `travReduce`.
*/
func travFoldRight<S: Traversable, U>(source: S, initialValue: U, combine: (U, S.ItemType) -> U) -> U {
    return travReduce(source, initialValue, combine)
}

/**
Returns the result of repeatedly calling combine with an accumulated value initialized to `initial` and each element of the current traversable from right to left. A reversal equivalent to `travReduce`.
*/
func travFoldLeft<S: Traversable, U>(source: S, initialValue: U, combine: (U, S.ItemType) -> U) -> U {
    let array = travToArray(source)
    var index = array.count - 1
    var result = initialValue
    while(index >= 0) {
        result = combine(result, array[index])
        index--
    }
    return result
}

/**
Returns an array containing the elements of this Traversable.
*/
func travToArray<S: Traversable>(source: S) -> [S.ItemType] {
    return travReduce(source, Array<S.ItemType>(), { (total, item) -> [S.ItemType] in
        total + [item]
    })
}

/**
Returns an array containing the results of mapping the partial function `f` over a set of the elements of this Traversable that match the condition defined in `f`'s `isDefinedAt`.
*/
func travCollect<S, U where S: Traversable>(source: S, f: PartialFunction<S.ItemType, U>) -> [U] {
    return travReduce(source, Array<U>(), { (total : [U], currentItem : S.ItemType) -> [U] in
        if f.isDefinedAt.apply(currentItem) == true {
            return total + [f.function.apply(currentItem)]
        }
        return total
    })
}