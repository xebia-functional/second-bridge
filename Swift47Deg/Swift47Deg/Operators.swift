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

// MARK: - Equality
// MARK: HashableAny equality

func ==(lhs: HashableAny, rhs: HashableAny) -> Bool {
    switch (lhs.intValue, rhs.intValue, lhs.stringValue, rhs.stringValue, lhs.floatValue, rhs.floatValue) {
    case let (.Some(_leftInt), .Some(_rightInt), _, _, _, _): return _leftInt == _rightInt
    case let (_, _, .Some(_leftString), .Some(_rightString), _, _): return _leftString == _rightString
    case let (_, _, _, _, .Some(_leftFloat), .Some(_rightFloat)): return _leftFloat == _rightFloat
    default: return false
    }
}

func ==<T: Equatable>(lhs: Map<T>, rhs: Map<T>) -> Bool {
    if lhs.size == rhs.size {
        for key in rhs.keys {
            switch (lhs[key], rhs[key]) {
            case let(.Some(leftValue), .Some(rightValue)):
                if leftValue != rightValue {
                    return false
                }
            default: return false
            }
        }
        return true
    }
    return false
}

// MARK: - Operators
// MARK: Dictionary

/// Append dictionary | Appends the contents of the second dictionary to the first. Keys are added to the first dictionary if they don't exist, or their values overwritten if they do.
func +<T, U> (left: [T:U], right: [T:U]) -> [T:U] {
    var result = left
    for (key, value) in right {
        result[key] = value
    }
    return result
}

/// Append tuple | Appends one key/value pair contained in a tuple with the format (key, value).
func +<T,U> (left: [T:U], right: (T,U)) -> [T:U] {
    var result = left
    result[right.0] = right.1
    return result
}

/// Append tuple array | Appends an array of tuples containing key/value pairs with the format (key, value).
func +<T,U> (left: [T:U], right: [(T,U)]) -> [T:U] {
    var result = left
    for tuple in right {
        result = result + tuple
    }
    return result
}

/// Append dictionary | Appends the contents of the second dictionary to the first. Keys are added to the first dictionary if they don't exist, or their values overwritten if they do.
func +=<T,U> (left: [T:U], right: [T:U]) -> [T:U] {
    return left + right
}

/// Append tuple | Appends one key/value pair contained in a tuple with the format (key, value).
func +=<T,U> (left: [T:U], right: (T,U)) -> [T:U] {
    return left + right
}

/// Append tuple array | Appends an array of tuples containing key/value pairs with the format (key, value).
func +=<T,U> (left: [T:U], right: [(T,U)]) -> [T:U] {
    return left + right
}

/// Remove key | Removes a given key from the dictionary. If it's not contained in the dictionary, nothing happens.
func -<T, U> (left: [T:U], right: T) -> [T:U] {
    var result = left
    result[right] = nil
    return result
}

/// Remove key | Removes a given key from the dictionary. If it's not contained in the dictionary, nothing happens.
func -=<T,U> (left: [T:U], right: T) -> [T:U] {
    return left - right
}

infix operator -- { associativity left precedence 140 }
infix operator --= { associativity left precedence 140 }

/// Remove keys | Removes the keys contained in an array from the source dictionary. If they're not contained in the dictionary, nothing happens.
func --<T, U> (left: [T:U], right: [T]) -> [T:U] {
    var result = left
    for key in right {
        result = result - key
    }
    return result
}

/// Remove keys | Removes the keys contained in an array from the source dictionary. If they're not contained in the dictionary, nothing happens.
func --=<T,U> (left: [T:U], right: [T]) -> [T:U] {
    return left -- right
}


// MARK: Maps
/// Append typed map | Appends the contents of the second map to the first. Keys are added to the first map if they don't exist, or their values overwritten if they do.
func +<T> (left: Map<T>, right: Map<T>) -> Map<T> {
    var result = left
    for (key, value) in right {
        result[key] = value
    }
    return result
}

/// Append typed map | Appends the contents of the second map to the first. Keys are added to the first map if they don't exist, or their values overwritten if they do.
func +=<T> (inout left: Map<T>, right: Map<T>) {
    left = left + right
}

/// Append tuple | Appends one key/value pair contained in a tuple with the format (key, value).
func +<T> (left: Map<T>, right: (HashableAny, T)) -> Map<T> {
    var result = left
    result[right.0] = right.1
    return result
}

/// Append tuple | Appends one key/value pair contained in a tuple with the format (key, value).
func +=<T> (inout left: Map<T>, right: (HashableAny, T)) {
    left = left + right
}

/// Append tuple array | Appends an array of tuples containing key/value pairs with the format (key, value).
func +<T> (left: Map<T>, right: [(HashableAny, T)]) -> Map<T> {
    var result = left
    for tuple in right {
        result = result + tuple
    }
    return result
}

/// Append tuple array | Appends an array of tuples containing key/value pairs with the format (key, value).
func +=<T> (inout left: Map<T>, right: [(HashableAny, T)]) {
    left = left + right
}

/// Remove key | Removes a given key from the typed map. If it's not contained in the map, nothing happens.
func -<T> (left: Map<T>, right: HashableAny) -> Map<T> {
    var result = left
    result[right] = nil
    return result
}

/// Remove key | Removes a given key from the typed map. If it's not contained in the map, nothing happens.
func -=<T> (inout left: Map<T>, right: HashableAny) {
    return left = left - right
}

/// Remove keys | Removes the keys contained in an array from the source typed map. If they're not contained in the map, nothing happens.
func --<T> (left: Map<T>, right: [HashableAny]) -> Map<T> {
    var result = left
    for key in right {
        result = result - key
    }
    return result
}

/// Remove keys | Removes the keys contained in an array from the source typed map. If they're not contained in the map, nothing happens.
func --=<T> (inout left: Map<T>, right: [HashableAny]) {
    left = left -- right
}