//
//  Map.swift
//  Swift47Deg
//
//  Created by Javier de Silóniz Sandino on 9/3/15.
//  Copyright (c) 2015 47 Degrees. All rights reserved.
//

import Foundation

// MARK: - Map declaration and protocol implementations

/// Map | An immutable iterable collection containing pairs of keys and values. Each key is of type HashableAny to allow to have keys with different types (currently supported types are Int, Float, and String). Each value is of a type T. If you need to store values of different types, make an instance of Map<Any>.
struct Map<T> {
    private var internalDict : Dictionary<Key, Value>
    
    subscript(key: Key) -> Value? {
        get {
            return internalDict[key]
        }
        set {
            internalDict[key] = newValue
        }
    }
    
    var count : Int {
        return self.internalDict.count
    }
}

extension Map : DictionaryLiteralConvertible {
    typealias Key = HashableAny
    typealias Value = T
    
    init(dictionaryLiteral elements: (Key, Value)...) {
        var tempDict = Dictionary<Key, Value>()
        for element in elements {
            tempDict[element.0] = element.1
        }
        internalDict = tempDict
    }
}

extension Map : SequenceType {
    typealias Generator = GeneratorOf<(Key, Value)>
    
    func generate() -> Generator {
        var index : Int = 0
        
        return Generator {
            if index < self.internalDict.count {
                let key = Array(self.internalDict.keys)[index]
                index++
                return (key, self.internalDict[key]!)
            }
            return nil
        }
    }
}

// MARK: Higher-order functions

extension Map {
    init(_ arrayOfGenerators: [Generator.Element]) {
        self = Map() + arrayOfGenerators
    }
    
    /**
    Returns a new map containing all the keys from the current map that satisfy the `includeElement` closure. Only takes into account values, not keys.
    */
    func filter(includeElement: (Value) -> Bool) -> Map {
        return Map(Swift.filter(self, { (key: Key, value: Value) -> Bool in
            includeElement(value)
        }))
    }
    
    /**
    Returns a new map containing all the keys/value pairs from the current one that satisfy the `includeElement` closure. Takes into account both values AND keys.
    */
    func filter(includeElement: ((Key, Value)) -> Bool) -> Map {
        return Map(Swift.filter(self, { (key: Key, value: Value) -> Bool in
            includeElement((key, value))
        }))
    }
    
    /**
    Returns a new map containing all the keys from the current one that satisfy the `includeElement` closure.
    */
    func filterKeys(includeElement: (Key) -> Bool) -> Map {
        return self.filter({ (item: (key: Key, value: Value)) -> Bool in
            includeElement(item.key)
        })
    }
    
    /**
    Returns a new map obtained by removing all key/value pairs for which the `removeElement` closure returns true.
    */
    func filterNot(removeElement: ((Key, Value)) -> Bool) -> Map {
        let itemsToExclude = self.filter(removeElement)
        return self -- itemsToExclude.keys
    }
    
    /**
    Returns a new map containing the results of mapping `transform` over its elements.
    */
    func map(transform: (Value) -> Value) -> Map {
        return Map(Swift.map(self, { (key: Key, value: Value) -> (Key, Value) in
            return (key, transform(value))
        }))
    }
    
    /**
    Returns the result of repeatedly calling combine with an accumulated value initialized to `initial` and each element's value of the current map.
    */
    func reduceByValue<U>(initialValue: U, combine: (U, Value) -> U) -> U {
        return Swift.reduce(self, initialValue) { (currentTotal, currentElement) -> U in
            return combine(currentTotal, currentElement.1)
        }
    }
    
    /**
    Returns the result of repeatedly calling combine with an accumulated value initialized to `initial` and each element (taking also into account the key) of the current map.
    */
    func reduce<U>(initialValue: U, combine: (U, (Key, Value)) -> U) -> U {
        return Swift.reduce(self, initialValue) { (currentTotal, currentElement) -> U in
            return combine(currentTotal, currentElement)
        }
    }
    
