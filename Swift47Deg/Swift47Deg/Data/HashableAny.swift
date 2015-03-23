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
    
    init(intValue: Int) {
        self.intValue = intValue
        self.stringValue = nil
        self.floatValue = nil
    }
    
    init(floatValue: Double) {
        self.intValue = nil
        self.stringValue = nil
        self.floatValue = floatValue
    }
    
    init(stringValue: String) {
        self.intValue = nil
        self.stringValue = stringValue
        self.floatValue = nil
    }
    
    var debugDescription : String {
        return currentValue.description
    }
    
    var description : String {
        return currentValue.description
    }
}