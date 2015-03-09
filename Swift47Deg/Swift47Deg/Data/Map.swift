//
//  Map.swift
//  Swift47Deg
//
//  Created by Javier de Silóniz Sandino on 5/3/15.
//  Copyright (c) 2015 47 Degrees. All rights reserved.
//

import Foundation

/// Map | An immutable iterable collection containing pairs of keys and values. Each key is of type HashableAny to allow to have keys with different types (currently supported types are Int, Float, and String). Each value is of type AnyObject which means you can store any type of instance in a Map, but also makes you responsible to downcast its contents to perform operations with returned values.
struct Map {
    private var internalDict : Dictionary<HashableAny, AnyObject>
    
    subscript(key: HashableAny) -> AnyObject? {
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
    typealias Value = AnyObject
    
    init(dictionaryLiteral elements: (Key, Value)...) {
        var tempDict = Dictionary<Key, Value>()
        for element in elements {
            tempDict[element.0] = element.1
        }
        internalDict = tempDict
    }
    
    init(dictionarySource: [Key: Value]) {
        internalDict = dictionarySource
    }
}

extension Map : SequenceType {
    typealias Generator = GeneratorOf<(HashableAny, AnyObject)>
    
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
    func filter(includeElement: (AnyObject) -> Bool) -> Map {
        return Map(Swift.filter(self, { (key: HashableAny, value: AnyObject) -> Bool in
            includeElement(value)
        }))
    }
    
    /**
    Returns a new map containing all the keys/value pairs from the current one that satisfy the `includeElement` closure. Takes into account both values AND keys.
    */
    func filter(includeElement: ((HashableAny, AnyObject)) -> Bool) -> Map {
        return Map(Swift.filter(self, { (key: HashableAny, value: AnyObject) -> Bool in
            includeElement((key, value))
        }))
    }
    
    /**
    Returns a new map containing all the keys from the current one that satisfy the `includeElement` closure.
    */
    func filterKeys(includeElement: (HashableAny) -> Bool) -> Map {
        return self.filter({ (item: (key: HashableAny, value: AnyObject)) -> Bool in
            includeElement(item.key)
        })
    }
    
    /**
    Returns a new map obtained by removing all key/value pairs for which the `removeElement` closure returns true.
    */
    func filterNot(removeElement: ((HashableAny, AnyObject)) -> Bool) -> Map {
        let itemsToExclude = self.filter(removeElement)
        return self -- itemsToExclude.keys
    }
    
    /**
    Returns a new map containing the results of mapping `transform` over its elements.
    */
    func map(transform: (AnyObject) -> AnyObject) -> Map {
        return Map(Swift.map(self, { (key: Key, value: Value) -> (Key, Value) in
            return (key, transform(value))
        }))
    }
    
    /**
    Returns the result of repeatedly calling combine with an accumulated value initialized to `initial` and each element of the current map.
    
    :param: initialValue The initial value used to start the accumulation process
    :param: combine A function that takes the current total of the process and the current item, and returns the next total value.
    */
    func reduce(initialValue: AnyObject, combine: (AnyObject, AnyObject) -> AnyObject) -> AnyObject {
        return Swift.reduce(self, initialValue) { (currentTotal, currentElement) -> Value in
            return combine(currentTotal, currentElement.1)
        }
    }
    
    /**
    Finds the first element of the map satisfying a predicate, if any. Note: might return different results for different runs, as the underlying collection type is unordered.
    
    :param: predicate The predicate to check the map items against
    */
    func find(predicate: ((HashableAny, AnyObject) -> Bool)) -> (HashableAny, AnyObject)? {
        return Swift.filter(self, predicate)[0]
    }
}

// MARK: Basic utils
extension Map {
    /**
    :returns: An array containing all the keys from the current map. Note: might return different results for different runs, as the underlying collection type is unordered.
    */
    var keys : [HashableAny] {
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
    func values() -> [AnyObject] {
        return Array(internalDict.values)
    }
    
    /**
    Checks if a certain key is binded to a value in the current map.
    
    :param: key The key to be checked.
    
    :returns: True if the map contains an element binded to the key.
    */
    func contains(key: HashableAny) -> Bool {
        return internalDict[key] != nil
    }
    
    /** 
    Generate a string composed by the different values contained in the map, concatenated.
    
    :param: separator A string used to separate each element to be concatenated. If it's a nil, the different strings are not separated.
    
    :returns: A string containing all the different values contained in the map
    */
    func addString(separator: String?) -> String {
        let separatorToUse = (separator != nil) ? separator! : ""
        return self.reduce("", combine: { (currentTotal, currentItem) -> AnyObject in
            let currentString = currentTotal as String
            if currentItem is String {
                let itemAsString = currentItem as String
                return currentString + itemAsString + separatorToUse
            } else if (currentItem.description? != nil) {
                let description = currentItem.description!
                return currentString + separatorToUse + description
            }
            return separatorToUse
        }) as String
    }
    
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
    
    :returns: A new typed map containing the elements from the selection
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
                if let value: AnyObject = self[key] {
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
    Checks equality between this and another map. As Maps can hold any type of object, a closure to check equality (and perform casting if needed) between the different values is needed.
    
    :param: equals A closure that check equality between values
    */
    func equals(anotherMap: Map, equals: (AnyObject, AnyObject) -> Bool) -> Bool {
        if self.count == anotherMap.count {
            for (key, value) in self {
                if let anotherValue: AnyObject = anotherMap[key] {
                    if !equals(value, anotherValue) {
                        return false
                    }
                } else {
                    return false
                }
            }
            return true
        }
        return false
    }
    
    /**
    Tests whether a predicate holds for some of the elements of this map.
    
    :param: p Predicate to check against the elements of this map
    */
    func exists(p: ((HashableAny, AnyObject)) -> Bool) -> Bool {
        return self.filter(p).count > 0
    }
}