//
//  Vector.swift
//  Swift47Deg
//
//  Created by Javier de Silóniz Sandino on 22/4/15.
//  Copyright (c) 2015 47 Degrees. All rights reserved.
//

import Foundation

enum VectorType {
    case Zero
    case One
    case Two
    case Three
    case Four
    case Five
    case Six
}

public class Vector<T> {
    
    typealias Array1 = [T]
    typealias Array2 = [[T]]
    typealias Array3 = [[[T]]]
    typealias Array4 = [[[[T]]]]
    typealias Array5 = [[[[[T]]]]]
    typealias Array6 = [[[[[[T]]]]]]
    
    private var tailOff : Int = 0
    private var tail : Array1 = Array1()
    private var trie : VectorCaseGen<T>
    private var length : Int = 0
    
    // MARK: - Initializers
    init(length: Int, trie: VectorCaseGen<T>, tail: Array1) {
        tailOff = length - tail.count
        self.tail = tail
        self.trie = trie
        self.length = length
    }
    
    convenience init() {
        self.init(length: 0, trie: VectorCaseGen<T>(), tail: Array1())
    }
}

// MARK: - Public operations

extension Vector {
    subscript(i: Int) -> T {
        get {
            if i >= 0 && i < length {
                if i >= tailOff {
                    return tail[i & 0x01]
                } else {
                    var arr = trie[i]
                    return arr[i & 0x01]
                }
            } else {
                assertionFailure("Vector index out of bounds: \(i)")
            }
        }
    }
    
    public func append(obj: T) -> Vector<T> {
        if tail.count < 32 {
            var tail2 = tail
            tail2.append(obj)
            return Vector<T>(length: self.length + 1, trie: trie, tail: tail2)
        } else {
            var trie2 = VectorCaseGen<T>(self.trie.append(tail))
            var arrayTail = Vector<T>.Array1()
            arrayTail.append(obj)
            return Vector<T>(length: self.length + 1, trie: trie2, tail: arrayTail)
        }
    }
    
    public func update(i: Int, obj: T) -> Vector<T> {
        if i >= 0 && i < length {
            if i >= tailOff {
                var newTail = tail
                newTail[i & 0x01] = obj
                return Vector(length: length, trie: self.trie, tail: newTail)
            } else {
                var newTrie = VectorCaseGen<T>(trie.update(i, obj: obj))
                return Vector(length: length, trie: newTrie, tail: self.tail)
            }
        } else if i == length {
            return self.append(obj)
        }
        assertionFailure("Vector index out of bounds: \(i)")
    }
    
    public func pop() -> Vector<T> {
        if length == 0 {
            assertionFailure("Cannot pop empty vector")
        } else if length == 1 {
            return Vector(length: 0, trie: VectorCaseGen<T>(), tail: Array1())
        } else if tail.count > 1 {
            var tail2 = tail
            tail2.removeLast()
            return Vector(length: length - 1, trie: trie, tail: tail2)
        } else {
            var pop = trie.pop()
            return Vector(length: length - 1, trie: VectorCaseGen<T>(pop.0), tail: pop.1)
        }
    }
    
    public var count : Int {
        get {
            return self.length
        }
    }
}

class VectorCaseGen<T> {
    typealias ItemType = T
    typealias SelfType = VectorCaseGen<T>
    
    private var one : VectorOne<T>?
    private var two : VectorTwo<T>?
    private var three : VectorThree<T>?
    private var four : VectorFour<T>?
    private var five : VectorFive<T>?
    private var six : VectorSix<T>?
    private var zero = VectorZero<T>()
    
    private init() {
        
    }
    
    private init(_ trie: VectorOne<T>) {
        one = trie
    }
    
    private init(_ trie: VectorTwo<T>) {
        two = trie
    }
    
    private init(_ trie: VectorThree<T>) {
        three = trie
    }
    
    private init(_ trie: VectorFour<T>) {
        four = trie
    }
    
    private init(_ trie: VectorFive<T>) {
        five = trie
    }
    
    private init(_ trie: VectorSix<T>) {
        six = trie
    }
    
    private init(_ trie: Any) {
        switch trie {
        case let instance as VectorOne<T>: one = instance
        case let instance as VectorTwo<T>: two = instance
        case let instance as VectorThree<T>: three = instance
        case let instance as VectorFour<T>: four = instance
        case let instance as VectorFive<T>: five = instance
        case let instance as VectorSix<T>: six = instance
        default: break;
        }
    }
    
