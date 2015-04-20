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

/// TravList | An immutable and traversable List containing elements of type T.
public struct TravList<T> {
    
    private var internalList : List<T>
    
    public subscript(index: UInt) -> T? {
        return internalList[index]
    }
}

extension TravList : Equatable {}

public func ==<T>(lhs: TravList<T> , rhs: TravList<T> ) -> Bool {
    return true
}


extension TravList {
    
    public func tail() -> TravList {
       return tailT(self)
    }
        
    //Funcion reduce with only a parameter,  parameter initial is not necessary
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
    
    //Funcion reduce right with only a parameter,  parameter initial is not necessary
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

    //Applies a binary operator to reduce the elements of the receiver to a single value.
    public func reduceRight<B>(f : (B, T) -> B, initial : B) -> B {
        let a = internalList.reverse()
        switch a.match() {
        case .Nil:
            return initial
        case let .Cons(x, xs):
            return xs.reduce(f, initial: f(initial,x))
        }
    }

    //Applies a binary operator to a start value and all elements of this sequence, going right to left
    public func fold<B>(f : (B, T) -> B, initial : B) -> B {
        switch internalList.match() {
        case .Nil:
            return initial
        case let .Cons(x, xs):
            return xs.reduce(f, initial: f(initial,x))
        }
    }
    
    //Applies a binary operator to a start value and all elements of this sequence, going left to right
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
    Returns a new TravList with the current contents and the provided item on top.
    */
    public func append(item: T) -> TravList<T> {
        var result = internalList
        return TravList(result.append([item]))
    }
    
    public func arrayToList( elements: Array<T>) -> TravList<T> {
        var result = internalList
        for element in elements {
            let l : List = [element]
            result = result + l
        }
        return TravList<T>(result)
    }
    
}




extension TravList : ArrayLiteralConvertible {
    
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


extension TravList : Traversable {
    
    typealias ItemType = T
    
    public func foreach(f: (T) -> ()) {
        for item in self.internalList {
            f(item)
        }
    }
    
    /**
    Build a new TravList instance with the elements contained in the `elements` array.
    */
    public static func build(elements: [ItemType]) -> TravList<T> {
        var result =  TravList()
        return result.arrayToList(elements)
    }
    
    /**
    Build a new TravList instance with the elements contained in the provided Traversable instance. The provided traversable is expected to contain
    items with the same type as the TravList struct. Items of different types will be discarded.
    */
    public static func buildFromTraversable<U where U : Traversable>(traversable: U) -> TravList {
        return reduceT(traversable, TravList()) { (result, item) -> TravList in
            switch item {
            case let sameTypeItem as T: result.append(sameTypeItem)
            default: break
            }
            return result
        }
        
    }
}


// MARK: - Traversable functions accesors
extension TravList {
    
    /**
    Returns the result of repeatedly calling combine with an accumulated value initialized to `initial` and each element of the current TravList.
    */
    public func reduce<U>(initialValue: U, combine: (U, T) -> U) -> U {
        return reduceT(self, initialValue, combine)
    }
    
    /**
    Returns an array containing the results of mapping `transform` over the elements of the current TravList.
    */
    public func map<U>(transform: (T) -> U) -> [U] {
        return mapT(self, transform)
    }
    
    /**
    Returns a new TravList containing the results of mapping `transform` over its elements. The resulting elements are guaranteed to be the same type as the items of the provided TravList.
    */
    public func mapConserve(transform: (T) -> T) -> TravList {
        return mapConserveT(self, transform)
    }
    
    /**
    Returns a TravList containing all the values from the current one that satisfy the `includeElement` closure.
    */
    public func filter(includeElement: (T) -> Bool) -> TravList {
        return filterT(self, includeElement)
    }
    
    /**
    Returns a new TravList containing all the values from the current one except those that satisfy the `excludeElement` closure.
    */
    public func filterNot(excludeElement: (T) -> Bool) -> TravList {
        return filterNotT(self, excludeElement)
    }
    
    /**
    Returns the result of applying `transform` on each element of the TravList, and then flattening the results into an array.
    */
    public func flatMap<U>(transform: (T) -> [U]) -> [U] {
        return flatMapT(self, transform)
    }
    
    /**
    Returns a new TravList with elements in inverse order than the current one.
    */
    public func reverse() -> TravList {
        return reverseT(self)
    }
    
    /**
    Returns the result of repeatedly calling combine with an accumulated value initialized to `initial` and each element of the current TravList from left to right. Equivalent to `reduce`.
    */
    public func foldRight<U>(initialValue: U, combine: (U, T) -> U) -> U {
        return foldRightT(self, initialValue, combine)
    }
    
    /**
    Returns the result of repeatedly calling combine with an accumulated value initialized to `initial` and each element of the current TravList from right to left. A reversal equivalent to `reduce`/`foldLeft`.
    */
    public func foldLeft<U>(initialValue: U, combine: (U, T) -> U) -> U {
        return foldLeftT(self, initialValue, combine)
    }
    
    /**
    Returns an array containing the elements of this TravList.
    */
    public func toArray() -> [T] {
        return toArrayT(self)
    }
    
    /**
    Returns a list containing the elements of this TravList.
    */
    public func toList() -> TravList<T> {
        return toListT(self)
    }
    
    /**
    Returns a string representation of all the elements within the TravList, without any separation between them.
    */
    public func mkString() -> String {
        return mkStringT(self)
    }
    
