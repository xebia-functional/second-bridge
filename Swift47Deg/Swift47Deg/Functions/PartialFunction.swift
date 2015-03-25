//
//  PartialFunction.swift
//  Swift47Deg
//
//  Created by Javier de Silóniz Sandino on 25/3/15.
//  Copyright (c) 2015 47 Degrees. All rights reserved.
//

import Foundation
import Swiftz

extension Function {
    typealias A = T
    typealias B = U
    
    
}


struct PartialFunction<T, U> {
    let function : Function<T, U>
    let isDefinedAt: Function<T, Bool>
    
    init(function: Function<T, U>, isDefinedAt: Function<T, Bool>) {
        self.function = function
        self.isDefinedAt = isDefinedAt
    }
}

func buildPartialFunctionOrElse<T, U>(a: PartialFunction<T, U>, b: PartialFunction<T, U>)(value: T) -> Function<T, U> {
    let functionToApply = { (value: T) -> U in
        if a.isDefinedAt.apply(value) {
            return a.function.apply(value)
        }
        return b.function.apply(value)
    }
    return Function.arr(functionToApply)
}

