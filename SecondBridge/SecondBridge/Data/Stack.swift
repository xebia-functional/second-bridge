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

// MARK: - Stack declaration and protocol implementations

/// Stack | An immutable iterable LIFO containing elements of type T.
public struct Stack<T> {
    private var internalArray : Array<T>
}

extension Stack : ArrayLiteralConvertible {
    public init(arrayLiteral elements: T...) {
        internalArray = elements
    }
    
    public init(_ elements: Array<T>) {
        internalArray = elements
    }
}

extension Stack : SequenceType {
    public typealias Generator = AnyGenerator<T>
    
    public func generate() -> Generator {
        let index : Int = 0
        
        return anyGenerator {
            if index < self.internalArray.count {
                return self.internalArray[index]
            }
            return nil
        }
    }
}

// MARK: - Basic operations

extension Stack {
    /**
    Returns a tuple containing the top item in the current stack, and a new stack with that item popped out.
    */
    public func pop() -> (item: T?, stack: Stack<T>) {
        if internalArray.count > 0 {
            return (self.top()!, takeT(self, n: self.size() - 1))
        }
        return (nil, self)
    }
    
    /**
    Returns a new stack with the current contents and the provided item on top.
    */
    public func push(item: T) -> Stack<T> {
        var result = internalArray
        result.append(item)
        return Stack<T>(result)
    }
    
    /**
    Returns the number of items contained in the stack.
    */
    public func size() -> Int {
        return internalArray.count
    }
    
    /**
    Returns the item on top the stack without popping it out, or nil if the stack is empty.
    */
    public func top() -> T? {
        return internalArray.last
    }
}

extension Stack : Traversable {
    public typealias ItemType = T
    public func foreach(f: (T) -> ()) {
        for item in self.internalArray {
            f(item)
        }
    }
    
    /**
    Build a new Stack instance with the elements contained in the `elements` array.
    */
    public static func build(elements: [ItemType]) -> Stack<T> {
        return Stack<T>(elements)
    }
    
    /**
    Build a new Stack instance with the elements contained in the provided Traversable instance. The provided traversable is expected to contain
    items with the same type as the Stack struct. Items of different types will be discarded.
    */
    public static func buildFromTraversable<U where U : Traversable>(traversable: U) -> Stack {
        return reduceT(traversable, initialValue: Stack()) { (result, item) -> Stack in
            switch item {
            case let sameTypeItem as T: result.push(sameTypeItem)
            default: break
            }
            return result
        }
    }
}

extension Stack : Iterable {
    
}

extension Stack: CustomStringConvertible, CustomDebugStringConvertible {
    public var debugDescription : String {
        return self.description
    }
    
    public var description : String {
        get {
            if self.size() > 0 {
                return self.mkString("[ ", separator: " | ", end: " ] <- top")
            }
            return "Empty stack"
        }
    }
}

// MARK: - Traversable functions accesors
extension Stack {
    /**
    Returns an array containing the results of mapping the partial function `f` over a set of the elements of this Stack that match the condition defined in `f`'s `isDefinedAt`.
    */
    public func collect<U>(f: PartialFunction<T, U>) -> [U] {
        return collectT(self, f: f)
    }
    
    /**
    Returns the number of elements of this Stack satisfy the given predicate.
    */
    public func count(p: (T) -> Bool) -> Int {
        return countT(self, p: p)
    }
    
    /**
    Returns a new Stack containing all the elements from the current Stack except the first `n` ones.
    */
    public func drop(n: Int) -> Stack {
        return dropT(self, n: n)
    }
    
    /**
    Returns a new Stack containing all the elements from the current Stack except the last `n` ones.
    */
    public func dropRight(n: Int) -> Stack {
        return dropRightT(self, n: n)
    }
    
    /**
    Returns the longest prefix of this Stack whose first element does not satisfy the predicate p.
    */
    public func dropWhile(p: (T) -> Bool) -> Stack {
        return dropWhileT(self, p: p)
    }
    
