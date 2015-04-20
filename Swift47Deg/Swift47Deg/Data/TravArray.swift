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

/// TravArray | An immutable and traversable Array containing elements of type T.
public struct TravArray<T> {
    private var internalArray : Array<T>
    
    public subscript(index: Int) -> T? {
        get {
            return (index < internalArray.count) ? internalArray[index] : nil
        }
    }
}

extension TravArray : ArrayLiteralConvertible {
    public init(arrayLiteral elements: T...) {
        internalArray = elements
    }
    
    public init(_ elements: Array<T>) {
        internalArray = elements
    }
}

extension TravArray : SequenceType {
    public typealias Generator = GeneratorOf<T>
    
    public func generate() -> Generator {
        var index : Int = 0
        
        return Generator {
            if index < self.internalArray.count {
                let result = self.internalArray[index]
                index++
                return result
            }
            return nil
        }
    }
}

extension TravArray {
    /**
    Returns a new TravArray with the current contents and the provided item on top.
    */
    public func append(item: T) -> TravArray<T> {
        var result = internalArray
        result.append(item)
        return TravArray<T>(result)
    }
    
    /**
    Returns the last item of the TravArray, if any.
    */
    public func last() -> T? {
        return internalArray.last
    }
    
    /**
    Returns the number of items contained in the TravArray.
    */
    public func size() -> Int {
        return internalArray.count
    }
}

extension TravArray : Traversable {
    typealias ItemType = T
    public func foreach(f: (T) -> ()) {
        for item in self.internalArray {
            f(item)
        }
    }
    
    /**
    Build a new TravArray instance with the elements contained in the `elements` array.
    */
    public static func build(elements: [ItemType]) -> TravArray<T> {
        return TravArray<T>(elements)
    }
    
    /**
    Build a new TravArray instance with the elements contained in the provided Traversable instance. The provided traversable is expected to contain
    items with the same type as the Stack struct. Items of different types will be discarded.
    */
    public static func buildFromTraversable<U where U : Traversable>(traversable: U) -> TravArray {
        return reduceT(traversable, TravArray()) { (result, item) -> TravArray in
            switch item {
            case let sameTypeItem as T: result.append(sameTypeItem)
            default: break
            }
            return result
        }
    }
}

extension TravArray : Iterable {
    
}

extension TravArray {
    func toArray() -> Array<T> {
        var internalArray = self.internalArray
        return internalArray
    }
}

// MARK: - Traversable functions accesors
extension TravArray {
    
    /**
    Returns the result of repeatedly calling combine with an accumulated value initialized to `initial` and each element of the current TravArray.
    */
    public func reduce<U>(initialValue: U, combine: (U, T) -> U) -> U {
        return reduceT(self, initialValue, combine)
    }
    
    /**
    Returns an array containing the results of mapping `transform` over the elements of the current TravArray.
    */
    public func map<U>(transform: (T) -> U) -> [U] {
        return mapT(self, transform)
    }
    
    /**
    Returns a new TravArray containing the results of mapping `transform` over its elements. The resulting elements are guaranteed to be the same type as the items of the provided one.
    */
    public func mapConserve(transform: (T) -> T) -> TravArray {
        return mapConserveT(self, transform)
    }
    
    /**
    Returns a TravArray containing all the values from the current one that satisfy the `includeElement` closure.
    */
    public func filter(includeElement: (T) -> Bool) -> TravArray {
        return filterT(self, includeElement)
    }
    
    /**
    Returns a new TravArray containing all the values from the current one except those that satisfy the `excludeElement` closure.
    */
    public func filterNot(excludeElement: (T) -> Bool) -> TravArray {
        return filterNotT(self, excludeElement)
    }
    
    /**
    Returns the result of applying `transform` on each element of the TravArray, and then flattening the results into an array.
    */
    public func flatMap<U>(transform: (T) -> [U]) -> [U] {
        return flatMapT(self, transform)
    }
    
    /**
    Returns a new TravArray with elements in inverse order than the current one.
    */
    public func reverse() -> TravArray {
        return reverseT(self)
    }
    
    /**
    Returns the result of repeatedly calling combine with an accumulated value initialized to `initial` and each element of the current TravArray from left to right. Equivalent to `reduce`.
    */
    public func foldRight<U>(initialValue: U, combine: (U, T) -> U) -> U {
        return foldRightT(self, initialValue, combine)
    }
    
    /**
    Returns the result of repeatedly calling combine with an accumulated value initialized to `initial` and each element of the current TravArray from right to left. A reversal equivalent to `reduce`/`foldLeft`.
    */
    public func foldLeft<U>(initialValue: U, combine: (U, T) -> U) -> U {
        return foldLeftT(self, initialValue, combine)
    }
    
    /**
    Returns a list containing the elements of this TravArray.
    */
    public func toList() -> TravList<T> {
        return toListT(self)
    }
    
    /**
    Returns a string representation of all the elements within the TravArray, without any separation between them.
    */
    public func mkString() -> String {
        return mkStringT(self)
    }
    
    /**
    Returns a string representation of all the elements within the TravArray, separated by the provided separator.
    */
    public func mkString(separator: String) -> String {
        return mkStringT(self, separator)
    }
    
    /**
    Returns a string representation of all the elements within the TravArray, separated by the provided separator and enclosed by the `start` and `end` strings.
    */
    public func mkString(start: String, separator: String, end: String) -> String {
        return mkStringT(self, start, separator, end)
    }
    
