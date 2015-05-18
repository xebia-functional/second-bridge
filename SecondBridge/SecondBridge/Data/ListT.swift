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

/// ListT | An immutable and traversable List containing elements of type T.
public struct ListT<T> {
    
    private var internalList : List<T>
    
    public subscript(index: UInt) -> T? {
        return internalList[index]
    }
}

//Operators

public func ==<T : Equatable>(lhs: ListT<T> , rhs: ListT<T> ) -> Bool {
    return lhs.internalList == rhs.internalList
}

public func ==<A,B>(lhs: ListT<A> , rhs: ListT<B> ) -> Bool {
    return lhs.length() == 0 && rhs.length() == 0
}

extension ListT {
    
    /**
    Returns a new ListT with the current contents and the provided item on top.
    */
    public func append(item: T) -> ListT<T> {
        var result = internalList
        return ListT(result.append([item]))
    }
    
    /**
    Returns a new ListT with the provided array as parameter.
    */
    public func arrayToList( elements: Array<T>) -> ListT<T> {
        var result = internalList
        for element in elements {
            let l : List = [element]
            result = result + l
        }
        return ListT<T>(result)
    }
    
    
    /**
    Folds the elements of this ListT using the specified associative binary operator.
    */
    public func fold<B>(f : (B, T) -> B, initial : B) -> B {
        switch internalList.match() {
        case .Nil:
            return initial
        case let .Cons(x, xs):
            return xs.reduce(f, initial: f(initial,x))
        }
    }
    /**
    Applies a binary operator to all elements of this ListT and a start value, going right to left.
    */
    public func foldRight<B>(f : (B, T) -> B, initial : B) -> B {
        let a = internalList.reverse()
        switch a.match() {
        case .Nil:
            return initial
        case let .Cons(x, xs):
            return xs.reduce(f, initial: f(initial,x))
        }
    }
    
    /**
    Returns the number of items contained in this ListT.
    */
    public func length() -> UInt {
        return internalList.length()
    }
        
    /**
    Reduces the elements of this ListT using the specified associative binary operator.
    */
    public func reduce<B>(f : (B, T) -> B) -> B? {
        if let head = internalList.head() as? B{
            if let tail = internalList.tail() as Swiftz.List<T>?{
                switch tail.match() {
                case .Nil:
                    return head
                case let .Cons(x, xs):
                    return xs.reduce(f, initial: f(head,x))
                }
            }
            return head
        }
        return nil
    }
    
    /**
    Applies a binary operator to all elements of this sequence, going right to left. Initial parameter is not necessary.
    */
    public func reduceRight<B>(f : (B, T) -> B) -> B? {
        let a = internalList.reverse()
        if let head = a.head() as? B{
            if let tail = a.tail() as Swiftz.List<T>?{
                switch tail.match() {
                case .Nil:
                    return head
                case let .Cons(x, xs):
                    return xs.reduce(f, initial: f(head,x))
                }
            }
            return head
        }
        return nil
    }

    /**
    Applies a binary operator to all elements of this sequence, going right to left.
    */
    public func reduceRight<B>(f : (B, T) -> B, initial : B) -> B {
        let a = internalList.reverse()
        switch a.match() {
        case .Nil:
            return initial
        case let .Cons(x, xs):
            return xs.reduce(f, initial: f(initial,x))
        }
    }    
    
}

// MARK: - Printable

extension ListT: Printable, DebugPrintable {
    public var description : String {
        get {
            return internalList.description
        }
    }
    
    public var debugDescription: String {
        get {
            return internalList.description
        }
    }
}

extension ListT: ArrayLiteralConvertible {
    
    public init(arrayLiteral elements: T...) {
        var listTemp = List<T>()
        for element in elements {
            let l : List = [element]
            listTemp = listTemp + l
        }
        internalList = listTemp
    }
    
    public init(_ elements: List<T>) {
        internalList = elements
    }
    
}


extension ListT: Traversable {
    
    typealias ItemType = T
    
    /**
    Build a new ListT instance with the elements contained in the `elements` array.
    */
    public static func build(elements: [ItemType]) -> ListT<T> {
        var result =  ListT()
        return result.arrayToList(elements)
    }
    
    /**
    Build a new ListT instance with the elements contained in the provided Traversable instance. The provided traversable is expected to contain
    items with the same type as the ListT struct. Items of different types will be discarded.
    */
    public static func buildFromTraversable<U where U : Traversable>(traversable: U) -> ListT {
        return reduceT(traversable, ListT()) { (result, item) -> ListT in
            switch item {
            case let sameTypeItem as T: result.append(sameTypeItem)
            default: break
            }
            return result
        }
        
    }
    