    /**
    Returns true if at least one of its elements of this Stack satisfy the given predicate.
    */
    public func exists(p: (T) -> Bool) -> Bool {
        return existsT(self, p: p)
    }
    
    /**
    Returns a Stack containing all the values from the current one that satisfy the `includeElement` closure.
    */
    public func filter(includeElement: (T) -> Bool) -> Stack {
        return filterT(self, includeElement: includeElement)
    }
    
    /**
    Returns a new Stack containing all the values from the current one except those that satisfy the `excludeElement` closure.
    */
    public func filterNot(excludeElement: (T) -> Bool) -> Stack {
        return filterNotT(self, excludeElement: excludeElement)
    }
    
    /**
    Returns the first element of this Stack that satisfy the given predicate `p`, if any.
    */
    public func find(p: (T) -> Bool) -> T? {
        return findT(self, p: p)
    }
    
    /**
    Returns the result of applying `transform` on each element of the Stack, and then flattening the results into an array.
    */
    public func flatMap<U>(transform: (T) -> [U]) -> [U] {
        return flatMapT(self, transform: transform)
    }
    
    /**
    Returns the result of repeatedly calling combine with an accumulated value initialized to `initial` and each element of the current Stack from right to left. A reversal equivalent to `reduce`/`foldLeft`.
    */
    public func foldLeft<U>(initialValue: U, combine: (U, T) -> U) -> U {
        return foldLeftT(self, initialValue: initialValue, combine: combine)
    }
    
    /**
    Returns the result of repeatedly calling combine with an accumulated value initialized to `initial` and each element of the current Stack from left to right. Equivalent to `reduce`.
    */
    public func foldRight<U>(initialValue: U, combine: (U, T) -> U) -> U {
        return foldRightT(self, initialValue: initialValue, combine: combine)
    }
    
    /**
    Returns true if all the elements of this Stack satisfy the given predicate.
    */
    public func forAll(p: (T) -> Bool) -> Bool {
        return forAllT(self, p: p)
    }
    
    /**
    Partitions this Stack into a map of Stacks according to some discriminator function defined by the function `f`. `f` should return a HashableAny for groupBy to be able to build the map.
    
    It's possible to use complex computations made of partial functions (using |||> `orElse` and >>> `andThen` operators), and pattern matching with the use of `match` in the place of `f`. i.e., being `pfA`, `pfB`, `pfC` and `pfD` several partial functions that take a certain value and return a HashableAny, it's possible to group a Stack the following ways:
    
    * stack.groupBy(pfa |||> pfb)
    
    * stack.groupBy((pfa |||> pfb) >>> pfc)
    
    * stack.groupBy(match(pfa, pfb, pfc, pfd))
    */
    public func groupBy(f: Function<T, HashableAny>) -> Map<Stack> {
        return groupByT(self, f: f)
    }
    
    /**
    - returns: The first element of the Stack, if any.
    */
    public func head() -> T? {
        return headT(self)
    }
    
    /**
    - returns: All the elements of this Stack except the last one.
    */
    public func initSegment() -> Stack {
        return initT(self)
    }
    
    /**
    Returns true if this Stack doesn't contain any elements.
    */
    public func isEmpty() -> Bool {
        return isEmptyT(self)
    }
    
    /**
    - returns: The last element of the Stack, if any.
    */
    public func last() -> T? {
        return lastT(self)
    }
    
    /**
    Returns an array containing the results of mapping `transform` over the elements of the current Stack.
    */
    public func map<U>(transform: (T) -> U) -> [U] {
        return mapT(self, transform: transform)
    }
    
    /**
    Returns a new Stack containing the results of mapping `transform` over its elements. The resulting elements are guaranteed to be the same type as the items of the provided Stack.
    */
    public func mapConserve(transform: (T) -> T) -> Stack {
        return mapConserveT(self, transform: transform)
    }
    