    /**
    Returns true if this TravArray doesn't contain any elements.
    */
    public func isEmpty() -> Bool {
        return isEmptyT(self)
    }
    
    /**
    Returns true if this TravArray contains elements.
    */
    public func nonEmpty() -> Bool {
        return nonEmptyT(self)
    }
    
    /**
    Returns the first element of this TravArray that satisfy the given predicate `p`, if any.
    */
    public func find(p: (T) -> Bool) -> T? {
        return findT(self, p)
    }
    
    /**
    Returns a new Stack containing all the elements from the current TravArray except the first `n` ones.
    */
    public func drop(n: Int) -> TravArray {
        return dropT(self, n)
    }
    
    /**
    Returns a new TravArray containing all the elements from the current TravArray except the last `n` ones.
    */
    public func dropRight(n: Int) -> TravArray {
        return dropRightT(self, n)
    }
    
    /**
    Returns the longest prefix of this TravArray whose first element does not satisfy the predicate p.
    */
    public func dropWhile(p: (T) -> Bool) -> TravArray {
        return dropWhileT(self, p)
    }
    
    /**
    :returns: A new TravArray containing the first `n` elements of the current one.
    */
    public func take(n: Int) -> TravArray {
        return takeT(self, n)
    }
    
    /**
    :returns: A new TravArray containing the last `n` elements of the current one.
    */
    public func takeRight(n: Int) -> TravArray {
        return takeRightT(self, n)
    }
    
    /**
    Returns the longest prefix of elements that satisfy the predicate `p`.
    */
    public func takeWhile(p: (T) -> Bool) -> TravArray {
        return takeWhileT(self, p)
    }
    
    /**
    :returns: The first element of the TravArray, if any.
    */
    public func head() -> T? {
        return headT(self)
    }
    
    /**
    :returns: Returns a new TravArray containing all the elements of the provided one except for the first element.
    */
    public func tail() -> TravArray {
        return tailT(self)
    }
    
    /**
    :returns: All the elements of this TravArray except the last one.
    */
    public func initSegment() -> TravArray {
        return initT(self)
    }
    
    /**
    Returns a new TravArray made of the elements from the current one which satisfy the invariant:
    
    from <= indexOf(x) < until
    
    Note: If `endIndex` is out of range within the TravArray, sliceT will throw an exception.
    */
    public func slice(from startIndex: Int, until endIndex: Int) -> TravArray {
        return sliceT(self, from: startIndex, until: endIndex)
    }
    
    /**
    :returns: Returns a tuple containing the results of splitting the TravArray at the given position (equivalent to: (take n, drop n)).
    */
    public func splitAt(n: Int) -> (TravArray, TravArray) {
        return splitAtT(self, n)
    }
    
    /**
    :returns: Returns a tuple containing the results of splitting the TravArray according to a predicate `p`. The first array in the tuple contains those elements which satisfy the predicate, while the second contains those which don't. Equivalent to (filter, filterNot).
    */
    public func partition(p: (T) -> Bool) -> (TravArray, TravArray) {
        return partitionT(self, p)
    }
    
    /**
    Returns an array containing the results of mapping the partial function `f` over a set of the elements of this TravArray that match the condition defined in `f`'s `isDefinedAt`.
    */
    public func collect<U>(f: PartialFunction<T, U>) -> [U] {
        return collectT(self, f)
    }
    
    /**
    Partitions this TravArray into a map of TravArrays according to some discriminator function defined by the function `f`. `f` should return a HashableAny for groupBy to be able to build the map.
    
    It's possible to use complex computations made of partial functions (using |||> `orElse` and >>> `andThen` operators), and pattern matching with the use of `match` in the place of `f`. i.e., being `pfA`, `pfB`, `pfC` and `pfD` several partial functions that take a certain value and return a HashableAny, it's possible to group a TravArray the following ways:
    
    * array.groupBy(pfa |||> pfb)
    
    * array.groupBy((pfa |||> pfb) >>> pfc)
    
    * array.groupBy(match(pfa, pfb, pfc, pfd))
    
    */
    public func groupBy(f: Function<T, HashableAny>) -> Map<TravArray> {
        return groupByT(self, f)
    }
    
    /**
    Returns the number of elements of this TravArray satisfy the given predicate.
    */
    public func count(p: (T) -> Bool) -> Int {
        return countT(self, p)
    }
    
    /**
    Returns true if all the elements of this TravArray satisfy the given predicate.
    */
    public func forAll(p: (T) -> Bool) -> Bool {
        return forAllT(self, p)
    }
    
    /**
    Returns true if at least one of its elements of this TravArray satisfy the given predicate.
    */
    public func exists(p: (T) -> Bool) -> Bool {
        return existsT(self, p)
    }
    
    /**
    Returns a new TravArray containing all the elements from the provided one, but sorted by a predicate `p`.
    
    :param: p Closure returning true if the first element should be ordered before the second.
    */
    public func sortWith(p: (T, T) -> Bool) -> TravArray {
        return sortWithT(self, p)
    }
    
    /**
    Returns a new TravArray containing all the elements from the two provided TravArray.
    */
    public func union(a: TravArray, b: TravArray) -> TravArray {
        return unionT(a, b)
    }
}