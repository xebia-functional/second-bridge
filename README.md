Second Brigde
=============

Second Brigde is a Swift library for functional programming.

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




Introduction
===========

####  PROTOCOL

**Protocol Traversable**

Datatypes conforming to this protocol should expose certain functions that allow to traverse through them, and also being built from other Traversable types (although the latter has some limitations due to Swift type constraints restrictions). All Traversable instances have access to the methods declared in this protocol.

```swift
public protocol Traversable {
   typealias ItemType
    
  //Traverse all items of the instance, and call the provided function on each one.
  
  func foreach(f: (ItemType) -> ())
   
 // Build a new instance of the same Traversable type with the elements contained in the `elements` array (i.e.: returned from the **T functions).
    
  class func build(elements: [ItemType]) -> Self
    
 /**Build a new instance of the same Traversable type with the elements contained in the provided Traversable     instance. Users calling this function are responsible of transforming the data of each item to a valid ItemType suitable for the current Traversable class.
  */
   class func buildFromTraversable<U where U : Traversable>(traversable: U) -> Self
}
 
```

Global functions. These functions are available for all Traversable-conforming types:

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

Swift collections that define an iterator method to step through one-by-one the collection's elements.
Methods implemented:

* **grouped**<S: Iterable>(source: S, n: Int) -> [S]
* **sameElements**<S: Iterable where S.Generator.Element == S.ItemType, S.ItemType : Equatable>(sourceA: S, sourceB: S) -> Bool
* **sliding**<S: Iterable>(source: S, n: Int, windowSize: Int) -> [S]
* **sliding**<S: Iterable>(source: S, n: Int) -> [S]
* **zip**<S: Iterable, T: Iterable where S.Generator.Element == S.ItemType, T.Generator.Element == T.ItemType>(sourceA: S, sourceB: T) -> [(S.ItemType, T.ItemType)]
* **zipAll**<S: Iterable, T: Iterable where S.Generator.Element == S.ItemType, T.Generator.Element == T.ItemType>(sourceA: S, sourceB: T, defaultItemA: S.ItemType?, defaultItemB: T.ItemType?)
* **zipWithIndex**<S: Iterable where S.Generator.Element == S.ItemType>(source: S) -> [(S.ItemType, Int)] 


#### STRUCT

**ArrayT**

An immutable and traversable Array containing elements of type T.

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

An immutable and traversable List containing elements of type T.

```swift
import SecondBrigde

let a : ListT<Int> = [1,2,3,4]
a.head()  // 1
a.tail()  // [2,3,4]
a.length()  // 4
a.filter({$0 % 3 == 0})  //  [1,2,4]

```

[PlayGroundList](https://github.com/47deg/swift-poc/blob/master/Playgrounds/ExampleList.playground/section-1.swift)

**Map**

An immutable iterable collection containing pairs of keys and values. Each key is of type HashableAny to allow to have keys with different types (currently supported types are Int, Float, and String). Each value is of a type T. If you need to store values of different types, make an instance of Map<Any>

```swift
import SecondBrigde


```
[PlayGroundMap](https://github.com/47deg/swift-poc/blob/master/Playgrounds/ExampleMap.playground/section-1.swift)

**Stack**

An immutable iterable LIFO containing elements of type T

```swift
import SecondBrigde


```

**Vector**

An immutable Persistent Bit-partitioned Vector Trie containing elements of type T.

```swift
import SecondBrigde


```

[PlayGroundNQueens](https://github.com/47deg/swift-poc/blob/master/Playgrounds/ExampleNQueens.playground/section-1.swift)

####  FUNTION

**Partial Function**

Defines a function whose execution is restricted to a certain set of values defined by `isDefinedAt`

The methods implemented are:

* **orElse**<T, U>(a: PartialFunction<T, U>, b: PartialFunction<T, U>) -> Function<T, U>
* **match**<T, U>(listOfPartialFunctions: PartialFunction<T, U>...) -> Function<T, U>
* **|||>** <T, U>(a: PartialFunction<T, U>, b: PartialFunction<T, U>) -> Function<T, U>
* **|->**<T, U>(isDefinedAt: Function<T, Bool>, function: Function<T, U>) -> PartialFunction<T, U>
* **|->**<T, U>(isDefinedAt: T -> Bool, function: T -> U) -> PartialFunction<T, U>
*** ∫** <T, U>(f: T -> U) -> Function<T, U>  


System Requirements
==================

Second Brigde supports  iOS 7.0+.

Contribute
=========

License
======

Copyright (C) 2012 47 Degrees, LLC http://47deg.com hello@47deg.com

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