    func vectorType() -> VectorType {
        if one != nil {
            return .One
        } else if two != nil {
            return .Two
        } else if three != nil {
            return .Three
        } else if four != nil {
            return .Four
        } else if five != nil {
            return .Five
        } else if six != nil {
            return .Six
        }
        return .Zero
    }
    
    var currentVector : Any {
        get {
            switch vectorType() {
            case .One: return one!
            case .Two: return two!
            case .Three: return three!
            case .Four: return four!
            case .Five: return five!
            case .Six: return six!
            default: return zero
            }
        }
    }
    
    subscript(i: Int) -> Vector<T>.Array1 {
        get {
            switch currentVector {
            case let instance as VectorOne<T>: return instance[i]
            case let instance as VectorTwo<T>: return instance[i]
            case let instance as VectorThree<T>: return instance[i]
            case let instance as VectorFour<T>: return instance[i]
            case let instance as VectorFive<T>: return instance[i]
            case let instance as VectorSix<T>: return instance[i]
            case let instance as VectorZero<T>: return instance[i]
            default: assertionFailure("Vector index error");
            }
        }
    }
    
    func update(i: Int, obj: ItemType) -> Any {
        switch currentVector {
        case let instance as VectorOne<T>: return instance.update(i, obj: obj)
        case let instance as VectorTwo<T>: return instance.update(i, obj: obj)
        case let instance as VectorThree<T>: return instance.update(i, obj: obj)
        case let instance as VectorFour<T>: return instance.update(i, obj: obj)
        case let instance as VectorFive<T>: return instance.update(i, obj: obj)
        case let instance as VectorSix<T>: return instance.update(i, obj: obj)
        case let instance as VectorZero<T>: return instance.update(i, obj: obj)
        default: assertionFailure("Vector index error");
        }
    }
    
    func append(tail: Vector<ItemType>.Array1) -> Any {
        switch currentVector {
        case let instance as VectorOne<T>: return instance.append(tail)
        case let instance as VectorTwo<T>: return instance.append(tail)
        case let instance as VectorThree<T>: return instance.append(tail)
        case let instance as VectorFour<T>: return instance.append(tail)
        case let instance as VectorFive<T>: return instance.append(tail)
        case let instance as VectorSix<T>: return instance.append(tail)
        case let instance as VectorZero<T>: return instance.append(tail)
        default: assertionFailure("Vector index error");
        }
    }
    
    func pop() -> (trie: Any, Vector<ItemType>.Array1) {
        switch currentVector {
        case let instance as VectorOne<T>: return instance.pop()
        case let instance as VectorTwo<T>: return instance.pop()
        case let instance as VectorThree<T>: return instance.pop()
        case let instance as VectorFour<T>: return instance.pop()
        case let instance as VectorFive<T>: return instance.pop()
        case let instance as VectorSix<T>: return instance.pop()
        case let instance as VectorZero<T>: return instance.pop()
        default: assertionFailure("Vector index error");
        }
    }
}


protocol VectorCase {
    typealias ItemType
    typealias SelfType
    
    subscript(i: Int) -> Vector<ItemType>.Array1 { get }
    func update(i: Int, obj: ItemType) -> SelfType
    func append(tail: Vector<ItemType>.Array1) -> Any
    func pop() -> (trie: Any, Vector<ItemType>.Array1)
}

// MARK: - Level 0 operations

class VectorZero<T> : VectorCase {
    typealias ItemType = T
    typealias SelfType = VectorZero<T>
    
    init() {
    
    }
    
    subscript(i: Int) -> Vector<ItemType>.Array1 {
        get {
            assertionFailure("Vector index out of bounds: \(i)")
        }
    }

    func update(i: Int, obj: ItemType) -> SelfType {
        assertionFailure("Vector index out of bounds: \(i)")
    }
    
    func append(tail: Vector<ItemType>.Array1) -> Any {
        return VectorOne(tail)
    }
    
    func pop() -> (trie: Any, Vector<ItemType>.Array1) {
        assertionFailure("Cannot pop an empty Vector")
    }
}

// MARK: - Level 1 operations

class VectorOne<T> : VectorCase {
    typealias ItemType = T
    typealias SelfType = VectorOne<T>
    
    let trie : Vector<T>.Array1
    
    init(_ trie: Vector<T>.Array1) {
        self.trie = trie
    }
    
