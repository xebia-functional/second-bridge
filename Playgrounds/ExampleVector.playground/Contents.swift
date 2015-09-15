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
import SecondBridge

/*:
# Vectors

SecondBridge's Vectors are scientifically called *Bitmapped Vector Tries with a branching factor of 32*.
Their goal, as Scala documentation states, is to achieve a good balance between fast functional updates and fast random access.
Our implementation is based on **Daniel Spiewak**'s from his awesome talk
["Extreme Cleverness: Functional Data Structures in Scala"](http://www.infoq.com/presentations/Functional-Data-Structures-in-Scala),
which in our opinion is a must watch! (actually Spiewak's implementation is a port from Clojure's implementation, created
by **Rick Hickey**).
*/

//: Vectors can be created by using an array literal:
let v : Vector<Int> = [1, 2, 3, 4, 5]
v.description

//: But it's better to do this by using the `build` function:
let v2 = Vector<Int>.build([1, 2, 3, 4, 5])
v2.description

//: You can add more elements to an existing vector by using the append function or the `+` operator
let v3 = v + 6
v3.description

//: And by popping you can remove the last element in the vector
let v4 = v.pop()
v4.description

//: Vectors are **Iterables**:
for integer in v {
    integer
}

//: And as all **Iterables**, are **Traversable**. Both protocols working together give our vectors access to a great deal of utility functions.
let mappedVector = v.mapConserve({$0 * 2})
mappedVector.description

let filteredVector = v.filter({$0 > 2})
filteredVector.description

let reducedVector = v.reduce(0, combine: {$0 + $1})
reducedVector

//: We can even do cool things like grouping by a function:
let groupByResult = groupByT(v, ∫{(item: (Int)) -> HashableAny in
    if item % 2 == 0 {
        return "Evens"
    } else {
        return "Odds"
    }
})

groupByResult.description
groupByResult["Odds"]!.description