    /**
    Traverse all items of the instance, and call the provided function on each one.
    */
    public func foreach(f: (T) -> ()) {
        for item in self.internalList {
            f(item)
        }
    }
}


// MARK: - Traversable functions accesors
extension ListT {
    
    /**
    Returns an array containing the results of mapping the partial function `f` over a set of the elements of this ListT that match the condition defined in `f`'s `isDefinedAt`.
    */
    public func collect<U>(f: PartialFunction<T, U>) -> [U] {
        return collectT(self, f)
    }
    
    /**
    Returns the number of elements of this ListT satisfy the given predicate.
    */
    public func count(p: (T) -> Bool) -> Int {
        return countT(self, p)
    }
    
    /**
    Returns a new ListT containing all the elements from the current ListT except the first `n` ones.
    */
    public func drop(n: Int) -> ListT {
        return dropT(self, n)
    }
    
    /**
    Returns a new ListT containing all the elements from the current ListT except the last `n` ones.
    */
    public func dropRight(n: Int) -> ListT {
        return dropRightT(self, n)
    }
    
    /**
    Returns the longest prefix of this ListT whose first element does not satisfy the predicate p.
    */
    public func dropWhile(p: (T) -> Bool) -> ListT {
        return dropWhileT(self, p)
    }
    
    /**
    Returns true if at least one of its elements of this ListT satisfy the given predicate.
    */
    public func exists(p: (T) -> Bool) -> Bool {
        return existsT(self, p)
    }
    
    /**
    Returns a ListT containing all the values from the current one that satisfy the `includeElement` closure.
    */
    public func filter(includeElement: (T) -> Bool) -> ListT {
        return filterT(self, includeElement)
    }
    
    /**
    Returns a new ListT containing all the values from the current one except those that satisfy the `excludeElement` closure.
    */
    public func filterNot(excludeElement: (T) -> Bool) -> ListT {
        return filterNotT(self, excludeElement)
    }
    
    /**
    Returns the first element of this ListT that satisfy the given predicate `p`, if any.
    */
    public func find(p: (T) -> Bool) -> T? {
        return findT(self, p)
    }
    
    /**
    Returns the result of applying `transform` on each element of the ListT, and then flattening the results into an array.
    */
    public func flatMap<U>(transform: (T) -> [U]) -> [U] {
        return flatMapT(self, transform)
    }
    
    /**
    Returns the result of repeatedly calling combine with an accumulated value initialized to `initial` and each element of the current ListT from right to left. A reversal equivalent to `reduce`/`foldLeft`.
    */
    public func foldLeft<U>(initialValue: U, combine: (U, T) -> U) -> U {
        return foldLeftT(self, initialValue, combine)
    }
    
    /**
    Returns the result of repeatedly calling combine with an accumulated value initialized to `initial` and each element of the current ListT from left to right. Equivalent to `reduce`.
    */
    public func foldRight<U>(initialValue: U, combine: (U, T) -> U) -> U {
        return foldRightT(self, initialValue, combine)
    }
    
    /**
    Returns true if all the elements of this ListT satisfy the given predicate.
    */
    public func forAll(p: (T) -> Bool) -> Bool {
        return forAllT(self, p)
    }
    
    /**
    Partitions this ListT into a map of ListT according to some discriminator function defined by the function `f`. `f` should return a HashableAny for groupBy to be able to build the map.
    
    It's possible to use complex computations made of partial functions (using |||> `orElse` and >>> `andThen` operators), and pattern matching with the use of `match` in the place of `f`. i.e., being `pfA`, `pfB`, `pfC` and `pfD` several partial functions that take a certain value and return a HashableAny, it's possible to group a ListT the following ways:
    
    * list.groupBy(pfa |||> pfb)
    
    * list.groupBy((pfa |||> pfb) >>> pfc)
    
    * list.groupBy(match(pfa, pfb, pfc, pfd))
    
    */
    public func groupBy(f: Function<T, HashableAny>) -> Map<ListT> {
        return groupByT(self, f)
    }
    
    /**
    :returns: The first element of the ListT, if any.
    */
    public func head() -> T? {
        return headT(self)
    }
    
    /**
    :returns: All the elements of this ListT except the last one.
    */
    public func initSegment() -> ListT {
        return initT(self)
    }
    
