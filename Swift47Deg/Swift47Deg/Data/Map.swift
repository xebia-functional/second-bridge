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
    
    func filter(includeElement: (AnyObject) -> Bool) -> Map {
        return Map(Swift.filter(self, { (key: HashableAny, value: AnyObject) -> Bool in
            includeElement(value)
        }))
    }
    
    func map(transform: (AnyObject) -> AnyObject) -> Map {
        return Map(Swift.map(self, { (key: Key, value: Value) -> (Key, Value) in
            return (key, transform(value))
        }))
    }
    
    func reduce(initialValue: AnyObject, combine: (AnyObject, AnyObject) -> AnyObject) -> AnyObject {
        return Swift.reduce(self, initialValue) { (currentTotal, currentElement) -> Value in
            return combine(currentTotal, currentElement.1)
        }
    }
}

// MARK: Basic utils
extension Map {
    func keys() -> [HashableAny] {
        return Array(internalDict.keys)
    }
    
    func isEmpty() -> Bool {
        return internalDict.keys.isEmpty
    }
    
    func values() -> [AnyObject] {
        return Array(internalDict.values)
    }
    
    func contains(key: HashableAny) -> Bool {
        return internalDict[key] != nil
    }
    
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
}

// MARK: - Typed map

struct TypedMap<T: Printable> {
    private var internalDict : Dictionary<HashableAny, T>
    
    subscript(key: HashableAny) -> T? {
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

extension TypedMap : DictionaryLiteralConvertible {
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

extension TypedMap : SequenceType {
    typealias Generator = GeneratorOf<(HashableAny, T)>
    
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
extension TypedMap {
    init(_ arrayOfGenerators: [Generator.Element]) {
        self = TypedMap() + arrayOfGenerators
    }
    
    func filter(includeElement: (T) -> Bool) -> TypedMap {
        return TypedMap(Swift.filter(self, { (key: HashableAny, value: T) -> Bool in
            includeElement(value)
        }))
    }
    
    func map(transform: (T) -> T) -> TypedMap {
        return TypedMap(Swift.map(self, { (key: Key, value: Value) -> (Key, Value) in
            return (key, transform(value))
        }))
    }
    
    func reduce<U>(initialValue: U, combine: (U, T) -> U) -> U {
        return Swift.reduce(self, initialValue) { (currentTotal, currentElement) -> U in
            return combine(currentTotal, currentElement.1)
        }
    }
}

// MARK: Basic utils
extension TypedMap {
    func keys() -> [HashableAny] {
        return Array(internalDict.keys)
    }
    
    func isEmpty() -> Bool {
        return internalDict.keys.isEmpty
    }
    
    func values() -> [T] {
        return Array(internalDict.values)
    }
    
    func contains(key: HashableAny) -> Bool {
        return internalDict[key] != nil
    }
    
    func addString(separator: String?) -> String {
        let separatorToUse = (separator != nil) ? separator! : ""
        return self.reduce("", combine: { (currentString, currentItem) -> String in
            currentString + currentItem.description + separatorToUse
        })
    }
}