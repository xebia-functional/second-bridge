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
import Swift47Deg
import Swiftz

let str = "Playground List Koans"

//== tests equality (same content)
var a : ListT<Int> = [1,2,3,4]
var b : ListT<Int> = [1,2,3,4]
println(a)
a == b

//Nil lists are identical, even of different types
var ab : ListT<String>  = []
var ba : ListT<Int>  = []
ab == ba

//Lists are easily created
var d : ListT<Int> = [1,2,3,4]

////Lists can be accessed via head and tail
d.head() == 1
let dTail : ListT<Int> = [2,3,4]
d.tail() == dTail

//Lists can be accessed by position
var e : ListT<Int> = [1,3,5,7,9]
e[0] == 1
e[2] == 5
e[4] == 9

//Lists are immutable
var f : ListT<Int> = [1,3,5,7,9]
println(f)
var g : ListT<Int> = f.filterNot({$0 == 1})
println(g)

//Lists have many useful methods
var h : ListT<Int> = [1,3,5,7,9]

// get the length of the list
h.length() == 5

// reverse the list
let reverseList : ListT<Int> = [9,7,5,3,1]
h.reverse() == reverseList

// map a function to double the numbers over the list
var hMap = h.map({$0 * 2})
println(hMap)

// filter any values divisible by 3 in the list
var hFilter = h.filter({$0 % 3 == 0})
println(hFilter)

//Lists can be reduced with a mathematical operation
var i : ListT<Int> = [1,3,5,7]
var iReduce = i.reduce({$0+$1})
println(iReduce)
var iReduceMul = i.reduce({$0*$1})
println(iReduceMul)

//Foldleft is like reduce, but with an explicit starting value
var j : ListT<Int> = [1,3,5,7]
var jReduce = i.reduce(0, combine: {$0+$1})
println(jReduce)
var jReduceIn = i.reduce(10, combine: {$0+$1})
println(jReduceIn)

var jReduceM = i.reduce(1, combine: {$0*$1})
println(jReduceM)
var jReduceInM = i.reduce(0, combine: {$0*$1})
println(jReduceInM)










































