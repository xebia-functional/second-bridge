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
Datatypes conforming to this protocol should expose certain functions that allow to traverse through them, and also being built from other Traversable types (although the latter has some limitations due to Swift type constraints restrictions). All Traversable instances have access to the methods declared in this protocol.
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
public func reduceT<S: Traversable, U>(source: S, initialValue: U, combine: (U, S.ItemType) -> U) -> U {
    var result = initialValue
    source.foreach { (item: S.ItemType) -> () in
        result = combine(result, item)
        return ()
    }
    return result
}

/**
Returns an array containing the results of mapping `transform` over the elements of the provided Traversable.
*/
public func mapT<S: Traversable, U>(source: S, transform: (S.ItemType) -> U) -> [U] {
    return reduceT(source, Array<U>()) { (total, item) -> [U] in
        total + [transform(item)]
    }
}

/**
Returns a traversable containing the results of mapping `transform` over its elements. The resulting elements are guaranteed to be the same type as the items of the provided traversable.
*/
public func mapConserveT<S: Traversable>(source: S, transform: (S.ItemType) -> S.ItemType) -> S {
    return S.build(reduceT(source, Array<S.ItemType>()) { (total, item) -> [S.ItemType] in
        total + [transform(item)]
    })
}

/**
Returns a Traversable containing all the values from the current traversable that satisfy the `includeElement` closure.
*/
public func filterT<S: Traversable>(source: S, includeElement: (S.ItemType) -> Bool) -> S {
    return S.build(reduceT(source, Array<S.ItemType>()) { (filtered, item) -> [S.ItemType] in
        includeElement(item) ? filtered + [item] : filtered
    })
}

/**
Returns an array containing all the values from the current traversable except those that satisfy the `excludeElement` closure.
*/
public func filterNotT<S: Traversable>(source: S, excludeElement: (S.ItemType) -> Bool) -> S {
    return S.build(reduceT(source, Array<S.ItemType>()) { (filtered, item) -> [S.ItemType] in
        !excludeElement(item) ? filtered + [item] : filtered
    })
}

/**
Returns the result of applying `transform` on each element of the traversable, and then flattening the results into an array. You can create a new Traversable from the results of the flatMap application by calling function Traversable.build and passing its results to it.
*/
public func flatMapT<S: Traversable, U>(source: S, transform: (S.ItemType) -> [U]) -> [U] {
    return reduceT(source, Array<U>()) { (total, item) -> [U] in
        total + transform(item)
    }
}

/**
Returns a traversable with elements in inverse order. Note: it won't produce a correct result when applied to non-ordered traversables.
*/
public func reverseT<S: Traversable>(source: S) -> S {
    return S.build(reduceT(source, Array<S.ItemType>(), { (total, item) -> [S.ItemType] in
        [item] + total
    }))
}

/**
Returns the result of repeatedly calling combine with an accumulated value initialized to `initial` and each element of the current traversable from left to right. Equivalent to `reduceT`.
*/
public func foldRightT<S: Traversable, U>(source: S, initialValue: U, combine: (U, S.ItemType) -> U) -> U {
    return reduceT(source, initialValue, combine)
}

