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

import UIKit
import Swiftz
import SecondBridge
/*:
# Partial Functions

SecondBridge includes an implementation for **partial functions**. That is, functions that are appliable
only for a certain subset of parameters. i.e.: a square root function can't be calculated on a negative number.

The next examples show how you can create partial functions (using the |-> operator), and how to combine several
of them to create algorithm-like functions using the *or* (|||>) and the *AND-THEN* (>>>) operators:
*/

//: We're creating a partial function that doubles a number if it’s even
let doubleEvens = { $0 % 2 == 0 } |-> { $0 * 2 }

//: And then another that triples a number if it’s odd
let tripleOdds = { $0 % 2 != 0 } |-> { $0 * 3 }

//: Then, a regular function that just adds five
let addFive = ∫(+5)

//: With that we can create blocks of code like this: "Double a number if it’s even, or triple it if it’s odd"
let opOrElseOp = doubleEvens |||> tripleOdds

//: Or this: "Double a number if it’s even, or triple it if it’s odd. Then, increment the result by 5."
let opOrElseAndThenOp = doubleEvens |||> tripleOdds >>> addFive

//: By using the `apply` method, we can pass a parameter to it and get a result.
let resultEven = opOrElseOp.apply(3)
let resultOdd = opOrElseOp.apply(4)

let resultAndThenOdd = opOrElseAndThenOp.apply(3)
let resultAndThenEven = opOrElseAndThenOp.apply(4)

//: One cool thing that we can do is to perform **pattern matching**, while getting a value as a result
let matchTest = match({(item: Int) -> Bool in item == 0 } |-> {(Int) -> String in return "Zero"},
    {(item: Int) -> Bool in item == 1 } |-> {(Int) -> String in return "One"},
    {(item: Int) -> Bool in item == 2 } |-> {(Int) -> String in return "Two"},
    {(item: Int) -> Bool in item > 2 } |-> {(Int) -> String in return "Moar!"})

matchTest.apply(0)
matchTest.apply(1)
matchTest.apply(2)
matchTest.apply(666)

//: Also, we can apply a partial function to any **Traversable** collection, and receiving the result from all the values appliable:
let map : Map<Double> = ["a" : -1, "b" : 0, "c" : 1, "d" : 2, "e" : 3, "f" : 4]
let squareRoot = ∫({ $0.1 >= 0 }) |-> Function<(HashableAny, Double), (HashableAny, Double)>.arr({ ($0.0, sqrt(Double($0.1))) })
map.description
map.collect(squareRoot).description
