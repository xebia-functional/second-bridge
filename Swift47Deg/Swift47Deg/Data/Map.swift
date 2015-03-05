//
//  Map.swift
//  Swift47Deg
//
//  Created by Javier de Silóniz Sandino on 5/3/15.
//  Copyright (c) 2015 47 Degrees. All rights reserved.
//

import Foundation

struct Map<T>: DictionaryLiteralConvertible, SequenceType {
    var internalDict : Dictionary<HashableAny, T>
    typealias Key = HashableAny
    typealias Value = T
    typealias Generator = GeneratorOf<(HashableAny, T)>
    
    init(dictionaryLiteral elements: (Key, Value)...) {
        var tempDict = Dictionary<HashableAny, T>()
        for element in elements {
            tempDict[element.0] = element.1
        }
        internalDict = tempDict
    }
    
    subscript(key: HashableAny) -> T? {
        get {
            return internalDict[key]
        }
        set {
            internalDict[key] = newValue
        }
    }
    
    func generate() -> Generator {
        var index : Int = 0
        return GeneratorOf {
            if index < self.internalDict.count {
                let key = Array(self.internalDict.keys)[index]
                return (key, self.internalDict[key]!)
            }
            return nil
        }
    }
}