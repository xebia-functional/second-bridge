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

struct Try<T> {
    private let operation : (() throws -> T)
    private let matchResult : TryMatcher<T>
    
    init(op: (() throws -> T)) {
        operation = op
        do {
            let result = try op()
            matchResult = TryMatcher<T>.Success(result)
        } catch let e {
            matchResult = TryMatcher<T>.Failure(e)
        }
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
    
    private func forceThrow(ex: ErrorType) throws {
        throw(ex)
    }
    
    
}
