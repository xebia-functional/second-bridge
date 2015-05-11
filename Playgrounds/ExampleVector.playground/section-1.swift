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

// Vectors can be created by using an array literal
var vector : Vector<Int> = [1, 2, 3, 4, 5]
vector.description

// But it's better to do this by using this function
vector = Vector<Int>.build([1, 2, 3, 4, 5])
vector.description

// You can add more elements to an existing vector by using the append function or the `+` operator
vector = vector + 6
vector.description

// And by popping you can remove the last element in the vector
vector = vector.pop()
vector.description

// Vectors are Iterables:
for integer in vector {
    integer
}

// And as all Iterables, are Traversable. Both protocols working together give our vectors access to a great deal of utility functions.
let mappedVector = vector.mapConserve({$0 * 2})
mappedVector.description

let filteredVector = vector.filter({$0 > 2})
filteredVector.description

let reducedVector = vector.reduce(0, combine: {$0 + $1})
reducedVector

// We can even do cool things like grouping by a function:
let groupByResult = groupByT(vector, ∫{(item: (Int)) -> HashableAny in
    if item % 2 == 0 {
        return "Evens"
    } else {
        return "Odds"
    }
})
groupByResult.description
groupByResult["Odds"]!.description