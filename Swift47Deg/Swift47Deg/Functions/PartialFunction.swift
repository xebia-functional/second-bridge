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

infix operator |||> { associativity left precedence 140 }
infix operator |-> { associativity left precedence 140 }
prefix operator ∫ {}

// MARK: - Partial function container

/// Defines a function whose execution is restricted to a certain set of values defined by `isDefinedAt`.
public struct PartialFunction<T, U> {
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
public func orElse<T, U>(a: PartialFunction<T, U>, b: PartialFunction<T, U>) -> Function<T, U> {
    return Function.arr({ (x: T) -> U in
        if a.isDefinedAt.apply(x) {
            return a.function.apply(x)
        }
        return b.function.apply(x)
    })
}

/**
Returns a new partial function by chaining two existing partial functions, and its implementation is as follows:
* Check if function `left` is defined for a given value.
* If it is, `left` will be executed and `right` will be ignored.
* If not, `left` will be executed and `right` will be ignored.
*/
public func |||> <T, U>(a: PartialFunction<T, U>, b: PartialFunction<T, U>) -> Function<T, U> {
    return orElse(a, b)
}

// MARK: - Partial function builder

/**
Defines a function whose execution is restricted to a certain set of values defined by the left function. i.e. to define a partial function to multiply all even values by two:

Function({ $0 % 2 == 0 }) |-> Function({ $0 * 2 })
*/
public func |-><T, U>(isDefinedAt: Function<T, Bool>, function: Function<T, U>) -> PartialFunction<T, U> {
    return PartialFunction<T, U>(function: function, isDefinedAt: isDefinedAt)
}

public func |-><T, U>(isDefinedAt: T -> Bool, function: T -> U) -> PartialFunction<T, U> {
    return PartialFunction<T, U>(function: Function(function), isDefinedAt: Function(isDefinedAt))
}

/**
Syntatic sugar, equivalent to Function.arr(T -> U).
Key shortcut: ⌥+S (Unicode 0x222B).
*/
public prefix func ∫ <T, U>(f: T -> U) -> Function<T, U> {
    return Function(f)
}

public extension List {
    public func reduce<B>(f : (B, A) -> B) -> B? {
        
        if let head = self.head() as? B{
            if let tail = self.tail() as Swiftz.List<A>?{
                switch tail.match() {
                case .Nil:
                    return head
                case let .Cons(x, xs):
                    return xs.reduce(f, initial: f(head,x))
                }
            }
            return head
        }
        return nil
    }
}