    /**
    Returns a string representation of all the elements within the TravList, separated by the provided separator.
    */
    public func mkString(separator: String) -> String {
        return mkStringT(self, separator)
    }
    
    /**
    Returns a string representation of all the elements within the TravList, separated by the provided separator and enclosed by the `start` and `end` strings.
    */
    public func mkString(start: String, separator: String, end: String) -> String {
        return mkStringT(self, start, separator, end)
    }
    
    /**
    Returns true if this TravList doesn't contain any elements.
    */
    public func isEmpty() -> Bool {
        return isEmptyT(self)
    }
    
    /**
    Returns true if this TravList contains elements.
    */
    public func nonEmpty() -> Bool {
        return nonEmptyT(self)
    }
    
    /**
    Returns the first element of this TravList that satisfy the given predicate `p`, if any.
    */
    public func find(p: (T) -> Bool) -> T? {
        return findT(self, p)
    }
    
    /**
    Returns a new TravList containing all the elements from the current TravList except the first `n` ones.
    */
    public func drop(n: Int) -> TravList {
        return dropT(self, n)
    }
    
    /**
    Returns a new TravList containing all the elements from the current TravList except the last `n` ones.
    */
    public func dropRight(n: Int) -> TravList {
        return dropRightT(self, n)
    }
    
    /**
    Returns the longest prefix of this TravList whose first element does not satisfy the predicate p.
    */
    public func dropWhile(p: (T) -> Bool) -> TravList {
        return dropWhileT(self, p)
    }
    
    /**
    :returns: A new TravList containing the first `n` elements of the current one.
    */
    public func take(n: Int) -> TravList {
        return takeT(self, n)
    }
    
    /**
    :returns: A new TravList containing the last `n` elements of the current one.
    */
    public func takeRight(n: Int) -> TravList {
        return takeRightT(self, n)
    }
    
    /**
    Returns the longest prefix of elements that satisfy the predicate `p`.
    */
    public func takeWhile(p: (T) -> Bool) -> TravList {
        return takeWhileT(self, p)
    }
    
    /**
    :returns: The first element of the TravList, if any.
    */
    public func head() -> T? {
        return headT(self)
    }
    
    /**
    :returns: All the elements of this TravList except the last one.
    */
    public func initSegment() -> TravList {
        return initT(self)
    }
    
    /**
    :returns: The last element of the TravList, if any.
    */
    public func last() -> T? {
        return lastT(self)
    }
    
    /**
    Returns a new TravList made of the elements from the current one which satisfy the invariant:
    
    from <= indexOf(x) < until
    
    Note: If `endIndex` is out of range within the TravList, sliceT will throw an exception.
    */
    public func slice(from startIndex: Int, until endIndex: Int) -> TravList {
        return sliceT(self, from: startIndex, until: endIndex)
    }
    
    /**
    :returns: Returns a tuple containing the results of splitting the TravList at the given position (equivalent to: (take n, drop n)).
    */
    public func splitAt(n: Int) -> (TravList, TravList) {
        return splitAtT(self, n)
    }
    
    /**
    :returns: Returns a tuple containing the results of splitting the TravList according to a predicate `p`. The first list in the tuple contains those elements which satisfy the predicate, while the second contains those which don't. Equivalent to (filter, filterNot).
    */
    public func partition(p: (T) -> Bool) -> (TravList, TravList) {
        return partitionT(self, p)
    }
    
    /**
    Returns an array containing the results of mapping the partial function `f` over a set of the elements of this TravList that match the condition defined in `f`'s `isDefinedAt`.
    */
    public func collect<U>(f: PartialFunction<T, U>) -> [U] {
        return collectT(self, f)
    }
    
    /**
    Partitions this TravList into a map of TravList according to some discriminator function defined by the function `f`. `f` should return a HashableAny for groupBy to be able to build the map.
    
    It's possible to use complex computations made of partial functions (using |||> `orElse` and >>> `andThen` operators), and pattern matching with the use of `match` in the place of `f`. i.e., being `pfA`, `pfB`, `pfC` and `pfD` several partial functions that take a certain value and return a HashableAny, it's possible to group a TravList the following ways:
    
    * list.groupBy(pfa |||> pfb)
    
    * list.groupBy((pfa |||> pfb) >>> pfc)
    
    * list.groupBy(match(pfa, pfb, pfc, pfd))
    
    */
    public func groupBy(f: Function<T, HashableAny>) -> Map<TravList> {
        return groupByT(self, f)
    }
    
    /**
    Returns the number of elements of this TravList satisfy the given predicate.
    */
    public func count(p: (T) -> Bool) -> Int {
        return countT(self, p)
    }
    
    /**
    Returns true if all the elements of this TravList satisfy the given predicate.
    */
    public func forAll(p: (T) -> Bool) -> Bool {
        return forAllT(self, p)
    }
    
    /**
    Returns true if at least one of its elements of this TravList satisfy the given predicate.
    */
    public func exists(p: (T) -> Bool) -> Bool {
        return existsT(self, p)
    }
    
    /**
    Returns a new TravList containing all the elements from the provided one, but sorted by a predicate `p`.
    
    :param: p Closure returning true if the first element should be ordered before the second.
    */
    public func sortWith(p: (T, T) -> Bool) -> TravList {
        return sortWithT(self, p)
    }
    
    /**
    Returns a new TravList containing all the elements from the two provided TravList.
    */
    public func union(a: TravList, b: TravList) -> TravList {
        return unionT(a, b)
    }
    
}