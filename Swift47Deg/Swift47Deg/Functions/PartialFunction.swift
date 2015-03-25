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

// MARK: - Custom operators

infix operator ||-> { associativity left precedence 140 }
infix operator &&-> { associativity left precedence 140 }

// MARK: - Partial function container

/// Defines a function whose execution is restricted to a certain set of values defined by `isDefinedAt`.
struct PartialFunction<T, U> {
    let function : Function<T, U>
    let isDefinedAt: Function<T, Bool>
    
    /**
    :param: function A function containing the implementation of this PartialFunction.
    :param: isDefinedAt A function that defines the values for whom this PartialFunction is executable
    */
    init(function: Function<T, U>, isDefinedAt: Function<T, Bool>) {
        self.function = function
        self.isDefinedAt = isDefinedAt
    }
}

// MARK: - Or else / And then implementation

/**
Returns a new partial function by chaining two existing partial functions, and its implementation is as follows:
* Check if function `a` is defined for a given value.
* If it is, `a` will be executed and `b` will be ignored.
* If not, `b` will be executed and `a` will be ignored.
*/
func orElse<T, U>(a: PartialFunction<T, U>, b: PartialFunction<T, U>) -> Function<T, U> {
    return Function.arr({ (x: T) -> U in
        if a.isDefinedAt.apply(x) {
            return a.function.apply(x)
        }
        return b.function.apply(x)
    })
}

/**
Returns a new function by chaining two existing functions. First function `a` is evaluated, and its result is then passed to function `b`.
*/
func andThen<T, U, V>(a: Function<T, U>, b: Function<U, V>) -> Function<T, V> {
    return Function.arr({ (x: T) -> V in
        let rA = a.apply(x)
        return b.apply(rA)
    })
}

/**
Returns a new partial function by chaining two existing partial functions, and its implementation is as follows:
* Check if function `left` is defined for a given value.
* If it is, `left` will be executed and `right` will be ignored.
* If not, `left` will be executed and `right` will be ignored.
*/
func ||-><T, U>(a: PartialFunction<T, U>, b: PartialFunction<T, U>) -> Function<T, U> {
    return orElse(a, b)
}

/**
Returns a new function by chaining two existing functions. First function `left` is evaluated, and its result is then passed to function `right`.
*/
func &&-><T, U, V>(a: Function<T, U>, b: Function<U, V>) -> Function<T, V> {
    return andThen(a, b)
}

// MARK: - Partial function builder

infix operator => { associativity left precedence 140 }

/**
Defines a function whose execution is restricted to a certain set of values defined by the left function. i.e. to define a partial function to multiply all even values by two:

Function.arr({ $0 % 2 == 0 }) => Function.arr({ $0 * 2 })
*/
func =><T, U>(isDefinedAt: Function<T, Bool>, function: Function<T, U>) -> PartialFunction<T, U> {
    return PartialFunction<T, U>(function: function, isDefinedAt: isDefinedAt)
}