    subscript(i: Int) -> Vector<ItemType>.Array1 {
        get {
            return self.trie
        }
    }
    
    func update(i: Int, obj: ItemType) -> SelfType {
        var trie2 = self.trie
        trie2[i & 0x01] = obj
        return VectorOne<T>(trie2)
    }
    
    func append(tail: Vector<ItemType>.Array1) -> Any {
        var trie2 = Vector<ItemType>.Array2()
        trie2.append(trie)
        trie2.append(tail)
        return VectorTwo(trie2)
    }
    
    func pop() -> (trie: Any, [ItemType]) {
        return (VectorZero<T>(), trie)
    }
}

// MARK: - Level 2 operations

class VectorTwo<T> : VectorCase {
    typealias ItemType = T
    typealias SelfType = VectorTwo<T>
    
    let trie : Vector<T>.Array2
    
    init(_ trie: Vector<T>.Array2) {
        self.trie = trie
    }
    
    subscript(i: Int) -> Vector<ItemType>.Array1 {
        get {
            return self.trie[(i >> 5) & 0x01]
        }
    }
    
    func update(i: Int, obj: ItemType) -> SelfType {
        var trie2a = trie
        var trie2b = trie2a[(i >> 5) & 0x01]
        
        trie2b[i & 0x01] = obj
        trie2a[(i >> 5) & 0x01] = trie2b
        
        return VectorTwo(trie2a)
    }
    
    func append(tail: Vector<ItemType>.Array1) -> Any {
        if trie.count >= 32 {
            var trie2 = Vector<ItemType>.Array3()
            trie2.append(trie)
            trie2.append(Vector<ItemType>.Array2())
            trie2[1].append(tail)
            return VectorThree<T>(trie2)
        } else {
            var trie2 = trie
            trie2.append(tail)
            return VectorTwo(trie2)
        }
    }
    
    func pop() -> (trie: Any, [ItemType]) {
        if trie.count == 2 {
            return (VectorOne(trie[0]), trie.last!)
        } else {
            var trie2 = trie
            trie2.removeLast()
            return (VectorOne(trie2), trie.last!)
        }
    }
}

// MARK: - Level 3 operations

class VectorThree<T> : VectorCase {
    typealias ItemType = T
    typealias SelfType = VectorThree<T>
    
    let trie : Vector<T>.Array3
    
    init(_ trie: Vector<T>.Array3) {
        self.trie = trie
    }
    
    subscript(i: Int) -> Vector<ItemType>.Array1 {
        get {
            return self.trie[(i >> 10) & 0x01][(i >> 5) & 0x01]
        }
    }
    
    func update(i: Int, obj: ItemType) -> SelfType {
        var trie2a = trie
        var trie2b = trie2a[(i >> 10) & 0x01]
        var trie2c = trie2b[(i >> 5) & 0x01]
        
        trie2c[i & 0x01] = obj
        trie2b[(i >> 5) & 0x01] = trie2c
        trie2a[(i >> 10) & 0x01] = trie2b

        return VectorThree<T>(trie2a)
    }
    
    func append(tail: Vector<ItemType>.Array1) -> Any {
        if trie.last!.count >= 32 {
            if trie.count >= 32 {
                var trie2 = Vector<ItemType>.Array4()
                
                trie2.append(trie)
                trie2.append(Vector<ItemType>.Array3())
                trie2[1].append(Vector<ItemType>.Array2())
                trie2[1][0].append(tail)
                
                return VectorFour(trie2)
            } else {
                var trie2 = trie
                var emptyTrie = Vector<ItemType>.Array2()
                emptyTrie.append(tail)
                trie2.append(emptyTrie)
                return VectorThree<T>(trie2)
            }
        } else {
            var trie2 = trie
            var lastItem = trie2.last!
            lastItem.append(tail)
            trie2[trie2.count - 1] = lastItem
            return VectorThree<T>(trie2)
        }
    }
    
    func pop() -> (trie: Any, [ItemType]) {
        if trie.last!.count == 1 {
            if trie.count == 2 {
                return (VectorTwo<T>(trie[0]), trie.last!.last!)
            } else {
                var trie2 = trie
                trie2.removeLast()
                return (VectorThree<T>(trie2), trie.last!.last!)
            }
        } else {
            var trie2 = trie
            var trie2Last = trie2.last!
            trie2Last.removeLast()
            trie2[trie2.count - 1] = trie2Last
            return (VectorThree<T>(trie2), trie.last!.last!)
        }
    }
}

