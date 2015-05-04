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

let str = "Playground List Koans"

//== tests equality (same content)
var a : ListT<Int> = [1,2,3,4]
var b : ListT<Int> = [1,2,3,4]
a == b


//Lists are easily created
var d : ListT = [1,2,3,4]

//Lists can be accessed via head and tail
d.head() == 1
let dTail : ListT = [2,3,4]
d.tail() == dTail

//Lists can be accessed by position
var e : ListT = [1,3,5,7,9]
e[0] == 1
e[2] == 5
e[4] == 9

//Lists are immutable
var f : ListT = [1,3,5,7,9]
var g : ListT = f.filterNot({$0 == 1})

//Lists have many useful methods
var h : ListT = [1,3,5,7,9]

// get the length of the list
h.length() == 5

// reverse the list
h.reverse()
























