//
//  Future.swift
//  SecondBridge
//
//  Created by Javier de Silóniz Sandino on 9/10/15.
//  Copyright © 2015 47 Degrees. All rights reserved.
//

import Foundation

public struct Future<T> {
    
    public init(@autoclosure _ op: () -> T) {
        
    }
}