// MARK: - Level 4 operations

class VectorFour<T> : VectorCase {
    typealias ItemType = T
    typealias SelfType = VectorFour<T>
    
    let trie : Vector<T>.Array4
    
    init(_ trie: Vector<T>.Array4) {
        self.trie = trie
    }
    
    subscript(i: Int) -> Vector<ItemType>.Array1 {
        get {
            return self.trie[(i >> 15) & 0x01][(i >> 10) & 0x01][(i >> 5) & 0x01]
        }
    }
    
    func update(i: Int, obj: ItemType) -> SelfType {
        var trie2a = trie
        var trie2b = trie2a[(i >> 15) & 0x01]
        var trie2c = trie2b[(i >> 10) & 0x01]
        var trie2d = trie2c[(i >> 5) & 0x01]
        
        trie2d[i & 0x01] = obj
        trie2c[(i >> 5) & 0x01] = trie2d
        trie2b[(i >> 10) & 0x01] = trie2c
        trie2a[(i >> 15) & 0x01] = trie2b
        return VectorFour<T>(trie2a)
    }
    
    func append(tail: Vector<ItemType>.Array1) -> Any {
        if trie.last!.last!.count >= 32 {
            if trie.last!.count >= 32 {
                if trie.count >= 32 {
                    var trie2 = Vector<ItemType>.Array5()
                    trie2.append(trie)
                    trie2.append(Vector<ItemType>.Array4())
                    
                    trie2[1].append(Vector<ItemType>.Array3())
                    trie2[1][0].append(Vector<ItemType>.Array2())
                    trie2[1][0][0].append(tail)
                    
                    return VectorFive<T>(trie2)
                } else {
                    var trie2 = trie
                    trie2.append(Vector<ItemType>.Array3())
                    trie2[0].append(Vector<ItemType>.Array2())
                    trie2[0][0].append(tail)
                    
                    return VectorFour<T>(trie2)
                }
            } else {
                var trie2 = trie
                var trie2Last = trie2.last!
                trie2Last.append(Vector<ItemType>.Array2())
                
                var trie2LastLast = trie2Last.last!
                trie2LastLast.append(tail)
                
                trie2Last[trie2Last.count - 1] = trie2LastLast
                trie2[trie2.count - 1] = trie2Last
                
                return VectorFour<T>(trie2)
            }
        } else {
            var trie2 = trie
            var trie2Last = trie2.last!
            var trie2LastLast = trie2Last.last!
            trie2LastLast.append(tail)
            
            trie2Last[trie2Last.count - 1] = trie2LastLast
            trie2[trie2.count - 1] = trie2Last
            return VectorFour<T>(trie2)
        }
    }
    
    func pop() -> (trie: Any, [ItemType]) {
        if trie.last!.last!.count == 1 {
            if trie.last!.count == 1 {
                if trie.count == 2 {
                    return (VectorThree<T>(trie[0]), trie.last!.last!.last!)
                } else {
                    var trie2 = trie
                    trie2.removeLast()
                    return (VectorFour<T>(trie2), trie.last!.last!.last!)
                }
            } else {
                var trie2 = trie
                var trie2Last = trie2.last!
                trie2Last.removeLast()
                trie2[trie2.count - 1] = trie2Last
                return (VectorFour<T>(trie2), trie.last!.last!.last!)
            }
        } else {
            var trie2 = trie
            var trie2Last = trie2.last!
            trie2Last.removeLast()
            var trie2LastLast = trie2Last.last!
            trie2LastLast.removeLast()
            
            trie2Last[trie2Last.count - 1] = trie2LastLast
            trie2[trie2.count - 1] = trie2Last
            
            return (VectorFour<T>(trie2), trie.last!.last!.last!)
        }
    }
}

// MARK: - Level 5 operations

class VectorFive<T> : VectorCase {
    typealias ItemType = T
    typealias SelfType = VectorFive<T>
    
    let trie : Vector<T>.Array5
    
    init(_ trie: Vector<T>.Array5) {
        self.trie = trie
    }
    
    subscript(i: Int) -> Vector<ItemType>.Array1 {
        get {
            return self.trie[(i >> 20) & 0x01][(i >> 15) & 0x01][(i >> 10) & 0x01][(i >> 5) & 0x01]
        }
    }
    
