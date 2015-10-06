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

/// ArrayT | An immutable and traversable Array containing elements of type T.
public struct ArrayT<T> {
    private var internalArray : Array<T>
    
    public subscript(index: Int) -> T? {
        get {
            return (index < internalArray.count) ? internalArray[index] : nil
        }
    }
}

extension ArrayT : ArrayLiteralConvertible {
    public init(arrayLiteral elements: T...) {
        internalArray = elements
    }
    
    public init(_ elements: Array<T>) {
        internalArray = elements
    }
}

extension ArrayT : SequenceType {
    public typealias Generator = AnyGenerator<T>
    
    public func generate() -> Generator {
        var index : Int = 0
        
        return anyGenerator {
            if index < self.internalArray.count {
                let result = self.internalArray[index]
                index++
                return result
            }
            return nil
        }
    }
}

extension ArrayT {
    /**
    Returns a new ArrayT with the current contents and the provided item on top.
    */
    public func append(item: T) -> ArrayT<T> {
        var result = internalArray
        result.append(item)
        return ArrayT<T>(result)
    }
    
    /**
    Returns the last item of the ArrayT, if any.
    */
    public func last() -> T? {
        return internalArray.last
    }
    
    /**
    Returns the number of items contained in the ArrayT.
    */
    public func size() -> Int {
        return internalArray.count
    }
}

extension ArrayT : Traversable {
    public typealias ItemType = T
    public func foreach(f: (T) -> ()) {
        for item in self.internalArray {
            f(item)
        }
    }
    
    /**
    Build a new ArrayT instance with the elements contained in the `elements` array.
    */
    public static func build(elements: [ItemType]) -> ArrayT<T> {
        return ArrayT<T>(elements)
    }
    
    /**
    Build a new ArrayT instance with the elements contained in the provided Traversable instance. The provided traversable is expected to contain
    items with the same type as the Stack struct. Items of different types will be discarded.
    */
    public static func buildFromTraversable<U where U : Traversable>(traversable: U) -> ArrayT {
        return reduceT(traversable, initialValue: ArrayT()) { (result, item) -> ArrayT in
            switch item {
            case let sameTypeItem as T: result.append(sameTypeItem)
            default: break
            }
            return result
        }
    }
}

extension ArrayT : Iterable {
    
}

extension ArrayT : CustomDebugStringConvertible, CustomStringConvertible {
    public var description : String {
        get {
            return internalArray.description
        }
    }
    
    public var debugDescription : String {
        get {
            return internalArray.debugDescription
        }
    }
}

extension ArrayT {
    func toArray() -> Array<T> {
        let internalArray = self.internalArray
        return internalArray
    }
}

// MARK: - Traversable functions accesors
extension ArrayT {
    /**
    Returns an array containing the results of mapping the partial function `f` over a set of the elements of this ArrayT that match the condition defined in `f`'s `isDefinedAt`.
    */
    public func collect<U>(f: PartialFunction<T, U>) -> [U] {
        return collectT(self, f: f)
    }
    
    /**
    Returns the number of elements of this ArrayT satisfy the given predicate.
    */
    public func count(p: (T) -> Bool) -> Int {
        return countT(self, p: p)
    }
    
    /**
    Returns a new Stack containing all the elements from the current ArrayT except the first `n` ones.
    */
    public func drop(n: Int) -> ArrayT {
        return dropT(self, n: n)
    }
    
    /**
    Returns a new ArrayT containing all the elements from the current ArrayT except the last `n` ones.
    */
    public func dropRight(n: Int) -> ArrayT {
        return dropRightT(self, n: n)
    }
    
    /**
    Returns the longest prefix of this ArrayT whose first element does not satisfy the predicate p.
    */
    public func dropWhile(p: (T) -> Bool) -> ArrayT {
        return dropWhileT(self, p: p)
    }
    
