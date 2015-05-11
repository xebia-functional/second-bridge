Second Bridge
=============

Second Bridge is a Swift library for functional programming. Our goal is to make Swift development on par with other functional languages like Scala by adding new data types, functions and operators.

This project depends on the [Swiftz](https://github.com/typelift/Swiftz) library. This library defines functional data structures, functions, idioms, and extensions that augment the Swift standard library. Please install as a local git submodule, for more information please read the [project site](https://github.com/typelift/Swiftz).

Installation
==========

To add Second Brigde to your application:

**Using Git Submodules**

* Clone SecondBrigde as a submodule into the directory of your choice
* Run git submodule init -i --recursive
* Drag SecondBrigde.xcodeproj  into your project tree as a subproject
* Under your project's Build Phases, expand Target Dependencies
* Click the + and add SecondBrigde
* Expand the Link Binary With Libraries phase
* Click the + and add SecondBrigde
* Click the + at the top left corner to add a Copy Files build phase
* Set the directory to Frameworks
* Click the + and add SecondBrigde

**Using Carthage**




Features
===========

####  PROTOCOLS

**Traversable**

Data types conforming to this protocol should expose certain functions that allow to traverse through them, and also being built from other Traversable types (although the latter has some limitations due to Swift type constraints restrictions). Any data type instantly gain access to a wide range of functional utility functions, by just implementing the following three methods:

```swift
public protocol Traversable {
   typealias ItemType
    
// Traverse all items of the instance, and call the provided function on each one.
  
  func foreach(f: (ItemType) -> ())
   
// Build a new instance of the same Traversable type with the elements contained in the `elements` array (i.e.: returned from the **T functions).
    
  class func build(elements: [ItemType]) -> Self
    
// Build a new instance of the same Traversable type with the elements contained in the provided Traversable instance. Users calling this function are responsible of transforming the data of each item to a valid ItemType suitable for the current Traversable class.
 
  class func buildFromTraversable<U where U : Traversable>(traversable: U) -> Self
}
 
```

The following global functions are available for any Traversable-conforming type. Those are based on the ones available in Scala to Traversable-derived types:

* **collectT**<S, U where S: Traversable>(source: S, f: PartialFunction<S.ItemType, U>) -> [U]
* **countT**<S: Traversable>(source: S, p: (S.ItemType) -> Bool) -> Int
* **dropT**<S: Traversable>(source: S, n: Int) -> S
* **dropRightT**<S: Traversable>(source: S, n: Int) -> S 
* **dropWhileT**<S: Traversable>(source: S, p: (S.ItemType) -> Bool) -> S
* **existsT**<S: Traversable>(source: S, p: (S.ItemType) -> Bool) -> Bool
* **findT**<S: Traversable>(source: S, p: (S.ItemType) -> Bool) -> S.ItemType?
* **filterT**<S: Traversable>(source: S, includeElement: (S.ItemType) -> Bool) -> S
* **filterNotT**<S: Traversable>(source: S, excludeElement: (S.ItemType) -> Bool) -> S
* **flatMapT**<S: Traversable, U>(source: S, transform: (S.ItemType) -> [U]) -> [U]
* **foldLeftT**<S: Traversable, U>(source: S, initialValue: U, combine: (U, S.ItemType) -> U) -> U
* **foldRightT**<S: Traversable, U>(source: S, initialValue: U, combine: (U, S.ItemType) -> U) -> U
* **forAllT**<S: Traversable>(source: S, p: (S.ItemType) -> Bool) -> Bool
* **groupByT**<S: Traversable>(source: S, f: Function<S.ItemType, HashableAny>) -> Map 
* **headT**<S: Traversable>(source: S) -> S.ItemType?
* **initT**<S: Traversable>(source: S) -> S
* **isEmptyT**<S: Traversable>(source: S) -> Bool
* **lastT**<S: Traversable>(source: S) -> S.ItemType?
* **mapT**<S: Traversable, U>(source: S, transform: (S.ItemType) -> U) -> [U]
* **mapConserveT**<S: Traversable>(source: S, transform: (S.ItemType) -> S.ItemType) -> S
* **mkStringT**<S: Traversable>(source: S) -> String
* **mkStringT**<S: Traversable>(source: S, separator: String) -> String
* **mkStringT**<S: Traversable>(source: S, start: String, separator: String, end: String) -> String
* **nonEmptyT**<S: Traversable>(source: S) -> Bool
* **partitionT**<S: Traversable>(source: S, p: (S.ItemType) -> Bool) -> (S, S)
* **reduceT**<S: Traversable, U>(source: S, initialValue: U, combine: (U, S.ItemType) -> U) -> U
* **reverseT**<S: Traversable>(source: S) -> S
* **sizeT**<S: Traversable>(source: S) -> Int
* **sliceT**<S: Traversable>(source: S, from startIndex: Int, until endIndex: Int) -> S
* **sortWithT**<S: Traversable>(source: S, p: (S.ItemType, S.ItemType) -> Bool) -> S
* **spanT**<S: Traversable>(source: S, p: (S.ItemType) -> Bool) -> (S, S)
* **splitAtT**<S: Traversable>(source: S, n: Int) -> (S, S)
* **tailT**<S: Traversable>(source: S) -> S
* **takeT**<S: Traversable>(source: S, n: Int) -> S
* **takeRightT**<S: Traversable>(source: S, n: Int) -> S
* **takeWhileT**<S: Traversable>(source: S, p: (S.ItemType) -> Bool) -> S
* **toArrayT**<S: Traversable>(source: S) -> [S.ItemType]
* **toListT**<S: Traversable>(source: S) -> ListT<S.ItemType>
* **unionT**<S: Traversable>(a: S, b: S) -> S
* **findIndexOfFirstItemToNotSatisfyPredicate**<S: Traversable>(source: S, p: (S.ItemType) -> Bool) -> Int?

**Iterable**

A Traversable-conforming data type that also implements the standard SequenceType (defining an iterator  to step one-by-one through the collection's elements) becomes instantly an Iterable. Iterables have instant access to the next functions, also based on their Scala counter-parts:

* **grouped**<S: Iterable>(source: S, n: Int) -> [S]
* **sameElements**<S: Iterable where S.Generator.Element == S.ItemType, S.ItemType : Equatable>(sourceA: S, sourceB: S) -> Bool
* **sliding**<S: Iterable>(source: S, n: Int, windowSize: Int) -> [S]
* **sliding**<S: Iterable>(source: S, n: Int) -> [S]
* **zip**<S: Iterable, T: Iterable where S.Generator.Element == S.ItemType, T.Generator.Element == T.ItemType>(sourceA: S, sourceB: T) -> [(S.ItemType, T.ItemType)]
* **zipAll**<S: Iterable, T: Iterable where S.Generator.Element == S.ItemType, T.Generator.Element == T.ItemType>(sourceA: S, sourceB: T, defaultItemA: S.ItemType?, defaultItemB: T.ItemType?)
* **zipWithIndex**<S: Iterable where S.Generator.Element == S.ItemType>(source: S) -> [(S.ItemType, Int)] 


#### DATA TYPES

**ArrayT**

An immutable, traversable and typed Array.

```swift
import SecondBrigde

let anArray : ArrayT<Int> = [1, 2, 3, 4, 5, 6] 
let list = anArray.toList()
anArray.isEmpty()  // False
anArray.size()  // 6
anArray.drop(4)  // [5,6]
anArray.filterNot({ $0 == 1 }  // [2, 3, 4, 5, 6]

```



**ListT**

An immutable, traversable and typed List.

```swift
import SecondBridge

let a : ListT<Int> = [1,2,3,4]
a.head()  // 1
a.tail()  // [2,3,4]
a.length()  // 4
a.filter({$0 % 3 == 0})  //  [1,2,4]

```

[Playground for Lists](https://github.com/47deg/swift-poc/blob/master/Playgrounds/ExampleList.playground/section-1.swift)

**Map**

An immutable, unordered, traversable and iterable collection containing pairs of keys and values. Values are typed, but Second Bridge supports several types of keys within one Map (i.e.: Int, Float and String) inside a container called HashableAny.

```swift
import SecondBridge

let map : Map<Int> = ["a" : 1, 2 : 2, 4.5 : 3]
map = map + ["c" : 4]		// map = ["a" : 1, 2 : 2, 4.5 : 3, "c" : 4]
map += ("d"", 5)			// map = ["a" : 1, 2 : 2, 4.5 : 3, "c" : 4, "d" : 5]
map += [("foo", 7), ("bar", 8)]	// map = ["a" : 1, 2 : 2, 4.5 : 3, "c" : 4, "d" : 5, "foo" : 7,  "bar" : 8]

map -= "d"				// map = ["a" : 1, 2 : 2, 4.5 : 3, "c" : 4, "foo" : 7,  "bar" : 8]
map --= ["foo", "bar"]		// map = ["a" : 1, 2 : 2, 4.5 : 3, "c" : 4]

let filteredMap = map.filter({ (value) -> Bool in (value as Int) < 3})  // ("a" : 1, 2 : 2)
let reducedResult = map.reduceByValue(0, combine: +)   // 10
let values = map.values 	// [1, 2, 3, 4]

```
[Playground for Maps](https://github.com/47deg/swift-poc/blob/master/Playgrounds/ExampleMap.playground/section-1.swift)

**Stack**

An immutable, traversable, iterable and typed LIFO stack.

```swift
import SecondBrigde

var stack = Stack<Int>()
stack = stack.push(1)	// top -> 1 <- bottom
stack = stack.push(2)	// top -> 2, 1 <- bottom
stack = stack.push(3)	// top -> 3, 2, 1 <- bottom

stack = stack.top()		// 3

stack.pop()				// (3, Stack[2, 1])

```
[Playground for Stacks](https://github.com/47deg/swift-poc/blob/master/Playgrounds/ExampleStack.playground/section-1.swift)
[Playground to showcase the use of Stacks and functional algorithms to solve the N-Queens problem](https://github.com/47deg/swift-poc/blob/master/Playgrounds/ExampleNQueens.playground/section-1.swift)

**Vector**

An immutable, traversable, iterable and typed Persistent Bit-partitioned Vector Trie, based on Haskell and Scala's Vector implementations.

```swift
import SecondBrigde

let vector = Vector<Int>()		// Empty vector
vector = vector.append(1) 	// [1]
vector = vector + 2			// [1, 2]
vector += 3					// [1, 2, 3]
let value = vector[1]			// 2
vector = vector.pop()			// [1, 2]

```
[Playground for Vectors](https://github.com/47deg/swift-poc/blob/master/Playgrounds/ExampleVector.playground/section-1.swift)

####  FUNCTIONS

**Partial Function**

A partial function defines a function whose execution is restricted to a certain set of values, defined by the method **isDefinedAt**. This allows developers to set certain conditions to their functions. An easy to understand example is division, whose execution is restricted to dividers equal to zero. As with Scala's partial functions, you are allowed to execute them even by using their restricted set of parameters. But you have access to the **isDefinedAt** function that tells you if you're good to go.

Second Bridge defines several custom operators that makes creating partial functions really easy. Just by joining two closures with the **|->** operator, we create a partial function (the first closure must return a Bool, thus defining the conditions under which this function works).

One important aspect of partial functions is that by combining them you can create meaningful pieces of code that define algorithms. i.e.: you can create a combined function that performs an operation or another, depending on the received parameter. You have access to other custom operators like **|||>** (OR), **>>>** (AND THEN), and  **∫** (function definition). One quick example:

```swift
import SecondBridge

let doubleEvens = { $0 % 2 == 0 } |-> { $0 * 2 }		// Multiply by 2 any even number
let tripleOdds = { $0 % 2 != 0 } |-> { $0 * 3 }		// Multiply by 3 any odd number
let addFive = ∫(+5)								// Regular function to add five to any number

let opOrElseOp = doubleEvens |||> tripleOdds		// If receiving an even, double it. If not, triple it.
let opOrElseAndThenOp = doubleEvens |||> tripleOdds >>> addFive	// If receiving an even, double it. If not, triple it. Then, add five to the result.

opOrElseOp.apply(3)			// 9
opOrElseOp.apply(4)			// 8
opOrElseAndThenOp.apply(3)	// 14
opOrElseAndThenOp.apply(4)	// 13

```

Partial functions also gives us the ability to perform complex pattern matching sets, more powerful than Swift's switch block, by using our **match** function:

```swift
import SecondBridge
let matchTest = match({(item: Int) -> Bool in item == 0 } |-> {(Int) -> String in return "Zero"},
                              {(item: Int) -> Bool in item == 1 } |-> {(Int) -> String in return "One"},
                              {(item: Int) -> Bool in item == 2 } |-> {(Int) -> String in return "Two"},
                              {(item: Int) -> Bool in item > 2 } |-> {(Int) -> String in return "Moar!"})
                              
matchTest.apply(0)			// "Zero"
matchTest.apply(1)			// "One"
matchTest.apply(1000)		// "Moar!"

```

System Requirements
==================

Second Brigde supports iOS 7.0+.

Contribute
=========

License
======

Copyright (C) 2012 47 Degrees, LLC http://47deg.com hello@47deg.com

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
