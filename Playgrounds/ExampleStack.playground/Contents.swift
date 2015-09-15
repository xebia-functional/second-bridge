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
# Stacks

SecondBridge includes an implementation for a basic but completely functional LIFO struct. That is: every operation performed on a Stack will always return a new Stack with the resulting changes.

Stacks implement both *Traversable* and *Iterable* protocols, which means that they can be used a lot of really
useful functions. In fact, most of them are implemented as accesors in the Stack struct.

In the next lines of code, we explore some basics of the use of SecondBridge's Stacks. Remember that you can take a look
at our test classes to learn more about all their available functions.
*/

//: Stacks are created like this:
let s = Stack<Int>()
let top = s.top()
//: You can use the push operation to add new elements to a stack. The one at the top is always the last to be added:
let s2 = s.push(1).push(2).push(3)
s2.description

s2.top()
//: Then you can use the pop operation to take new elements from the stack, also getting a new stack with that element removed.
let poppedStack = s.pop().stack
poppedStack.description
//: Stacks are **Traversable** and **Iterable**, that means that you can create them easily using Swift arrays
let stackFromArray = Stack<Int>([1, 2, 3, 4, 5])
stackFromArray.description

//: And also you have access to the broad array of functions available:
let mappedStack = s.mapConserve({$0 * 2})
mappedStack.description

let reduceStack = s.reduce(0, combine: { $0 + $1 })
reduceStack