    /**
    Returns true if at least one of its elements of this ArrayT satisfy the given predicate.
    */
    public func exists(p: (T) -> Bool) -> Bool {
        return existsT(self, p: p)
    }
    
    /**
    Returns a ArrayT containing all the values from the current one that satisfy the `includeElement` closure.
    */
    public func filter(includeElement: (T) -> Bool) -> ArrayT {
        return filterT(self, includeElement: includeElement)
    }
    
    /**
    Returns a new ArrayT containing all the values from the current one except those that satisfy the `excludeElement` closure.
    */
    public func filterNot(excludeElement: (T) -> Bool) -> ArrayT {
        return filterNotT(self, excludeElement: excludeElement)
    }
    
    /**
    Returns the first element of this ArrayT that satisfy the given predicate `p`, if any.
    */
    public func find(p: (T) -> Bool) -> T? {
        return findT(self, p: p)
    }
    
    /**
    Returns the result of applying `transform` on each element of the ArrayT, and then flattening the results into an array.
    */
    public func flatMap<U>(transform: (T) -> [U]) -> [U] {
        return flatMapT(self, transform: transform)
    }
    
    /**
    Returns the result of repeatedly calling combine with an accumulated value initialized to `initial` and each element of the current ArrayT from right to left. A reversal equivalent to `reduce`/`foldLeft`.
    */
    public func foldLeft<U>(initialValue: U, combine: (U, T) -> U) -> U {
        return foldLeftT(self, initialValue: initialValue, combine: combine)
    }
    
    /**
    Returns the result of repeatedly calling combine with an accumulated value initialized to `initial` and each element of the current ArrayT from left to right. Equivalent to `reduce`.
    */
    public func foldRight<U>(initialValue: U, combine: (U, T) -> U) -> U {
        return foldRightT(self, initialValue: initialValue, combine: combine)
    }
    
    /**
    Returns true if all the elements of this ArrayT satisfy the given predicate.
    */
    public func forAll(p: (T) -> Bool) -> Bool {
        return forAllT(self, p: p)
    }
    
    /**
    Partitions this ArrayT into a map of ArrayTs according to some discriminator function defined by the function `f`. `f` should return a HashableAny for groupBy to be able to build the map.
    
    It's possible to use complex computations made of partial functions (using |||> `orElse` and >>> `andThen` operators), and pattern matching with the use of `match` in the place of `f`. i.e., being `pfA`, `pfB`, `pfC` and `pfD` several partial functions that take a certain value and return a HashableAny, it's possible to group a ArrayT the following ways:
    
    * array.groupBy(pfa |||> pfb)
    
    * array.groupBy((pfa |||> pfb) >>> pfc)
    
    * array.groupBy(match(pfa, pfb, pfc, pfd))
    */
    public func groupBy(f: Function<T, HashableAny>) -> Map<ArrayT> {
        return groupByT(self, f: f)
    }
    
    /**
    - returns: The first element of the ArrayT, if any.
    */
    public func head() -> T? {
        return headT(self)
    }
    
    /**
    - returns: All the elements of this ArrayT except the last one.
    */
    public func initSegment() -> ArrayT {
        return initT(self)
    }
    
    /**
    Returns true if this ArrayT doesn't contain any elements.
    */
    public func isEmpty() -> Bool {
        return isEmptyT(self)
    }
    
    /**
    Returns an array containing the results of mapping `transform` over the elements of the current ArrayT.
    */
    public func map<U>(transform: (T) -> U) -> [U] {
        return mapT(self, transform: transform)
    }
    
    /**
    Returns a new ArrayT containing the results of mapping `transform` over its elements. The resulting elements are guaranteed to be the same type as the items of the provided one.
    */
    public func mapConserve(transform: (T) -> T) -> ArrayT {
        return mapConserveT(self, transform: transform)
    }
    
    /**
    Returns a string representation of all the elements within the ArrayT, without any separation between them.
    */
    public func mkString() -> String {
        return mkStringT(self)
    }
    