    func update(i: Int, obj: ItemType) -> SelfType {
        var trie2a = trie
        var trie2b = trie2a[(i >> 20) & 0x01]
        var trie2c = trie2b[(i >> 15) & 0x01]
        var trie2d = trie2c[(i >> 10) & 0x01]
        var trie2e = trie2d[(i >> 5) & 0x01]
        
        trie2e[i & 0x01] = obj
        trie2d[(i >> 5) & 0x01] = trie2e
        trie2c[(i >> 10) & 0x01] = trie2d
        trie2b[(i >> 15) & 0x01] = trie2c
        trie2a[(i >> 20) & 0x01] = trie2b
        return VectorFive<T>(trie2a)
    }
    
    func append(tail: Vector<ItemType>.Array1) -> Any {
        if trie.last!.last!.last!.count >= 32 {
            if trie.last!.last!.count >= 32 {
                if trie.last!.count >= 32 {
                    if trie.count >= 32 {
                        var trie2 = Vector<ItemType>.Array6()
                        trie2.append(trie)
                        trie2.append(Vector<ItemType>.Array5())
                        
                        trie2[1].append(Vector<ItemType>.Array4())
                        trie2[1][0].append(Vector<ItemType>.Array3())
                        trie2[1][0][0].append(Vector<ItemType>.Array2())
                        trie2[1][0][0][0].append(tail)
                        
                        return VectorSix<T>(trie2)
                    } else {
                        var trie2 = trie
                        trie2.append(Vector<ItemType>.Array4())
                        trie2[0].append(Vector<ItemType>.Array3())
                        trie2[0][0].append(Vector<ItemType>.Array2())
                        trie2[0][0][0].append(tail)
                        
                        return VectorFive<T>(trie2)
                    }
                } else {
                    var trie2 = trie
                    var trie2Last = trie2.last!
                    
                    trie2Last.append(Vector<ItemType>.Array3())
                    trie2Last[0].append(Vector<ItemType>.Array2())
                    trie2Last[0][0].append(tail)
                    
                    trie2[trie2.count - 1] = trie2Last
                    
                    return VectorFive<T>(trie2)
                }
            } else {
                var trie2 = trie
                var trie2Last = trie2.last!
                var trie2LastLast = trie2.last!.last!
                
                trie2LastLast.append(Vector<ItemType>.Array2())
                trie2LastLast[0].append(tail)
                trie2Last[trie2Last.count - 1] = trie2LastLast
                trie2[trie2.count - 1] = trie2Last
                
                return VectorFive<T>(trie2)
            }
        } else {
            var trie2 = trie
            var trie2Last = trie2.last!
            var trie2LastLast = trie2Last.last!
            var trie2LastLastLast = trie2LastLast.last!
            
            trie2LastLastLast.append(tail)
            
            trie2LastLast[trie2LastLast.count - 1] = trie2LastLastLast
            trie2Last[trie2Last.count - 1] = trie2LastLast
            trie2[trie2.count - 1] = trie2Last
            return VectorFive<T>(trie2)
        }
    }
    
    func pop() -> (trie: Any, [ItemType]) {
        if trie.last!.last!.last!.count == 1 {
            if trie.last!.last!.count == 1 {
                if trie.last!.count == 1 {
                    if trie.count == 2 {
                        return (VectorFour<T>(trie[0]), trie.last!.last!.last!.last!)
                    } else {
                        var trie2 = trie
                        trie2.removeLast()
                        return (VectorFive<T>(trie2), trie.last!.last!.last!.last!)
                    }
                } else {
                    var trie2 = trie
                    var trie2Last = trie2.last!
                    trie2Last.removeLast()
                    trie2[trie2.count - 1] = trie2Last
                    return (VectorFive<T>(trie2), trie.last!.last!.last!.last!)
                }
            } else {
                var trie2 = trie
                var trie2Last = trie2.last!
                trie2Last.removeLast()
                
                var trie2LastLast = trie2Last.last!
                trie2LastLast.removeLast()
                
                trie2Last[trie2Last.count - 1] = trie2LastLast
                trie2[trie2.count - 1] = trie2Last
                return (VectorFive<T>(trie2), trie.last!.last!.last!.last!)
            }
        } else {
            var trie2 = trie
            var trie2Last = trie2.last!
            trie2Last.removeLast()
            
            var trie2LastLast = trie2Last.last!
            trie2LastLast.removeLast()
            
            var trie2LastLastLast = trie2LastLast.last!
            trie2LastLastLast.removeLast()
            
            trie2LastLast[trie2LastLast.count - 1] = trie2LastLastLast
            trie2Last[trie2Last.count - 1] = trie2LastLast
            trie2[trie2.count - 1] = trie2Last
            
            return (VectorFive<T>(trie2), trie.last!.last!.last!.last!)
        }
    }
}

