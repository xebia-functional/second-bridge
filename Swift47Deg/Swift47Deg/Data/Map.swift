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
    Returns a new map containing all the keys from the current one that satisfy the `includeElement` closure. Takes into account values AND keys.
    */
    func filter(includeElement: ((HashableAny, AnyObject)) -> Bool) -> Map {
        return Map(Swift.filter(self, { (key: HashableAny, value: AnyObject) -> Bool in
            includeElement((key, value))
        }))
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
    */
    func reduce(initialValue: AnyObject, combine: (AnyObject, AnyObject) -> AnyObject) -> AnyObject {
        return Swift.reduce(self, initialValue) { (currentTotal, currentElement) -> Value in
            return combine(currentTotal, currentElement.1)
        }
    }
}

// MARK: Basic utils
extension Map {
    /**
    :returns: An array containing all the keys from the current map. Note: might return different results for different runs, as the underlying collection type is unordered.
    */
    func keys() -> [HashableAny] {
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
        let keys = self.keys()
        return self.filter({ find(keys, $0.0) >= n })
    }
}