    /**
    Returns a string representation of all the elements within the ArrayT, separated by the provided separator.
    */
    public func mkString(separator: String) -> String {
        return mkStringT(self, separator: separator)
    }
    
    /**
    Returns a string representation of all the elements within the ArrayT, separated by the provided separator and enclosed by the `start` and `end` strings.
    */
    public func mkString(start: String, separator: String, end: String) -> String {
        return mkStringT(self, start: start, separator: separator, end: end)
    }
    
    /**
    Returns true if this ArrayT contains elements.
    */
    public func nonEmpty() -> Bool {
        return nonEmptyT(self)
    }
    
    /**
    - returns: Returns a tuple containing the results of splitting the ArrayT according to a predicate `p`. The first array in the tuple contains those elements which satisfy the predicate, while the second contains those which don't. Equivalent to (filter, filterNot).
    */
    public func partition(p: (T) -> Bool) -> (ArrayT, ArrayT) {
        return partitionT(self, p: p)
    }
    
    /**
    Returns the result of repeatedly calling combine with an accumulated value initialized to `initial` and each element of the current ArrayT.
    */
    public func reduce<U>(initialValue: U, combine: (U, T) -> U) -> U {
        return reduceT(self, initialValue: initialValue, combine: combine)
    }
    
    /**
    Returns a new ArrayT with elements in inverse order than the current one.
    */
    public func reverse() -> ArrayT {
        return reverseT(self)
    }
    
    /**
    Returns a new ArrayT made of the elements from the current one which satisfy the invariant:
    
    from <= indexOf(x) < until
    
    Note: If `endIndex` is out of range within the ArrayT, sliceT will throw an exception.
    */
    public func slice(from startIndex: Int, until endIndex: Int) -> ArrayT {
        return sliceT(self, from: startIndex, until: endIndex)
    }
    
    /**
    Returns a new ArrayT containing all the elements from the provided one, but sorted by a predicate `p`.
    
    - parameter p: Closure returning true if the first element should be ordered before the second.
    */
    public func sortWith(p: (T, T) -> Bool) -> ArrayT {
        return sortWithT(self, p: p)
    }
    
    /**
    - returns: Returns a tuple containing the results of splitting the ArrayT according to a predicate. The first traversable in the tuple contains the first elements that satisfy the predicate `p`, while the second contains all elements after those. Equivalent to (takeWhileT, dropWhileT).
    */
    public func span(p: (T) -> Bool) -> (ArrayT, ArrayT) {
        return spanT(self, p: p)
    }
    
    /**
    - returns: Returns a tuple containing the results of splitting the ArrayT at the given position (equivalent to: (take n, drop n)).
    */
    public func splitAt(n: Int) -> (ArrayT, ArrayT) {
        return splitAtT(self, n: n)
    }
    
    /**
    - returns: Returns a new ArrayT containing all the elements of the provided one except for the first element.
    */
    public func tail() -> ArrayT {
        return tailT(self)
    }
    
    /**
    - returns: A new ArrayT containing the first `n` elements of the current one.
    */
    public func take(n: Int) -> ArrayT {
        return takeT(self, n: n)
    }
    
    /**
    - returns: A new ArrayT containing the last `n` elements of the current one.
    */
    public func takeRight(n: Int) -> ArrayT {
        return takeRightT(self, n: n)
    }
    
    /**
    Returns the longest prefix of elements that satisfy the predicate `p`.
    */
    public func takeWhile(p: (T) -> Bool) -> ArrayT {
        return takeWhileT(self, p: p)
    }
    
    /**
    Returns a list containing the elements of this ArrayT.
    */
    public func toList() -> ListT<T> {
        return toListT(self)
    }
    
    /**
    Returns a new ArrayT containing all the elements from the two provided ArrayT.
    */
    public func union(a: ArrayT, b: ArrayT) -> ArrayT {
        return unionT(a, b: b)
    }
}