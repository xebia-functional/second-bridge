//
//  HashableAny.swift
//  Swift47Deg
//
//  Created by Javier de Silóniz Sandino on 5/3/15.
//  Copyright (c) 2015 47 Degrees. All rights reserved.
//

import Foundation

/// HashableAny | A type that can contain a certain value of the following supported types: Int, String, Float.
struct HashableAny: Hashable, IntegerLiteralConvertible, FloatLiteralConvertible, StringLiteralConvertible, Printable, DebugPrintable {
    typealias UnicodeScalarLiteralType = StringLiteralType
    typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    
    let intValue : Int?
    let stringValue : String?
    let floatValue: Double?
    
    var currentValue : AnyObject {
        switch (intValue, stringValue, floatValue) {
        case let (.Some(_integer), _, _): return _integer
        case let (_, .Some(_string), _): return _string
        case let (_, _, .Some(_float)): return _float
        default: return 0
        }
    }
    
    var hashValue : Int {
        return currentValue.hashValue
    }
    
    init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.stringValue = "\(value)"
        self.intValue = nil
        self.floatValue = nil
    }
    
    init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.stringValue = value
        self.intValue = nil
        self.floatValue = nil
    }
    
    init(stringLiteral value: StringLiteralType) {
        self.stringValue = value
        self.intValue = nil
        self.floatValue = nil
    }
    
    init(integerLiteral value: IntegerLiteralType) {
        self.intValue = value
        self.stringValue = nil
        self.floatValue = nil
    }
    
    init(floatLiteral value: FloatLiteralType) {
        self.floatValue = value
        self.intValue = nil
        self.stringValue = nil
    }
    
    var debugDescription : String {
        return currentValue.description
    }
    
    var description : String {
        return currentValue.description
    }
}