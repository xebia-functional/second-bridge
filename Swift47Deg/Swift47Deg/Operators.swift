//
//  Operators.swift
//  Swift47Deg
//
//  Created by Javier de Silóniz Sandino on 5/3/15.
//  Copyright (c) 2015 47 Degrees. All rights reserved.
//

// MARK: - HashableAny equality

func ==(lhs: HashableAny, rhs: HashableAny) -> Bool {
    switch (lhs.intValue, rhs.intValue, lhs.stringValue, rhs.stringValue, lhs.floatValue, rhs.floatValue) {
    case let (.Some(_leftInt), .Some(_rightInt), _, _, _, _): return _leftInt == _rightInt
    case let (_, _, .Some(_leftString), .Some(_rightString), _, _): return _leftString == _rightString
    case let (_, _, _, _, .Some(_leftFloat), .Some(_rightFloat)): return _leftFloat == _rightFloat
    default: return false
    }
}

// MARK: - Dictionary operators

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


// MARK: - Maps operators

/// Append map | Appends the contents of the second map to the first. Keys are added to the first map if they don't exist, or their values overwritten if they do.
func + (left: Map, right: Map) -> Map {
    var result = left
    for (key, value) in right {
        result[key] = value
    }
    return result
}

/// Append map | Appends the contents of the second map to the first. Keys are added to the first map if they don't exist, or their values overwritten if they do.
func += (inout left: Map, right: Map) {
    left = left + right
}

/// Append tuple | Appends one key/value pair contained in a tuple with the format (key, value).
func + (left: Map, right: (HashableAny, AnyObject)) -> Map {
    var result = left
    result[right.0] = right.1
    return result
}

/// Append tuple | Appends one key/value pair contained in a tuple with the format (key, value).
func += (inout left: Map, right: (HashableAny, AnyObject)) {
    left = left + right
}

/// Append tuple array | Appends an array of tuples containing key/value pairs with the format (key, value).
func + (left: Map, right: [(HashableAny, AnyObject)]) -> Map {
    var result = left
    for tuple in right {
        result = result + tuple
    }
    return result
}

/// Append tuple array | Appends an array of tuples containing key/value pairs with the format (key, value).
func += (inout left: Map, right: [(HashableAny, AnyObject)]) {
    left = left + right
}

/// Remove key | Removes a given key from the map. If it's not contained in the map, nothing happens.
func - (left: Map, right: HashableAny) -> Map {
    var result = left
    result[right] = nil
    return result
}

/// Remove key | Removes a given key from the map. If it's not contained in the map, nothing happens.
func -= (inout left: Map, right: HashableAny) {
    return left = left - right
}

/// Remove keys | Removes the keys contained in an array from the source map. If they're not contained in the map, nothing happens.
func -- (left: Map, right: [HashableAny]) -> Map {
    var result = left
    for key in right {
        result = result - key
    }
    return result
}

/// Remove keys | Removes the keys contained in an array from the source map. If they're not contained in the map, nothing happens.
func --= (inout left: Map, right: [HashableAny]) {
    left = left -- right
}