    /**
    Returns the first element of the map satisfying a predicate, if any. Note: might return different results for different runs, as the underlying collection type is unordered.
    
    :param: predicate The predicate to check the map items against
    */
    func find(predicate: ((Key, Value) -> Bool)) -> (Key, Value)? {
        return Swift.filter(self, predicate)[0]
    }
}

// MARK: Basic functions

extension Map {
    /**
    :returns: An array containing all the keys from the current map. Note: might return different results for different runs, as the underlying collection type is unordered.
    */
    var keys : [Key] {
        return Array(internalDict.keys)
    }
    
    /**
    :returns: True if the map doesn't contain any element.
    */
    func isEmpty() -> Bool {
        return internalDict.keys.isEmpty
    }
    
    /**
    :returns: An array containing the different values from the current map. Note: might return different results for different runs, as the underlying collection type is unordered.
    */
    func values() -> [Value] {
        return Array(internalDict.values)
    }
    
    /**
    Checks if a certain key is binded to a value in the current map.
    
    :param: key The key to be checked.
    
    :returns: True if the map contains an element binded to the key.
    */
    func contains(key: Key) -> Bool {
        return internalDict[key] != nil
    }
    
    /**
    Tests whether a predicate holds for some of the elements of this map.
    
    :param: p Predicate to check against the elements of this map
    */
    func exists(p: ((Key, Value)) -> Bool) -> Bool {
        return self.filter(p).count > 0
    }
}

// MARK: - addition/removal/modification of elements in the map

extension Map {
    /**
    Selects all elements except the first n ones. Note: might return different results for different runs, as the underlying collection type is unordered.
    
    :param: n Number of elements to be excluded from the selection
    
    :returns: A new map containing the elements from the selection
    */
    func drop(n: Int) -> Map {
        let keys = self.keys
        let keysToExclude = keys.filter({ Swift.find(keys, $0) < n })
        return self -- keysToExclude
    }
    
    /**
    Selects all elements except the last n ones. Note: might return different results for different runs, as the underlying collection type is unordered.
    
    :param: n Number of elements to be excluded from the selection
    
    :returns: A new map containing the elements from the selection
    */
    func dropRight(n: Int) -> Map {
        let keys = self.keys
        let keysToExclude = keys.filter({ Swift.find(keys, $0) >= self.count - n })
        return self -- keysToExclude
    }
    
    /**
    Drops longest prefix of elements that satisfy a predicate. Note: might return different results for different runs, as the underlying collection type is unordered.
    
    :param: n Number of elements to be excluded from the selection
    
    :returns: The longest suffix of this traversable collection whose first element does not satisfy the predicate p.
    */
    func dropWhile(p: (Key, Value) -> Bool) -> Map {
        func findSuffixFirstIndex() -> Int? {
            var count = 0
            for key in self.keys {
                if let value = self[key] {
                    if !p(key, value) {
                        return count
                    }
                }
                count++
            }
            return nil
        }
        
        if let firstIndex = findSuffixFirstIndex() {
            return self.drop(firstIndex)
        }
        return self
    }
    
    /**
    :returns: Returns the first element of this map (if there are any). Note: might return different results for different runs, as the underlying collection type is unordered.
    */
    func head() -> (Key, Value)? {
        if let headKey = self.internalDict.keys.first {
            return (headKey, self[headKey]!)
        }
        return nil
    }
    
    /**
    :returns: Returns all elements except the last (equivalent to Scala's init()). Note: might return different results for different runs, as the underlying collection type is unordered.
    */
    func initSegment() -> Map {
        return self.dropRight(1)
    }
    
    /**
    :returns: Returns the last element as an optional value, or nil if any. Note: might return different results for different runs, as the underlying collection type is unordered.
    */
    func last() -> (Key, Value)? {
        if let lastKey = self.keys.last {
            return (lastKey, self[lastKey]!)
        }
        return nil
    }
    
    /**
    Removes the provided key from the current map, and returns a new map without that key/value binding. Also an optional containing the value bound to the key.
    
    :param: key The key to remove
    */
    func remove(key: HashableAny) -> (Map, Value?) {
        let map = self
        let value = self[key]
        return (map - key, value)
    }
    