    /**
    Returns true if this ListT doesn't contain any elements.
    */
    public func isEmpty() -> Bool {
        return isEmptyT(self)
    }
    
    /**
    :returns: The last element of the ListT, if any.
    */
    public func last() -> T? {
        return lastT(self)
    }
    
    /**
    Returns an array containing the results of mapping `transform` over the elements of the current ListT.
    */
    public func map<U>(transform: (T) -> U) -> [U] {
        return mapT(self, transform)
    }
    
    /**
    Returns a new ListT containing the results of mapping `transform` over its elements. The resulting elements are guaranteed to be the same type as the items of the provided ListT.
    */
    public func mapConserve(transform: (T) -> T) -> ListT {
        return mapConserveT(self, transform)
    }
    
    /**
    Returns a string representation of all the elements within the ListT, without any separation between them.
    */
    public func mkString() -> String {
        return mkStringT(self)
    }
    
    /**
    Returns a string representation of all the elements within the ListT, separated by the provided separator.
    */
    public func mkString(separator: String) -> String {
        return mkStringT(self, separator)
    }
    
    /**
    Returns a string representation of all the elements within the ListT, separated by the provided separator and enclosed by the `start` and `end` strings.
    */
    public func mkString(start: String, separator: String, end: String) -> String {
        return mkStringT(self, start, separator, end)
    }
    
    /**
    Returns true if this ListT contains elements.
    */
    public func nonEmpty() -> Bool {
        return nonEmptyT(self)
    }
    
    /**
    :returns: Returns a tuple containing the results of splitting the ListT according to a predicate `p`. The first list in the tuple contains those elements which satisfy the predicate, while the second contains those which don't. Equivalent to (filter, filterNot).
    */
    public func partition(p: (T) -> Bool) -> (ListT, ListT) {
        return partitionT(self, p)
    }
    
    /**
    Returns the result of repeatedly calling combine with an accumulated value initialized to `initial` and each element of the current ListT.
    */
    public func reduce<U>(initialValue: U, combine: (U, T) -> U) -> U {
        return reduceT(self, initialValue, combine)
    }
    
    /**
    Returns a new ListT with elements in inverse order than the current one.
    */
    public func reverse() -> ListT {
        return reverseT(self)
    }
    
    /**
    Returns the number of items contained in the ListT.
    */
    public func size() -> Int {
        return sizeT(self)
    }
    
    /**
    Returns a new ListT made of the elements from the current one which satisfy the invariant:
    
    from <= indexOf(x) < until
    
    Note: If `endIndex` is out of range within the ListT, sliceT will throw an exception.
    */
    public func slice(from startIndex: Int, until endIndex: Int) -> ListT {
        return sliceT(self, from: startIndex, until: endIndex)
    }
    
    /**
    Returns a new ListT containing all the elements from the provided one, but sorted by a predicate `p`.
    
    :param: p Closure returning true if the first element should be ordered before the second.
    */
    public func sortWith(p: (T, T) -> Bool) -> ListT {
        return sortWithT(self, p)
    }
    
    /**
    :returns: Returns a tuple containing the results of splitting the ListT at the given position (equivalent to: (take n, drop n)).
    */
    public func splitAt(n: Int) -> (ListT, ListT) {
        return splitAtT(self, n)
    }
    
    /**
    :returns: Returns a new ListT containing all the elements of the provided one except for the first element.
    */
    public func tail() -> ListT {
        return tailT(self)
    }
    
    /**
    :returns: A new ListT containing the first `n` elements of the current one.
    */
    public func take(n: Int) -> ListT {
        return takeT(self, n)
    }
    
    /**
    :returns: A new ListT containing the last `n` elements of the current one.
    */
    public func takeRight(n: Int) -> ListT {
        return takeRightT(self, n)
    }
    
    /**
    Returns the longest prefix of elements that satisfy the predicate `p`.
    */
    public func takeWhile(p: (T) -> Bool) -> ListT {
        return takeWhileT(self, p)
    }
    
    /**
    Returns an array containing the elements of this ListT.
    */
    public func toArray() -> [T] {
        return toArrayT(self)
    }
    
    /**
    Returns a list containing the elements of this ListT.
    */
    public func toList() -> ListT<T> {
        return toListT(self)
    }
    
    /**
    Returns a new ListT containing all the elements from the two provided ListT.
    */
    public func union(a: ListT, b: ListT) -> ListT {
        return unionT(a, b)
    }
    
}
