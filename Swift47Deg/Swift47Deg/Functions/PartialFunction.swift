//
//  PartialFunction.swift
//  Swift47Deg
//
//  Created by Javier de Silóniz Sandino on 25/3/15.
//  Copyright (c) 2015 47 Degrees. All rights reserved.
//

import Foundation
import Swiftz

infix operator ||-> { associativity left precedence 140 }
infix operator &&-> { associativity left precedence 140 }

struct PartialFunction<T, U> {
    let function : Function<T, U>
    let isDefinedAt: Function<T, Bool>
    
    init(function: Function<T, U>, isDefinedAt: Function<T, Bool>) {
        self.function = function
        self.isDefinedAt = isDefinedAt
    }
}

func buildPartialFunctionOrElse<T, U>(a: PartialFunction<T, U>, b: PartialFunction<T, U>) -> Function<T, U> {
    let functionToApply = { (x: T) -> U in
        if a.isDefinedAt.apply(x) {
            return a.function.apply(x)
        }
        return b.function.apply(x)
    }
    return Function.arr(functionToApply)
}

func buildPartialFunctionAndThen<T, U, V>(a: Function<T, U>, b: Function<U, V>) -> Function<T, V> {
    return Function.arr({ (x: T) -> V in
        let rA = a.apply(x)
        return b.apply(rA)
    })
}

func ||-><T, U>(a: PartialFunction<T, U>, b: PartialFunction<T, U>) -> Function<T, U> {
    return buildPartialFunctionOrElse(a, b)
}

func &&-><T, U, V>(a: Function<T, U>, b: Function<U, V>) -> Function<T, V> {
    return buildPartialFunctionAndThen(a, b)
}