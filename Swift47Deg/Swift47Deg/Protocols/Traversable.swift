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
import Swiftz

/**
Datatypes conforming to this protocol should expose certain functions that allow to traverse through them, and also being built from other Traversable types (although the latter has some limitations due to Swift type constraints restrictions). All Traversable instances have access to the following methods: `travReduce`, `travMap`, `travFilter`, `travFlatMap`, `travReverse`, `travFoldRight`, `travFoldLeft`, and `travToArray`.
*/
public protocol Traversable {
    typealias ItemType
    
    /** 
    Traverse all items of the instance, and call the provided function on each one.
    */
    func foreach(f: (ItemType) -> ())
    
    /**
    Build a new instance of the same Traversable type with the elements contained in the `elements` array (i.e.: returned from the trav*** functions).
    */
    class func build(elements: [ItemType]) -> Self
    
    /**
    Build a new instance of the same Traversable type with the elements contained in the provided Traversable instance. Users calling this function are responsible of transforming the data of each item to a valid ItemType suitable for the current Traversable class.
    */
    class func buildFromTraversable<U where U : Traversable>(traversable: U) -> Self
}

// MARK: - Global functions
// These functions are available for all Traversable-conforming types

/**
Returns the result of repeatedly calling combine with an accumulated value initialized to `initial` and each element of the current traversable.
*/
public func travReduce<S: Traversable, U>(source: S, initialValue: U, combine: (U, S.ItemType) -> U) -> U {
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
public func travMap<S: Traversable, U>(source: S, transform: (S.ItemType) -> U) -> [U] {
    return travReduce(source, Array<U>()) { (total, item) -> [U] in
        total + [transform(item)]
    }
}

/**
Returns a Traversable containing all the values from the current traversable that satisfy the `includeElement` closure.
*/
public func travFilter<S: Traversable>(source: S, includeElement: (S.ItemType) -> Bool) -> S {
    return S.build(travReduce(source, Array<S.ItemType>()) { (filtered, item) -> [S.ItemType] in
        includeElement(item) ? filtered + [item] : filtered
    })
}

/**
Returns an array containing all the values from the current traversable except those that satisfy the `excludeElement` closure.
*/
public func travFilterNot<S: Traversable>(source: S, excludeElement: (S.ItemType) -> Bool) -> S {
    return S.build(travReduce(source, Array<S.ItemType>()) { (filtered, item) -> [S.ItemType] in
        !excludeElement(item) ? filtered + [item] : filtered
    })
}

/**
Returns the result of applying `transform` on each element of the traversable, and then flattening the results into an array. You can create a new Traversable from the results of the flatMap application by calling function Traversable.build and passing its results to it.
*/
public func travFlatMap<S: Traversable, U>(source: S, transform: (S.ItemType) -> [U]) -> [U] {
    return travReduce(source, Array<U>()) { (total, item) -> [U] in
        total + transform(item)
    }
}

/**
Returns a traversable with elements in inverse order. Note: it won't produce a correct result when applied to non-ordered traversables.
*/
public func travReverse<S: Traversable>(source: S) -> [S.ItemType] {
    return travReduce(source, Array<S.ItemType>(), { (total, item) -> [S.ItemType] in
        [item] + total
    })
}

/**
Returns the result of repeatedly calling combine with an accumulated value initialized to `initial` and each element of the current traversable from left to right. Equivalent to `travReduce`.
*/
public func travFoldRight<S: Traversable, U>(source: S, initialValue: U, combine: (U, S.ItemType) -> U) -> U {
    return travReduce(source, initialValue, combine)
}

/**
Returns the result of repeatedly calling combine with an accumulated value initialized to `initial` and each element of the current traversable from right to left. A reversal equivalent to `travReduce`.
*/
public func travFoldLeft<S: Traversable, U>(source: S, initialValue: U, combine: (U, S.ItemType) -> U) -> U {
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
public func travToArray<S: Traversable>(source: S) -> [S.ItemType] {
    return travReduce(source, Array<S.ItemType>(), { (total, item) -> [S.ItemType] in
        total + [item]
    })
}

/**
Returns a list containing the elements of this Traversable.
*/
public func travToList<S: Traversable>(source: S) -> List<S.ItemType> {
    return travReduce(source, List<S.ItemType>(), { (list : List<S.ItemType>, item : S.ItemType) -> List<S.ItemType> in
        let l : List<S.ItemType> = [item]
        return list.append(l)
    })
}

/**
Returns true if this Traversable doesn't contain any elements.
*/
public func travIsEmpty<S: Traversable>(source: S) -> Bool {
    var result = true
    source.foreach { (item) -> () in
        result = false
    }
    return result
}

/**
Returns the number of elements contained in this Traversable.
*/
public func travSize<S: Traversable>(source: S) -> Int {
    return travReduce(source, 0) { (total, item) -> Int in
        return total + 1
    }
}

/**
Returns true if this Traversable contains elements.
*/
public func travNonEmpty<S: Traversable>(source: S) -> Bool {
    return !travIsEmpty(source)
}

/**
Returns the first element of this Traversable that satisfy the given predicate `p`.
*/
public func travFind<S: Traversable>(source: S, p: (S.ItemType) -> Bool) -> S.ItemType? {
    return travReduce(source, nil) { (result, item) -> S.ItemType? in
        if result == nil && p(item) {
            return item
        }
        return result
    }
}

/**
Selects all elements except the first n ones. Note: might return different results for different runs, if the underlying collection type is unordered.

:param: source Traversable containing the elements to be selected
:param: n Number of elements to be excluded from the selection

:returns: A new Traversable of the same type as `source` containing the elements from the selection
*/
public func travDrop<S: Traversable>(source: S, n: Int) -> S {
    if travNonEmpty(source) {
        let result = S.build(travFoldLeft(source, (travSize(source), Array<S.ItemType>()), { (result: (index: Int, array: [S.ItemType]), currentItem) -> (Int, [S.ItemType]) in
            if result.index > n {
                var resultArray = result.array
                resultArray = resultArray + [currentItem]
                return (result.index - 1, resultArray)
            }
            return result
        }).1)
        return S.build(travReverse(result))
    }
    return source
}

/**
Selects all elements except the last n ones. Note: might return different results for different runs, as the underlying collection type is unordered.

:param: source Traversable containing the elements to be selected
:param: n Number of elements to be excluded from the selection

:returns: A new Traversable of the same type as `source` containing the elements from the selection
*/
public func travDropRight<S: Traversable>(source: S, n: Int) -> S {
    if travNonEmpty(source) {
        let size = travSize(source)
        return S.build(travFoldRight(source, (0, Array<S.ItemType>()), { (result: (index: Int, array: [S.ItemType]), currentItem) -> (Int, [S.ItemType]) in
            if result.index < size - n {
                var resultArray = result.array
                resultArray = resultArray + [currentItem]
                return (result.index + 1, resultArray)
            }
            return result
        }).1)
    }
    return source
}

private func travFindIndexOfFirstItemToNotSatisfyPredicate<S: Traversable>(source: S, p: (S.ItemType) -> Bool) -> Int? {
    let result = travReduce(source, (0, false)) { (result: (count: Int, didFindItem: Bool), item) -> (Int, Bool) in
        if result.didFindItem {
            return result
        } else {
            if !p(item) {
                return (result.count, true)
            }
            return (result.count + 1, false)
        }
    }
    
    if result.1 {
        return result.0
    }
    return nil
}

/**
Drops longest prefix of elements that satisfy a predicate. Note: might return different results for different runs if the underlying collection type is unordered.

:param: source Traversable containing the elements to be selected.
:param: p Predicate to match the elements to.

:returns: The longest prefix of this Traversable whose first element does not satisfy the predicate p.
*/
public func travDropWhile<S: Traversable>(source: S, p: (S.ItemType) -> Bool) -> S {
    if let firstIndex = travFindIndexOfFirstItemToNotSatisfyPredicate(source, p) {
        return travDrop(source, firstIndex)
    }
    return source
}

/**
Takes longest prefix of elements that satisfy a predicate. Note: might return different results for different runs if the underlying collection type is unordered.

:param: source Traversable containing the elements to be selected.
:param: p Predicate to match the elements to.

:returns: The longest prefix of elements that satisfy the predicate p.
*/
public func travTakeWhile<S: Traversable>(source: S, p: (S.ItemType) -> Bool) -> S {
    if let firstIndex = travFindIndexOfFirstItemToNotSatisfyPredicate(source, p) {
        return travTake(source, firstIndex)
    }
    return source
}

/**
:returns: A Traversable of the same type containing the first n elements. Note: might return different results for different runs if the underlying collection type is unordered.
*/
public func travTake<S: Traversable>(source: S, n: Int) -> S {
    return travDropRight(source, travSize(source) - n)
}

/**
:returns: A Traversable containing the last n elements. Note: might return different results for different runs if the underlying collection type is unordered.
*/
public func travTakeRight<S: Traversable>(source: S, n: Int) -> S {
    return travDrop(source, travSize(source) - n)
}

/**
:returns: The first element of the Traversable or a nil if it's empty. Note: might return different results for different runs if the underlying collection type is unordered.
*/
public func travHead<S: Traversable>(source: S) -> S.ItemType? {
    if travNonEmpty(source) {
        return travReduce(travTake(source, 1), nil, { (item: S.ItemType?, currentItem) -> S.ItemType? in currentItem })
    }
    return nil
}

/**
:returns: Returns a new Traversable containing all the elements of the provided one except for the first element. Note: might return different results for different runs, if the underlying collection type is unordered.
*/
public func travTail<S: Traversable>(source: S) -> S {
    return travDrop(source, 1)
}

/**
:returns: All the elements of this Traversable except the last one. Note: might return different results for different runs if the underlying collection type is unordered.
*/
public func travInit<S: Traversable>(source: S) -> S {
    return travDropRight(source, 1)
}

/**
:returns: Returns a tuple containing the results of splitting the Traversable at the given position (equivalent to: (take n, drop n)). Note: might return different results for different runs if the underlying collection type is unordered.
*/
public func travSplitAt<S: Traversable>(source: S, n: Int) -> (S, S) {
    return (travTake(source, n), travDrop(source, n))
}

/**
:returns: Returns a tuple containing the results of splitting the Traversable according to a predicate. The first traversable in the tuple contains those elements which satisfy the predicate, while the second contains those which don't. Equivalent to (travFilter, travFilterNot).
*/
public func travPartition<S: Traversable>(source: S, p: (S.ItemType) -> Bool) -> (S, S) {
    return (travFilter(source, p), travFilterNot(source, p))
}

/**
:returns: Returns a tuple containing the results of splitting the Traversable according to a predicate. The first traversable in the tuple contains the first elements that satisfy the predicate `p`, while the second contains all elements after those. Equivalent to (travTakeWhile, travDropWhile). Note: might return different results for different runs if the underlying collection type is unordered.
*/
public func travSpan<S: Traversable>(source: S, p: (S.ItemType) -> Bool) -> (S, S) {
    return (travTakeWhile(source, p), travDropWhile(source, p))
}

/**
Returns an array containing the results of mapping the partial function `f` over a set of the elements of this Traversable that match the condition defined in `f`'s `isDefinedAt`.
*/
public func travCollect<S, U where S: Traversable>(source: S, f: PartialFunction<S.ItemType, U>) -> [U] {
    return travReduce(source, Array<U>(), { (total : [U], currentItem : S.ItemType) -> [U] in
        if f.isDefinedAt.apply(currentItem) == true {
            return total + [f.function.apply(currentItem)]
        }
        return total
    })
}

/**
Partitions this Traversable into a map of Traversables according to some discriminator function defined by the function `f`. `f` should return a HashableAny for groupBy be able to build the map.

It's possible to use complex computations made of partial functions (using |||> `orElse` and >>> `andThen` operators), and pattern matching with the use of `match`, in the place of `f`. i.e., being `pfA`, `pfB`, `pfC` and `pfD` several partial functions that take a certain value and return a HashableAny, it's possible to group a traversable the following ways:

* travGroupBy(source, pfa |||> pfb)

* travGroupBy(source, (pfa |||> pfb) >>> pfc)

* travGroupBy(source, match(pfa, pfb, pfc, pfd))

*/
public func travGroupBy<S: Traversable>(source: S, f: Function<S.ItemType, HashableAny>) -> Map<S> {
    return travReduce(source, Map<S>()) { (currentMap: Map<S>, currentItem: S.ItemType) -> Map<S> in
        let key = f.apply(currentItem)
        var nextMap = currentMap
        if let travForThisKey = currentMap[key] {
            var array = travToArray(travForThisKey)
            array = array + [currentItem]
            nextMap[key] = S.build(array)
        } else {
            nextMap[key] = S.build([currentItem])
        }
        return nextMap
    }
}

/**
Returns the number of elements of this Traversable satisfy the given predicate.
*/
public func travCount<S: Traversable>(source: S, p: (S.ItemType) -> Bool) -> Int {
    return travSize(travFilter(source, p))
}

/**
Returns true if all the elements of this Traversable satisfy the given predicate.
*/
public func travForAll<S: Traversable>(source: S, p: (S.ItemType) -> Bool) -> Bool {
    return travCount(source, p) == travSize(source)
}

/**
Returns true if at least one of its elements of this Traversable satisfy the given predicate.
*/
public func travExists<S: Traversable>(source: S, p: (S.ItemType) -> Bool) -> Bool {
     return travCount(source, p) > 0
}