    /**
    Removes the provided key from the current map, and returns an optional containing the value bound to that key.
    
    :param: key The key to remove
    */
    mutating func remove(key: HashableAny) -> Value? {
        let value = self[key]
        self = self - key
        return value
    }
}

// MARK: - numeric operations
extension Map {
    private func convertValueToNumber(value: Value) -> Double? {
        switch value {
        case let number as Double: return number
        case let number as Int: return Double(number)
        case let numberString as String:
            if let number = NSNumberFormatter().numberFromString(numberString) {
                return number.doubleValue
            }
            return nil
        default: return nil
        }
    }
    
    /**
    Applies a binary numeric operation to each value contained in the map, if it's castable to a number. If a value contains a String representation of a number, its content will be converted to a Double value suitable for the multiplication. Any other value will be ignored.
    */
    func applyNumericOperation(initialValue: Double, f: (Double, Double) -> Double) -> Double {
        return self.reduce(initialValue, combine: { (currentTotal: Double, currentItem: (Key, Value)) -> Double in
            if let number = self.convertValueToNumber(currentItem.1) {
                return f(currentTotal, number)
            }
            return currentTotal
        })
    }
    
    /**
    :returns: The product of the multiplication of each value contained in the map, if it's castable to a number. If a value contains a String representation of a number, its content will be converted to a Double value suitable for the multiplication. Any other value will be ignored.
    */
    func product() -> Double {
        return self.applyNumericOperation(1, *)
    }
    
    /**
    :returns: The product of the sum of each value contained in the map, if it's castable to a number. If a value contains a String representation of a number, its content will be converted to a Double value suitable for the multiplication. Any other value will be ignored.
    */
    func sum() -> Double {
        return self.applyNumericOperation(0, +)
    }
    
    /**
    :returns: Returns the maximum value of the results of applying the function `f` to each element of the map as an optional value, or nil if the map is empty. The result type of `f` is expected to return a type conforming to the Comparable protocol.
    */
    func maxBy<U: Comparable>(f: (Value) -> U) -> (Key, Value)? {
        return comparisonBy(f, compareFunction: { $1 > $0 })
    }
    
    /**
    :returns: Returns the minimum value of the results of applying the function `f` to each element of the map as an optional value, or nil if the map is empty. The result type of `f` is expected to return a type conforming to the Comparable protocol.
    */
    func minBy<U: Comparable>(f: (Value) -> U) -> (Key, Value)? {
        return comparisonBy(f, compareFunction: { $1 < $0 })
    }
    
    private func comparisonBy<U: Comparable>(f: (Value) -> U, compareFunction: (x: U, y: U) -> Bool) -> (Key, Value)? {
        if !self.isEmpty() {
            let keys = self.keys
            if let firstKey = keys.first {
                return self.reduce((firstKey, self[firstKey]!), combine: { (currentMax: (Key, Value), currentItem: (Key, Value)) -> (Key, Value) in
                    if compareFunction(x: f(currentMax.1), y: f(currentItem.1)) {
                        return currentItem
                    }
                    return currentMax
                })
            }
        }
        return nil
    }
}

// MARK: - string operations
extension Map {
    /**
    Generate a string composed by the different values contained in the map, concatenated.
    
    :param: separator A string used to separate each element to be concatenated. If it's a nil, the different strings are not separated.
    
    :returns: A string containing all the different values contained in the map. If the map contains String values, they'll be concatenated as such. If not, addString relies on String interpolation to perform the concatenation.
    */
    func addString(separator: String?) -> String {
        let separatorToUse = (separator == nil) ? "" : separator!
        let result = self.reduceByValue("", combine: { (result: String, currentValue: T) -> String in
            switch currentValue {
            case let stringValue as String: return result + stringValue + separatorToUse
            default: return result + "\(currentValue)" + separatorToUse
            }
        })
        if separatorToUse == "" {
            return result
        }
        return result.substringToIndex(result.endIndex.predecessor())
    }
}
