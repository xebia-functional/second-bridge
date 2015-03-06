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
    var internalDict : Dictionary<HashableAny, AnyObject>
    
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
}

extension Map : SequenceType {
    typealias Index = DictionaryIndex<Key, Value>
    typealias Generator = GeneratorOf<(HashableAny, AnyObject)>
    
    func generate() -> Generator {
        var index : Int = 0
        
        return Generator {
            if index < self.internalDict.count {
                let key = Array(self.internalDict.keys)[index]
                println("Index: \(index), count: \(self.internalDict.count), key: \(key), value: \(self.internalDict[key])")
                println(self.internalDict)
                index++
                return (key, self.internalDict[key]!)
            }
            return nil
        }
    }
}

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