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

// MARK: - Try pattern matching helpers
public enum TryMatcher<T> {
    case Success(T)
    case Failure(ErrorType)
}

private enum TryError : ErrorType {
    case TryFilterException
}

// MARK: - Try definition
/// Defines a computation that either result in an exception, or return a successfully computed value.
public struct Try<T> {
    private let matchResult : TryMatcher<T>
    
    /**
    - parameter op: A throwable computation to be executed and encapsulated
    */
    public init(@autoclosure _ op: (() throws -> T)) {
        do {
            let result = try op()
            matchResult = TryMatcher<T>.Success(result)
        } catch let e {
            matchResult = TryMatcher<T>.Failure(e)
        }
    }
    
    /**
    Utility constructor to allow compatibility between Try and its match cases (Success and Failure).
    - parameter m: a Success or Failure enum case.
    */
    public init(_ m: TryMatcher<T>) {
        matchResult = m
    }
}

extension Try {
    /**
    - returns: `true` if the encapsulated computation didn't throw an exception.
    */
    public func isSuccess() -> Bool {
        switch self.matchResult {
        case .Success(_): return true
        default: return false
        }
    }
    
    /**
    - returns: `true` if the encapsulated computation did throw an exception.
    */
    public func isFailure() -> Bool {
        return !self.isSuccess()
    }
    
    /**
    - parameter def: A default value to return if the encapsulated computation throws an exception.
    - returns: The result of the encapsulated computation, or a default value if it did throw an exception.
    */
    public func getOrElse(def: T) -> T {
        switch self.matchResult {
        case .Success(let value): return value
        case .Failure(_): return def
        }
    }
    
    private func forceThrow(ex: ErrorType) throws {
        throw(ex)
    }
    
    /**
    - parameter f: A function to filter the result of a computation.
    - returns: Success(x) if the original computation was successful and `f(x)` is `true`. Failure(ex: TryFilterException)
    in case the filter function returned `false`. If the original computation was a failure, it just goes through.
    */
    public func filter(f: T -> Bool) -> Try {
        switch self.matchResult {
        case .Success(let value):
            if f(value) {
                return self
            }
            return Try(.Failure(TryError.TryFilterException))
        case .Failure(_): return self
        }
    }
    
    /**
    Allows recovering from a Failure operation, by applying one of the given partial functions. These partial functions will be 
    evaluated sequentially as in a Pattern Matching. The matching function will be wrapped in a Try and returned to the user.
    - parameter pf: A variadic list of partial functions that will be evaluated as in a Pattern Matching. The result of this process
    will be wrapped in a Try and returned to the user.
    */
    public func recover(pf: PartialFunction<ErrorType, T>...) -> Try<T> {
        return recoverWithArray(pf.map{ $0.flatMap { (x: T) -> Try<T> in return Try(x) }})
    }
    
    /**
    Allows recovering from a Failure operation, by applying one of the given partial functions. These partial functions will be
    evaluated sequentially as in a Pattern Matching. The matching function will be returned to the user.
    - parameter pf: A variadic list of partial functions that will be evaluated as in a Pattern Matching. The result of this process
    will be wrapped in a Try and returned to the user.
    */
    public func recoverWith(pf: PartialFunction<ErrorType, Try<T>>...) -> Try<T> {
        return recoverWithArray(pf)
    }
    
    private func recoverWithArray(pf: [PartialFunction<ErrorType, Try<T>>]) -> Try<T> {
        switch self.matchResult {
        case .Success(_): return self
        case .Failure(let ex): return match(pf).apply(ex)
        }
    }
}

extension Try: Applicative {
    public typealias A = T
    public typealias B = Any
    public typealias FB = Try<B>
    public typealias FAB = Try<A -> B>
    
    /**
    - returns: A `Try` instance wrapping a given value. (Serves as a Point function).
    - parameter a: A value to be wrapped in a Try.
    */
    public static func pure(a : A) -> Try {
        return Try(a)
    }
    
    /**
    - parameter f: A transformation function between the type for our given `Try`, and another type `B`.
    - returns: If our given `Try` is a `Success(x)`, it will return `Try(f(x))`. If not, it will wrap the original
    exception to a `Try` of type `B`.
    */
    public func map<B>(f: T -> B) -> Try<B> {
        switch self.matchResult {
        case .Success(let value): return Try<B>(.Success(f(value)))
        case .Failure(let ex): return Try<B>(.Failure(ex))
        }
    }
    
    /**
    - parameter f: A transformation function between the type for our given `Try`, and another type `B`.
    - returns: If our given `Try` is a `Success(x)`, it will return `Try(f(x))`. If not, it will wrap the original
    exception to a `Try` of type `B`.
    */
    public func fmap<B>(f : A -> B) -> FB {
        return map({ f($0) })
    }
    
    /**
    Applies the function contained inside the provided Try `f`, to the value inside our given `Try` (if it's a `Success`).
    If any of the `Try` instances is a `Failure`, the corresponding exception will fall through and returned to the user.
    - parameter f: A `Try` containing a function of type `F -> B`
    - returns: A `Try` containing the application of the function contained in `f` if both `f` and our given `Try` are
    `Success`. If not, the corresponding exception will be returned wrapped in a `Try` of type `B`.
    */
    public func ap(f : FAB) -> FB {
        switch (self.matchResult, f.matchResult) {
        case (.Failure(let ex), _): return Try<B>(.Failure(ex))
        case (.Success(_), .Success(let fs)): return self.map(fs)
        case (.Success(_), .Failure(let ex)): return Try<B>(.Failure(ex))
        }
    }
}

extension Try: Monad {
    /**
    - parameter f: A transformation function between the type for our given `Try`, and another `Try` of type `B`.
    - returns: If our given `Try` is a `Success(x)`, it will return a `Try` containing the result of `f(x)`.
    If not, it will wrap the original exception to a `Try` of type `B`.
    */
    public func bind(f: Try.A -> Try.FB) -> Try.FB {
        return self.flatMap(f)
    }
    
    /**
    - parameter f: A transformation function between the type for our given `Try`, and another `Try` of type `B`.
    - returns: If our given `Try` is a `Success(x)`, it will return a `Try` containing the result of `f(x)`.
    If not, it will wrap the original exception to a `Try` of type `B`.
    */
    public func flatMap<B>(f: T -> Try<B>) -> Try<B> {
        switch self.matchResult {
        case .Success(let value): return f(value)
        case .Failure(let ex): return Try<B>(.Failure(ex))
        }
    }
}