// MARK: - Level 6 operations

class VectorSix<T> : VectorCase {
    typealias ItemType = T
    typealias SelfType = VectorSix<T>
    
    let trie : Vector<T>.Array6
    
    init(_ trie: Vector<T>.Array6) {
        self.trie = trie
    }
    
    subscript(i: Int) -> Vector<ItemType>.Array1 {
        get {
            return self.trie[(i >> 25) & 0x01][(i >> 20) & 0x01][(i >> 15) & 0x01][(i >> 10) & 0x01][(i >> 5) & 0x01]
        }
    }
    
    func update(i: Int, obj: ItemType) -> SelfType {
        var trie2a = trie
        var trie2b = trie2a[(i >> 25) & 0x01]
        var trie2c = trie2b[(i >> 20) & 0x01]
        var trie2d = trie2c[(i >> 15) & 0x01]
        var trie2e = trie2d[(i >> 10) & 0x01]
        var trie2f = trie2e[(i >> 5) & 0x01]
        
        trie2f[i & 0x01] = obj
        trie2e[(i >> 5) & 0x01] = trie2f
        trie2d[(i >> 10) & 0x01] = trie2e
        trie2c[(i >> 15) & 0x01] = trie2d
        trie2b[(i >> 20) & 0x01] = trie2c
        trie2a[(i >> 25) & 0x01] = trie2b
        return VectorSix<T>(trie2a)
    }
   
    func append(tail: Vector<ItemType>.Array1) -> Any {
        if trie.last!.last!.last!.last!.count >= 32 {
            if trie.last!.last!.last!.count >= 32 {
                if trie.last!.last!.count >= 32 {
                    if trie.last!.count >= 32 {
                        if trie.count >= 32 {
                            assertionFailure("Cannot grow vector beyond integer bounds")
                            return VectorZero<T>()
                        } else {
                            var trie2 = trie
                            trie2.append(Vector<ItemType>.Array5())
                            trie2[0].append(Vector<ItemType>.Array4())
                            trie2[0][0].append(Vector<ItemType>.Array3())
                            trie2[0][0][0].append(Vector<ItemType>.Array2())
                            trie2[0][0][0][0].append(tail)
                            
                            return VectorSix<T>(trie2)
                        }
                    } else {
                        var trie2 = trie
                        var trie2Last = trie2.last!
                        
                        trie2Last.append(Vector<ItemType>.Array4())
                        trie2Last[0].append(Vector<ItemType>.Array3())
                        trie2Last[0][0].append(Vector<ItemType>.Array2())
                        trie2Last[0][0][0].append(tail)
                        
                        trie2[trie2.count - 1] = trie2Last
                        return VectorSix<T>(trie2)
                    }
                } else {
                    var trie2 = trie
                    var trie2Last = trie2.last!
                    var trie2LastLast = trie2Last.last!
                    
                    trie2LastLast.append(Vector<ItemType>.Array3())
                    trie2LastLast[0].append(Vector<ItemType>.Array2())
                    trie2LastLast[0][0].append(tail)
                    
                    trie2Last[trie2Last.count - 1] = trie2LastLast
                    trie2[trie2.count - 1] = trie2Last
                    
                    return VectorSix<T>(trie2)
                }
            } else {
                var trie2 = trie
                var trie2Last = trie2.last!
                var trie2LastLast = trie2.last!.last!
                var trie2LastLastLast = trie2.last!.last!.last!
                
                trie2LastLastLast.append(Vector<ItemType>.Array2())
                trie2LastLastLast[0].append(tail)
                
                trie2LastLast[trie2LastLast.count - 1] = trie2LastLastLast
                trie2Last[trie2Last.count - 1] = trie2LastLast
                trie2[trie2.count - 1] = trie2Last
                
                return VectorSix<T>(trie2)
            }
        } else {
            var trie2 = trie
            var trie2Last = trie2.last!
            var trie2LastLast = trie2Last.last!
            var trie2LastLastLast = trie2LastLast.last!
            var trie2LastLastLastLast = trie2LastLastLast.last!
            
            trie2LastLastLastLast.append(tail)
            
            trie2LastLastLast[trie2LastLastLast.count - 1] = trie2LastLastLastLast
            trie2LastLast[trie2LastLast.count - 1] = trie2LastLastLast
            trie2Last[trie2Last.count - 1] = trie2LastLast
            trie2[trie2.count - 1] = trie2Last
            return VectorSix<T>(trie2)
        }
    }
    