    /**
    Returns a string representation of all the elements within the Stack, without any separation between them.
    */
    public func mkString() -> String {
        return mkStringT(self)
    }
    
    /**
    Returns a string representation of all the elements within the Stack, separated by the provided separator.
    */
    public func mkString(separator: String) -> String {
        return mkStringT(self, separator: separator)
    }
    
    /**
    Returns a string representation of all the elements within the Stack, separated by the provided separator and enclosed by the `start` and `end` strings.
    */
    public func mkString(start: String, separator: String, end: String) -> String {
        return mkStringT(self, start: start, separator: separator, end: end)
    }
    
    /**
    Returns true if this Stack contains elements.
    */
    public func nonEmpty() -> Bool {
        return nonEmptyT(self)
    }
    
    /**
    - returns: Returns a tuple containing the results of splitting the Stack according to a predicate `p`. The first stack in the tuple contains those elements which satisfy the predicate, while the second contains those which don't. Equivalent to (filter, filterNot).
    */
    public func partition(p: (T) -> Bool) -> (Stack, Stack) {
        return partitionT(self, p: p)
    }    
    
    /**
    Returns the result of repeatedly calling combine with an accumulated value initialized to `initial` and each element of the current Stack.
    */
    public func reduce<U>(initialValue: U, combine: (U, T) -> U) -> U {
        return reduceT(self, initialValue: initialValue, combine: combine)
    }
    
    /**
    Returns a new Stack with elements in inverse order than the current one.
    */
    public func reverse() -> Stack {
        return reverseT(self)
    }
    
    /**
    Returns a new Stack made of the elements from the current one which satisfy the invariant:
    
    from <= indexOf(x) < until
    
    Note: If `endIndex` is out of range within the Stack, sliceT will throw an exception.
    */
    public func slice(from startIndex: Int, until endIndex: Int) -> Stack {
        return sliceT(self, from: startIndex, until: endIndex)
    }
    
    /**
    Returns a new Stack containing all the elements from the provided one, but sorted by a predicate `p`.
    
    - parameter p: Closure returning true if the first element should be ordered before the second.
    */
    public func sortWith(p: (T, T) -> Bool) -> Stack {
        return sortWithT(self, p: p)
    }
    
    /**
    - returns: Returns a tuple containing the results of splitting the Stack at the given position (equivalent to: (take n, drop n)).
    */
    public func splitAt(n: Int) -> (Stack, Stack) {
        return splitAtT(self, n: n)
    }
    
    /**
    - returns: Returns a new Stack containing all the elements of the provided one except for the first element.
    */
    public func tail() -> Stack {
        return tailT(self)
    }
    
    /**
    - returns: A new Stack containing the first `n` elements of the current one.
    */
    public func take(n: Int) -> Stack {
        return takeT(self, n: n)
    }
    
    /**
    - returns: A new Stack containing the last `n` elements of the current one.
    */
    public func takeRight(n: Int) -> Stack {
        return takeRightT(self, n: n)
    }
    
    /**
    Returns the longest prefix of elements that satisfy the predicate `p`.
    */
    public func takeWhile(p: (T) -> Bool) -> Stack {
        return takeWhileT(self, p: p)
    }
    
    /**
    Returns an array containing the elements of this Stack. Note: the top of the stack points to the last element of the contents array, so in case you want to get
    an array with the top in the first position, you need to reverse it (i.e: using reverseT(array)).
    */
    public func toArray() -> [T] {
        return toArrayT(self)
    }
    
    /**
    Returns a list containing the elements of this Stack.
    */
    public func toList() -> ListT<T> {
        return toListT(self)
    }
    
    /**
    Returns a new Stack containing all the elements from the two provided Stack.
    */
    public func union(a: Stack, b: Stack) -> Stack {
        return unionT(a, b: b)
    }    
}