/**
Returns the result of repeatedly calling combine with an accumulated value initialized to `initial` and each element of the current traversable from right to left. A reversal equivalent to `reduceT`/`foldLeftT`.
*/
public func foldLeftT<S: Traversable, U>(source: S, initialValue: U, combine: (U, S.ItemType) -> U) -> U {
    let array = toArrayT(source)
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
public func toArrayT<S: Traversable>(source: S) -> [S.ItemType] {
    return reduceT(source, Array<S.ItemType>(), { (total, item) -> [S.ItemType] in
        total + [item]
    })
}

/**
Returns a list containing the elements of this Traversable.
*/
public func toListT<S: Traversable>(source: S) -> TravList<S.ItemType> {
    return reduceT(source, TravList<S.ItemType>(), { (list : TravList<S.ItemType>, item : S.ItemType) -> TravList<S.ItemType> in
        return list.append(item)
    })
}

/**
Returns a string representation of all the elements within the Traversable, without any separation between them.
*/
public func mkStringT<S: Traversable>(source: S) -> String {
    return mkStringT(source, "", "", "")
}

/**
Returns a string representation of all the elements within the Traversable, separated by the provided separator.
*/
public func mkStringT<S: Traversable>(source: S, separator: String) -> String {
    return mkStringT(source, "", separator, "")
}

/**
Returns a string representation of all the elements within the Traversable, separated by the provided separator and enclosed by the `start` and `end` strings.
*/
public func mkStringT<S: Traversable>(source: S, start: String, separator: String, end: String) -> String {
    let reduceString = reduceT(source, start, { (result: String, item: S.ItemType) -> String in
        return result + "\(item)" + separator
    })
    switch (start, separator, end) {
    case ("", "", ""): return reduceString
    default: return reduceString.substringToIndex(reduceString.endIndex.predecessor()) + end
    }    
}

/**
Returns true if this Traversable doesn't contain any elements.
*/
public func isEmptyT<S: Traversable>(source: S) -> Bool {
    var result = true
    source.foreach { (item) -> () in
        result = false
    }
    return result
}

/**
Returns the number of elements contained in this Traversable.
*/
public func sizeT<S: Traversable>(source: S) -> Int {
    return reduceT(source, 0) { (total, item) -> Int in
        return total + 1
    }
}

/**
Returns true if this Traversable contains elements.
*/
public func nonEmptyT<S: Traversable>(source: S) -> Bool {
    return !isEmptyT(source)
}

/**
Returns the first element of this Traversable that satisfy the given predicate `p`, if any.
*/
public func findT<S: Traversable>(source: S, p: (S.ItemType) -> Bool) -> S.ItemType? {
    return reduceT(source, nil) { (result, item) -> S.ItemType? in
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
public func dropT<S: Traversable>(source: S, n: Int) -> S {
    if nonEmptyT(source) {
        let result = S.build(foldLeftT(source, (sizeT(source), Array<S.ItemType>()), { (result: (index: Int, array: [S.ItemType]), currentItem) -> (Int, [S.ItemType]) in
            if result.index > n {
                var resultArray = result.array
                resultArray = resultArray + [currentItem]
                return (result.index - 1, resultArray)
            }
            return result
        }).1)
        return reverseT(result)
    }
    return source
}

/**
Selects all elements except the last n ones. Note: might return different results for different runs, as the underlying collection type is unordered.

:param: source Traversable containing the elements to be selected
:param: n Number of elements to be excluded from the selection

:returns: A new Traversable of the same type as `source` containing the elements from the selection
*/
public func dropRightT<S: Traversable>(source: S, n: Int) -> S {
    if nonEmptyT(source) {
        let size = sizeT(source)
        return S.build(foldRightT(source, (0, Array<S.ItemType>()), { (result: (index: Int, array: [S.ItemType]), currentItem) -> (Int, [S.ItemType]) in
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

private func findIndexOfFirstItemToNotSatisfyPredicate<S: Traversable>(source: S, p: (S.ItemType) -> Bool) -> Int? {
    let result = reduceT(source, (0, false)) { (result: (count: Int, didFindItem: Bool), item) -> (Int, Bool) in
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
Drops the longest prefix of elements that satisfy a predicate. Note: might return different results for different runs if the underlying collection type is unordered.

:param: source Traversable containing the elements to be selected.
:param: p Predicate to match the elements to.

:returns: The longest prefix of this Traversable whose first element does not satisfy the predicate p.
*/
public func dropWhileT<S: Traversable>(source: S, p: (S.ItemType) -> Bool) -> S {
    if let firstIndex = findIndexOfFirstItemToNotSatisfyPredicate(source, p) {
        return dropT(source, firstIndex)
    }
    return source
}

/**
Takes the longest prefix of elements that satisfy a predicate. Note: might return different results for different runs if the underlying collection type is unordered.

:param: source Traversable containing the elements to be selected.
:param: p Predicate to match the elements to.

:returns: The longest prefix of elements that satisfy the predicate p.
*/
public func takeWhileT<S: Traversable>(source: S, p: (S.ItemType) -> Bool) -> S {
    if let firstIndex = findIndexOfFirstItemToNotSatisfyPredicate(source, p) {
        return takeT(source, firstIndex)
    }
    return source
}

/**
:returns: A Traversable of the same type containing the first n elements. Note: might return different results for different runs if the underlying collection type is unordered.
*/
public func takeT<S: Traversable>(source: S, n: Int) -> S {
    return dropRightT(source, sizeT(source) - n)
}

/**
:returns: A Traversable containing the last n elements. Note: might return different results for different runs if the underlying collection type is unordered.
*/
public func takeRightT<S: Traversable>(source: S, n: Int) -> S {
    return dropT(source, sizeT(source) - n)
}

/**
:returns: The first element of the Traversable or a nil if it's empty. Note: might return different results for different runs if the underlying collection type is unordered.
*/
public func headT<S: Traversable>(source: S) -> S.ItemType? {
    if nonEmptyT(source) {
        return reduceT(takeT(source, 1), nil, { (item: S.ItemType?, currentItem) -> S.ItemType? in currentItem })
    }
    return nil
}

/**
:returns: Returns a new Traversable containing all the elements of the provided one except for the first element. Note: might return different results for different runs, if the underlying collection type is unordered.
*/
public func tailT<S: Traversable>(source: S) -> S {
    return dropT(source, 1)
}

/**
:returns: All the elements of this Traversable except the last one. Note: might return different results for different runs if the underlying collection type is unordered.
*/
public func initT<S: Traversable>(source: S) -> S {
    return dropRightT(source, 1)
}

/**
:returns: The last element of the Traversable or a nil if it's empty. Note: might return different results for different runs if the underlying collection type is unordered.
*/
public func lastT<S: Traversable>(source: S) -> S.ItemType? {
    return headT(takeRightT(source, 1))
}

/**
Returns a Traversable made of the elements from `source` which satisfy the invariant:

from <= indexOf(x) < until

Note: might return different results for different runs, unless the underlying collection type is ordered. If `endIndex` is out of range within the Traversable, sliceT will throw an exception.
*/
public func sliceT<S: Traversable>(source: S, from startIndex: Int, until endIndex: Int) -> S {
    let size = sizeT(source)
    switch size {
    case 0: return source
    case _ where endIndex > size: assertionFailure("SliceT: end index out of range")
    default: return S.build(reduceT(source, (0, TravArray<S.ItemType>())) {
        (result: (index: Int, buffer: TravArray<S.ItemType>), currentItem: S.ItemType) -> (Int, TravArray<S.ItemType>) in
        
        let nextIndex = result.index + 1
        
        switch result.index {
        case _ where result.index >= startIndex && result.index < endIndex : return (nextIndex, result.buffer.append(currentItem))
        default: return (nextIndex, result.1)
        }
        
        }.1.toArray())
    }
}

/**
:returns: Returns a tuple containing the results of splitting the Traversable at the given position (equivalent to: (takeT n, dropT n)). Note: might return different results for different runs if the underlying collection type is unordered.
*/
public func splitAtT<S: Traversable>(source: S, n: Int) -> (S, S) {
    return (takeT(source, n), dropT(source, n))
}

/**
:returns: Returns a tuple containing the results of splitting the Traversable according to a predicate. The first traversable in the tuple contains those elements which satisfy the predicate, while the second contains those which don't. Equivalent to (filterT, filterNotT). Note: might return different results for different runs if the underlying collection type is unordered.
*/
public func partitionT<S: Traversable>(source: S, p: (S.ItemType) -> Bool) -> (S, S) {
    return (filterT(source, p), filterNotT(source, p))
}

/**
:returns: Returns a tuple containing the results of splitting the Traversable according to a predicate. The first traversable in the tuple contains the first elements that satisfy the predicate `p`, while the second contains all elements after those. Equivalent to (takeWhileT, dropWhileT). Note: might return different results for different runs if the underlying collection type is unordered.
*/
public func spanT<S: Traversable>(source: S, p: (S.ItemType) -> Bool) -> (S, S) {
    return (takeWhileT(source, p), dropWhileT(source, p))
}

/**
Returns an array containing the results of mapping the partial function `f` over a set of the elements of this Traversable that match the condition defined in `f`'s `isDefinedAt`.
*/
public func collectT<S, U where S: Traversable>(source: S, f: PartialFunction<S.ItemType, U>) -> [U] {
    return reduceT(source, Array<U>(), { (total : [U], currentItem : S.ItemType) -> [U] in
        if f.isDefinedAt.apply(currentItem) == true {
            return total + [f.function.apply(currentItem)]
        }
        return total
    })
}

/**
Partitions this Traversable into a map of Traversables according to some discriminator function defined by the function `f`. `f` should return a HashableAny for groupByT to be able to build the map.

It's possible to use complex computations made of partial functions (using |||> `orElse` and >>> `andThen` operators), and pattern matching with the use of `match` in the place of `f`. i.e., being `pfA`, `pfB`, `pfC` and `pfD` several partial functions that take a certain value and return a HashableAny, it's possible to group a traversable the following ways:

* groupByT(source, pfa |||> pfb)

* groupByT(source, (pfa |||> pfb) >>> pfc)

* groupByT(source, match(pfa, pfb, pfc, pfd))

*/
public func groupByT<S: Traversable>(source: S, f: Function<S.ItemType, HashableAny>) -> Map<S> {
    return reduceT(source, Map<S>()) { (currentMap: Map<S>, currentItem: S.ItemType) -> Map<S> in
        let key = f.apply(currentItem)
        var nextMap = currentMap
        if let travForThisKey = currentMap[key] {
            var array = toArrayT(travForThisKey)
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
public func countT<S: Traversable>(source: S, p: (S.ItemType) -> Bool) -> Int {
    return sizeT(filterT(source, p))
}

/**
Returns true if all the elements of this Traversable satisfy the given predicate.
*/
public func forAllT<S: Traversable>(source: S, p: (S.ItemType) -> Bool) -> Bool {
    return countT(source, p) == sizeT(source)
}

/**
Returns true if at least one of its elements of this Traversable satisfy the given predicate.
*/
public func existsT<S: Traversable>(source: S, p: (S.ItemType) -> Bool) -> Bool {
     return countT(source, p) > 0
}

/**
Returns a new Traversable containing all the elements from the provided one, but sorted by a predicate `p`.

:param: source Traversable to be sorted
:param: p Closure returning true if the first element should be ordered before the second.
*/
public func sortWithT<S: Traversable>(source: S, p: (S.ItemType, S.ItemType) -> Bool) -> S {
    var array = toArrayT(source)
    array.sort(p)
    return S.build(array)
}

/**
Returns a new Traversable containing all the elements from the two provided Traversables. Note: if the Traversable type has restrictions on append operations (i.e.: Maps can't contain two elements with the same key), elements from `b` will prevail over `a`'s.
*/
public func unionT<S: Traversable>(a: S, b: S) -> S {
    var tempA = toArrayT(a)
    let resultArray = tempA + toArrayT(b)
    return S.build(resultArray)
}