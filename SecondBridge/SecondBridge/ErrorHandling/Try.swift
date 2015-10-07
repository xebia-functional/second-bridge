//
//  Try.swift
//  SecondBridge
//
//  Created by Javier de Silóniz Sandino on 6/10/15.
//  Copyright © 2015 47 Degrees. All rights reserved.
//

import Foundation

enum TryMatcher<T> {
    case Success(T)
    case Failure(ErrorType)
}

enum TryError : ErrorType {
    case TryFilterException
}

struct Try<T> {
    private let matchResult : TryMatcher<T>
    
    init(@autoclosure op: (() throws -> T)) {
        do {
            let result = try op()
            matchResult = TryMatcher<T>.Success(result)
        } catch let e {
            matchResult = TryMatcher<T>.Failure(e)
        }
    }
    
    init(m: TryMatcher<T>) {
        matchResult = m
    }
    
    func match() -> TryMatcher<T> {
        return matchResult
    }
    
    func isSuccess() -> Bool {
        switch self.match() {
        case .Success(_): return true
        default: return false
        }
    }
    
    func isFailure() -> Bool {
        return !self.isSuccess()
    }
    
    func get() -> T? {
        switch self.match() {
        case .Success(let value): return value
        case .Failure(let ex): try! forceThrow(ex)
        }
        return nil
    }
    
    func getOrElse(def: T) -> T {
        switch self.match() {
        case .Success(let value): return value
        case .Failure(_): return def
        }
    }
    
    private func forceThrow(ex: ErrorType) throws {
        throw(ex)
    }
    
    func map<B>(f: T -> B) -> Try<B> {
        switch self.match() {
        case .Success(let value): return Try<B>(m: TryMatcher.Success(f(value)))
        case .Failure(let ex): return Try<B>(m: TryMatcher.Failure(ex))
        }
    }
    
    func flatMap<B>(f: T -> Try<B>) -> Try<B> {
        switch self.match() {
        case .Success(let value): return f(value)
        case .Failure(let ex): return Try<B>(m: TryMatcher.Failure(ex))
        }
    }
    
    func filter(f: T -> Bool) -> Try {
        switch self.match() {
        case .Success(let value):
            if f(value) {
                return self
            }
            return Try(m: TryMatcher.Failure(TryError.TryFilterException))
        case .Failure(_): return self
        }
    }
}