    func pop() -> (trie: Any, [ItemType]) {
        if trie.last!.last!.last!.last!.count == 1 {
            if trie.last!.last!.last!.count == 1 {
                if trie.last!.last!.count == 1 {
                    if trie.last!.count == 1 {
                        if trie.count == 2 {
                            return (VectorFive<T>(trie[0]), trie.last!.last!.last!.last!.last!)
                        } else {
                            var trie2 = trie
                            trie2.removeLast()
                            return (VectorSix<T>(trie2), trie.last!.last!.last!.last!.last!)
                        }
                    } else {
                        var trie2 = trie
                        var trie2Last = trie2.last!
                        trie2Last.removeLast()
                        
                        trie2[trie2.count - 1] = trie2Last
                        return (VectorSix<T>(trie2), trie.last!.last!.last!.last!.last!)
                    }
                } else {
                    var trie2 = trie
                    var trie2Last = trie2.last!
                    trie2Last.removeLast()
                    
                    var trie2LastLast = trie2Last.last!
                    trie2LastLast.removeLast()
                    
                    trie2Last[trie2Last.count - 1] = trie2LastLast
                    trie2[trie2.count - 1] = trie2Last
                    return (VectorSix<T>(trie2), trie.last!.last!.last!.last!.last!)
                }
            } else {
                var trie2 = trie
                var trie2Last = trie2.last!
                trie2Last.removeLast()
                
                var trie2LastLast = trie2Last.last!
                trie2LastLast.removeLast()
                
                var trie2LastLastLast = trie2LastLast.last!
                trie2LastLastLast.removeLast()
                
                trie2LastLast[trie2LastLast.count - 1] = trie2LastLastLast
                trie2Last[trie2Last.count - 1] = trie2LastLast
                trie2[trie2.count - 1] = trie2Last
                return (VectorSix<T>(trie2), trie.last!.last!.last!.last!.last!)
            }
        } else {
            var trie2 = trie
            var trie2Last = trie2.last!
            trie2Last.removeLast()
            
            var trie2LastLast = trie2Last.last!
            trie2LastLast.removeLast()
            
            var trie2LastLastLast = trie2LastLast.last!
            trie2LastLastLast.removeLast()
            
            var trie2LastLastLastLast = trie2LastLastLast.last!
            trie2LastLastLastLast.removeLast()
            
            trie2LastLastLast[trie2LastLastLast.count - 1] = trie2LastLastLastLast
            trie2LastLast[trie2LastLast.count - 1] = trie2LastLastLast
            trie2Last[trie2Last.count - 1] = trie2LastLast
            trie2[trie2.count - 1] = trie2Last
            
            return (VectorSix<T>(trie2), trie.last!.last!.last!.last!.last!)
        }
    }
}

// MARK: - Vector Builder

class VectorBuilder<T> {
    private var buffer = Array<T>()
    
    let ZeroThresh = 0
    let OneThresh = 32
    let TwoThresh = 32 << 5
    let ThreeThresh = 32 << 10
    let FourThresh = 32 << 15
    let FiveThresh = 32 << 20
    let SixThresh = 32 << 25
    
    func append(obj: T) {
        buffer.append(obj)
    }
    
