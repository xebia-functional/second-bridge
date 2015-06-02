Second Bridge
=============

**[Second Bridge](http://47deg.github.io/second-bridge)** is a Swift framework for functional programming. Our goal is to make Swift development on par with other functional languages like Scala by adding new data types, functions and operators.

This project depends on the [Swiftz](https://github.com/typelift/Swiftz) library. This library defines functional data structures, functions, idioms, and extensions that augment the Swift standard library.

Installation
==========

Second Bridge supports the CocoaPods dependency manager. To install the framework in your project, place the following in your Podfile:

	platform :ios, '8.0'
	use_frameworks!
	
	// (... other pods ...)
	pod 'SecondBridge', :git => 'https://github.com/47deg/second-bridge.git'
	
By running `pod install` or `pod update` you should have **Second Bridge** in your workspace ready to go!

Features
===========

####  DATA-TYPES PROTOCOLS

**Traversable**

Protocols like **Traversable** and **Iterable** will make it easier for you to expand the current data-types available. If you need to create a new data-type, just by implementing the following three methods your type will have access to the 40-something functions available in Second Bridge:


	public protocol Traversable {
	   typealias ItemType
	    
	  // Traverse all items of the instance, and call the provided function on each one.  
	  func foreach(f: (ItemType) -> ())
	   
	  // Build a new instance of the same Traversable type with the elements contained in the `elements` array (i.e.: returned from the **T functions).	    
	  class func build(elements: [ItemType]) -> Self
	    
	  // Build a new instance of the same Traversable type with the elements contained in the provided Traversable instance. Users calling this function are responsible of transforming the data of each item to a valid ItemType suitable for the current Traversable class.	 
	  class func buildFromTraversable<U where U : Traversable>(traversable: U) -> Self
	}
 
The following **global** functions are available for any **Traversable-conforming** type. Those are based on the main ones available in Scala for Traversable-derived types:

* **collectT**: Returns an array containing the results of mapping a partial function `f` over a set of the elements of this Traversable that match the condition defined in `f`'s `isDefinedAt`.
* **countT**: Returns the number of elements of this Traversable satisfy the given predicate.
* **dropT**: Selects all elements except the first n ones.
* **dropRightT**: Selects all elements except the last n ones.
* **dropWhileT**: Drops the longest prefix of elements that satisfy a predicate.
* **existsT**: Returns true if at least one of its elements of this Traversable satisfy the given predicate.
* **findT**: Returns the first element of this Traversable that satisfy the given predicate `p`, if any.
* **filterT**: Returns a Traversable containing all the values from the current traversable that satisfy the `includeElement` closure.
* **filterNotT**: Returns an array containing all the values from the current traversable except those that satisfy the `excludeElement` closure.
* **flatMapT**: Returns the result of applying `transform` on each element of the traversable, and then flattening the results into an array. You can create a new Traversable from the results of the flatMap application by calling function Traversable.build and passing its results to it.
* **foldLeftT**: Returns the result of repeatedly calling combine with an accumulated value initialized to `initial` and each element of the current traversable from right to left. A reversal equivalent to `reduceT`/`foldLeftT`.
* **foldRightT**: Returns the result of repeatedly calling combine with an accumulated value initialized to `initial` and each element of the current traversable from left to right. Equivalent to `reduceT`.
* **forAllT**: Returns true if all the elements of this Traversable satisfy the given predicate.
* **groupByT**: Partitions this Traversable into a map of Traversables according to some discriminator function defined by the function `f`.
* **headT**: Returns the first element of the Traversable or a nil if it's empty. 
* **initT**: Returns all the elements of this Traversable except the last one.
* **isEmptyT**: Returns true if this Traversable doesn't contain any elements.
* **lastT**: Returns the last element of the Traversable or a nil if it's empty.
* **mapT**: Returns an array containing the results of mapping `transform` over the elements of the provided Traversable.
* **mapConserveT**: Returns a traversable containing the results of mapping `transform` over its elements. The resulting elements are guaranteed to be the same type as the items of the provided traversable.
* **mkStringT**: Returns a string representation of all the elements within the Traversable, separated by the provided separator and enclosed by the `start` and `end` strings.
* **nonEmptyT**: Returns true if this Traversable contains elements.
* **partitionT**: Returns a tuple containing the results of splitting the Traversable according to a predicate. The first traversable in the tuple contains those elements which satisfy the predicate, while the second contains those which don't.
* **reduceT**: Returns the result of repeatedly calling combine with an accumulated value initialized to `initial` and each element of the current traversable.
* **reverseT**: Returns a traversable with elements in inverse order.
* **sizeT**: Returns the number of elements contained in this Traversable.
* **sliceT**: Returns a Traversable made of the elements from `source` which satisfy the invariant: `from <= indexOf(x) < until`.
* **sortWithT**: Returns a new Traversable containing all the elements from the provided one, but sorted by a predicate `p`.
* **spanT**: Returns a tuple containing the results of splitting the Traversable according to a predicate. The first traversable in the tuple contains the first elements that satisfy the predicate `p`, while the second contains all elements after those.
* **splitAtT**: Returns a tuple containing the results of splitting the Traversable at the given position.
* **tailT**: Returns a new Traversable containing all the elements of the provided one except for the first element.
* **takeT**: Returns a new Traversable of the same type containing the first n elements.
* **takeRightT**: Returns a new Traversable containing the last n elements.
* **takeWhileT**: Takes the longest prefix of elements that satisfy a predicate.
* **toArrayT**: Returns a standard array containing the elements of this Traversable.
* **toListT**: Returns a singly-linked list containing the elements of this Traversable.
* **unionT**: Returns a new Traversable containing all the elements from the two provided Traversables.

**Iterable**

Any Traversable-conforming data type that also implements the standard **SequenceType** protocol (defining an iterator to step one-by-one through the collection's elements) instantly becomes an **Iterable**. Iterables have instant access to the next functions, also based on their **Scala** counter-parts:

* **grouped**: Returns an array of Iterables of size `n`, comprising all the elements of the provided Iterable.
* **sameElements**: Returns true if the two Iterables contain the same elements in the same order.
* **sliding**: Returns an array of Iterables, being the result of grouping chunks of size `n` while traversing through a sliding window of size `windowSize`.
* **sliding**: Returns an array of Iterables, being the result of grouping chunks of size `n` while traversing through a sliding window of size 1.
* **zip**: Returns an array of tuples, each containing the corresponding elements from the provided Iterables.
* **zipAll**: Returns an array of tuples, each containing the corresponding elements from the provided Iterables. If the two sources aren't the same size, zipAll will fill the gaps by using the provided default items (if any).
* **zipWithIndex**: Returns an array of tuples, each containing an element from the provided Iterable and its index.

#### DATA TYPES

**ArrayT**

An **immutable**, **traversable** and **typed** Array.

	import SecondBrigde

	let anArray : ArrayT<Int> = [1, 2, 3, 4, 5, 6] 
	let list = anArray.toList()
	anArray.isEmpty()  // False
	anArray.size()  // 6
	anArray.drop(4)  // [5,6]
	anArray.filterNot({ $0 == 1 }  // [2, 3, 4, 5, 6]

**ListT**

An **immutable**, **traversable** and **typed** List.

	import SecondBridge

	let a : ListT<Int> = [1,2,3,4]
	a.head()  // 1
	a.tail()  // [2,3,4]
	a.length()  // 4
	a.filter({$0 % 3 == 0})  //  [1,2,4]

[Interactive Playground about Lists](https://github.com/47deg/swift-poc/blob/master/Playgrounds/ExampleList.playground/section-1.swift)

**Map**

An **immutable**, **unordered**, **traversable** and **iterable** collection containing pairs of keys and values. Values are typed, but **Second Bridge** supports several types of keys within one Map (i.e.: **Int**, **Float** and **String**) inside a container called `HashableAny`.

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
[Interactive Playground about Maps](https://github.com/47deg/swift-poc/blob/master/Playgrounds/ExampleMap.playground/section-1.swift)

**Stack**

An **immutable**, **traversable**, **iterable** and **typed** LIFO stack.

	import SecondBrigde

	var stack = Stack<Int>()
	stack = stack.push(1)	// top -> 1 <- bottom
	stack = stack.push(2)	// top -> 2, 1 <- bottom
	stack = stack.push(3)	// top -> 3, 2, 1 <- bottom

	stack = stack.top()		// 3

	stack.pop()				// (3, Stack[2, 1])

* [Interactive Playground about Stacks](https://github.com/47deg/swift-poc/blob/master/Playgrounds/ExampleStack.playground/section-1.swift)
* [Interactive Playground to showcase the use of Stacks and functional algorithms to solve the N-Queens problem](https://github.com/47deg/swift-poc/blob/master/Playgrounds/ExampleNQueens.playground/section-1.swift)

**Vector**

An **immutable**, **traversable**, **iterable** and **typed** **Persistent Bit-partitioned Vector Trie**, based on Haskell and Scala's Vector implementations.

	import SecondBrigde

	let vector = Vector<Int>()		// Empty vector
	vector = vector.append(1) 	// [1]
	vector = vector + 2			// [1, 2]
	vector += 3					// [1, 2, 3]
	let value = vector[1]			// 2
	vector = vector.pop()			// [1, 2]

[Interactive Playground about Vectors](https://github.com/47deg/swift-poc/blob/master/Playgrounds/ExampleVector.playground/section-1.swift)

####  FUNCTIONS

**Partial Function**

A partial function are those whose execution is restricted to a certain set of values, defined by the method **isDefinedAt**. This allows developers to set certain conditions to their functions. An easy to understand example is a divider function, whose execution is restricted to dividers equal to zero. As with **Scala**'s partial functions, you are allowed to execute them even by using their restricted set of parameters. But you have access to the **isDefinedAt** function that tells you if it's safe to call.

**Second Bridge** defines several custom operators that makes creating partial functions really easy. Just by joining two closures with the `|->` operator, we create a partial function (the first closure must return a Bool, thus defining the conditions under which this function works).

One important aspect of partial functions is that by combining them you can create meaningful pieces of code that define algorithms. i.e.: you can create a combined function that performs an operation or another, depending on the received parameter. You have access to other custom operators like `|||>` (*OR*), `>>>` (*AND THEN*), and  `∫` (*function definition*). One quick example:

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


Partial functions also gives us the ability to perform **complex pattern matching sets**, more powerful than Swift's standard **switch** block, by using our **match** function:

	import SecondBridge
	let matchTest = match({(item: Int) -> Bool in item == 0 } |-> {(Int) -> String in return "Zero"},
	                              {(item: Int) -> Bool in item == 1 } |-> {(Int) -> String in return "One"},
	                              {(item: Int) -> Bool in item == 2 } |-> {(Int) -> String in return "Two"},
	                              {(item: Int) -> Bool in item > 2 } |-> {(Int) -> String in return "Moar!"})
	                              
	matchTest.apply(0)			// "Zero"
	matchTest.apply(1)			// "One"
	matchTest.apply(1000)		// "Moar!"


System Requirements
==================

Second Bridge supports iOS 8.0+.

Contribute
=========

We've tried to pack **Second Bridge** with many useful features from the Scala language, but considering all the work done in that language we have a lot of ground to cover yet. That's why **47 Degrees wants YOU**! Second Bridge is **completely open-source**, and we're really looking forward to see what you can come up with! So if you're interested in Second Bridge and think that you've come up with a great feature to add... don't hesitate and send us a PR! We'll review and incorporate it to our code-base as soon as possible.

License
======

Copyright (C) 2015 47 Degrees, LLC http://47deg.com hello@47deg.com

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