    func result() -> Vector<T> {
        let tailLength = (buffer.count % 32 == 0) ? 32 : buffer.count % 32
        let trieBuffer = buffer[0..<(buffer.count - tailLength)]
        let tailBuffer = buffer[(buffer.count - tailLength)..<buffer.count]
        
        var trie : VectorCaseGen<T>
        
        if trieBuffer.count <= ZeroThresh {
            trie = VectorCaseGen<T>(VectorZero<T>())
        } else if trieBuffer.count <= OneThresh {
            trie = VectorCaseGen<T>(VectorOne<T>(fillArray1(trieBuffer)))
        } else if trieBuffer.count <= TwoThresh {
            trie = VectorCaseGen<T>(VectorTwo<T>(fillArray2(trieBuffer)))
        } else if trieBuffer.count <= ThreeThresh {
            trie = VectorCaseGen<T>(VectorThree<T>(fillArray3(trieBuffer)))
        } else if trieBuffer.count <= FourThresh {
            trie = VectorCaseGen<T>(VectorFour<T>(fillArray4(trieBuffer)))
        } else if trieBuffer.count <= FiveThresh {
            trie = VectorCaseGen<T>(VectorFive<T>(fillArray5(trieBuffer)))
        } else if trieBuffer.count <= SixThresh {
            trie = VectorCaseGen<T>(VectorSix<T>(fillArray6(trieBuffer)))
        } else {
            assertionFailure("Cannot build vector with length which exceeds MAX_INT")
        }
        
        return Vector<T>(length: buffer.count, trie: trie, tail: fillArray1(tailBuffer))
    }
}

// MARK: - Empty array creators:

extension VectorBuilder {
    func emptyArray2(count: Int) -> Vector<T>.Array2 {
        return Vector<T>.Array2(count: count, repeatedValue: Vector<T>.Array1())
    }
    
    func emptyArray3(count: Int) -> Vector<T>.Array3 {
        return Vector<T>.Array3(count: count, repeatedValue: emptyArray2(0))
    }
    
    func emptyArray4(count: Int) -> Vector<T>.Array4 {
        return Vector<T>.Array4(count: count, repeatedValue: emptyArray3(0))
    }
    
    func emptyArray5(count: Int) -> Vector<T>.Array5 {
        return Vector<T>.Array5(count: count, repeatedValue: emptyArray4(0))
    }
    
    func emptyArray6(count: Int) -> Vector<T>.Array6 {
        return Vector<T>.Array6(count: count, repeatedValue: emptyArray5(0))
    }
}

extension VectorBuilder {
    func fillArray1(seq: Slice<T>) -> Vector<T>.Array1 {
        return Vector<T>.Array1(seq)
    }
    
    func fillArray2(seq: Slice<T>) -> Vector<T>.Array2 {
        let cellSize = OneThresh
        let length = (seq.count % cellSize == 0) ? seq.count / cellSize : (seq.count / cellSize) + 1
        var back = Vector<T>.Array2()
        
        for i in 0..<length {
            let buffer = seq[i * cellSize..<min((i + 1) * cellSize, seq.count)]
            back.append(fillArray1(buffer))
        }
        return back
    }
    
    func fillArray3(seq: Slice<T>) -> Vector<T>.Array3 {
        let cellSize = TwoThresh
        let length = (seq.count % cellSize == 0) ? seq.count / cellSize : (seq.count / cellSize) + 1
        var back = Vector<T>.Array3()
        
        for i in 0..<length {
            let buffer = seq[i * cellSize..<min((i + 1) * cellSize, seq.count)]
            back.append(fillArray2(buffer))
        }
        return back
    }
    
    func fillArray4(seq: Slice<T>) -> Vector<T>.Array4 {
        let cellSize = ThreeThresh
        let length = (seq.count % cellSize == 0) ? seq.count / cellSize : (seq.count / cellSize) + 1
        var back = Vector<T>.Array4()
        
        for i in 0..<length {
            let buffer = seq[i * cellSize..<min((i + 1) * cellSize, seq.count)]
            back.append(fillArray3(buffer))
        }
        return back
    }
    
    func fillArray5(seq: Slice<T>) -> Vector<T>.Array5 {
        let cellSize = FourThresh
        let length = (seq.count % cellSize == 0) ? seq.count / cellSize : (seq.count / cellSize) + 1
        var back = Vector<T>.Array5()
        
        for i in 0..<length {
            let buffer = seq[i * cellSize..<min((i + 1) * cellSize, seq.count)]
            back.append(fillArray4(buffer))
        }
        return back
    }
    
    func fillArray6(seq: Slice<T>) -> Vector<T>.Array6 {
        let cellSize = FiveThresh
        let length = (seq.count % cellSize == 0) ? seq.count / cellSize : (seq.count / cellSize) + 1
        var back = Vector<T>.Array6()
        
        for i in 0..<length {
            let buffer = seq[i * cellSize..<min((i + 1) * cellSize, seq.count)]
            back.append(fillArray5(buffer))
        }
        return back
    }
}