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

/*
* This code is an straight port (or at least, as straight as it can be) from the Scala Vector class made by
* Daniel Spiewak, which was part from his awesome talk "Extreme Cleverness: Functional Data Structures in Scala".
* You can (and should) find this talk at this URL: http://www.infoq.com/presentations/Functional-Data-Structures-in-Scala
* and the Scala implementation code at this GitHub repo: https://github.com/djspiewak/extreme-cleverness
*/

import Foundation
import Swiftz

public enum VectorType {
    case Zero
    case One
    case Two
    case Three
    case Four
    case Five
    case Six
}

/// Vector | An immutable Persistent Bit-partitioned Vector Trie containing elements of type T.
@objc public final class Vector<T> {
    
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
    public init(length: Int, trie: VectorCaseGen<T>, tail: Array1) {
        tailOff = length - tail.count
        self.tail = tail
        self.trie = trie
        self.length = length
    }
    
    public convenience init() {
        self.init(length: 0, trie: VectorCaseGen<T>(), tail: Array1())
    }
    
    public convenience init(array: [T]) {
        self.init()
        
        // Not the best way to do it, performance should be much greater using Vector.build(...). Added for convenience:
        let sourceVector = Vector.build(array)
        
        self.tailOff = sourceVector.tailOff
        self.trie = sourceVector.trie
        self.tail = sourceVector.tail
        self.length = sourceVector.length
    }
}

// MARK: - Public operations

extension Vector {
    public subscript(i: Int) -> T {
        get {
            if i >= 0 && i < length {
                if i >= tailOff {
                    return tail[i & 0x01f]
                } else {
                    var arr = trie[i]
                    return arr[i & 0x01f]
                }
            } else {
                assertionFailure("Vector index out of bounds: \(i)")
            }
        }
    }
    
    /**
    * Returns a new Vector containing all the elements of the provided one, and `obj` appended to its tail.
    */
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
    
    /**
    * Returns a new Vector containing all the elements of the provided one, except for the item at `i` position
    * which is updated with the value `obj`.
    */
    public func update(i: Int, obj: T) -> Vector<T> {
        if i >= 0 && i < length {
            if i >= tailOff {
                var newTail = tail
                newTail[i & 0x01f] = obj
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
    
    /**
    * Returns a new Vector containing all the elements of the provided one, except its last one.
    */
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
    
    /**
    * Returns the number of elements contained in the provided Vector.
    */
    public var count : Int {
        get {
            return self.length
        }
    }
}

// MARK: - Operations for testing purposes:

extension Vector {
    /**
    * Returns the depth level of the tries inside this Vector. Implemented for testing purposes only.
    */
    public var debugTrieLevel : VectorType {
        get {
            return self.trie.vectorType()
        }
    }
}

// MARK: - Traversable / Iterable implementations

extension Vector : SequenceType {
    public typealias Generator = GeneratorOf<T>
    
    public func generate() -> Generator {
        var index : Int = 0
        
        return Generator {
            if index < self.count {
                let result = self[index]
                index++
                return result
            }
            return nil
        }
    }
}

// MARK: - Traversable / Iterable implementation

extension Vector : Traversable {
    public func foreach(f: (T) -> ()) {
        for item in self {
            f(item)
        }
    }
    
    /**
    Build a new Vector instance with the elements contained in the `elements` array.
    */
    public class func build(elements: [T]) -> Vector<T> {
        let vectorGen = VectorBuilder(buffer: elements)
        return vectorGen.result()
    }
    
    /**
    Build a new Vector instance with the elements contained in the provided Traversable instance. The provided traversable is expected to contain
    items with the same type as the Stack struct. Items of different types will be discarded.
    */
    public class func buildFromTraversable<U where U : Traversable>(traversable: U) -> Vector<T> {
        return reduceT(traversable, Vector()) { (result, item) -> Vector in
            switch item {
            case let sameTypeItem as T: result.append(sameTypeItem)
            default: break
            }
            return result
        }
    }
}

extension Vector : Iterable {
    
}

// MARK: - Printable

extension Vector : Printable, DebugPrintable {
    public var description : String {
        get {
            return "Vector(\(self.length)): " + mkStringT(self, "[", ", ", "]")
        }
    }
    
    public var debugDescription : String {
        get {
            return self.description
        }
    }
}

// MARK: - Inner stuff

public class VectorCaseGen<T> {
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
        trie2[i & 0x01f] = obj
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
            return self.trie[(i >> 5) & 0x01f]
        }
    }
    
    func update(i: Int, obj: ItemType) -> SelfType {
        var trie2a = trie
        var trie2b = trie2a[(i >> 5) & 0x01f]
        
        trie2b[i & 0x01f] = obj
        trie2a[(i >> 5) & 0x01f] = trie2b
        
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
            return self.trie[(i >> 10) & 0x01f][(i >> 5) & 0x01f]
        }
    }
    
    func update(i: Int, obj: ItemType) -> SelfType {
        var trie2a = trie
        var trie2b = trie2a[(i >> 10) & 0x01f]
        var trie2c = trie2b[(i >> 5) & 0x01f]
        
        trie2c[i & 0x01f] = obj
        trie2b[(i >> 5) & 0x01f] = trie2c
        trie2a[(i >> 10) & 0x01f] = trie2b

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
            return self.trie[(i >> 15) & 0x01f][(i >> 10) & 0x01f][(i >> 5) & 0x01f]
        }
    }
    
    func update(i: Int, obj: ItemType) -> SelfType {
        var trie2a = trie
        var trie2b = trie2a[(i >> 15) & 0x01f]
        var trie2c = trie2b[(i >> 10) & 0x01f]
        var trie2d = trie2c[(i >> 5) & 0x01f]
        
        trie2d[i & 0x01f] = obj
        trie2c[(i >> 5) & 0x01f] = trie2d
        trie2b[(i >> 10) & 0x01f] = trie2c
        trie2a[(i >> 15) & 0x01f] = trie2b
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
                    trie2[trie2.count - 1].append(Vector<ItemType>.Array2())
                    trie2[trie2.count - 1][0].append(tail)
                    
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
            return self.trie[(i >> 20) & 0x01f][(i >> 15) & 0x01f][(i >> 10) & 0x01f][(i >> 5) & 0x01f]
        }
    }
    
    func update(i: Int, obj: ItemType) -> SelfType {
        var trie2a = trie
        var trie2b = trie2a[(i >> 20) & 0x01f]
        var trie2c = trie2b[(i >> 15) & 0x01f]
        var trie2d = trie2c[(i >> 10) & 0x01f]
        var trie2e = trie2d[(i >> 5) & 0x01f]
        
        trie2e[i & 0x01f] = obj
        trie2d[(i >> 5) & 0x01f] = trie2e
        trie2c[(i >> 10) & 0x01f] = trie2d
        trie2b[(i >> 15) & 0x01f] = trie2c
        trie2a[(i >> 20) & 0x01f] = trie2b
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
                        var emptyTrie = Vector<ItemType>.Array4()
                        emptyTrie.append(Vector<ItemType>.Array3())
                        emptyTrie[0].append(Vector<ItemType>.Array2())
                        emptyTrie[0][0].append(tail)
                        
                        trie2.append(emptyTrie)
                        
                        return VectorFive<T>(trie2)
                    }
                } else {
                    var trie2 = trie
                    var trie2Last = trie2.last!
                    
                    var emptyTrie = Vector<ItemType>.Array3()
                    emptyTrie.append(Vector<ItemType>.Array2())
                    emptyTrie[0].append(tail)
                    
                    trie2Last.append(emptyTrie)
                    trie2[trie2.count - 1] = trie2Last
                    
                    return VectorFive<T>(trie2)
                }
            } else {
                var trie2 = trie
                var trie2Last = trie2.last!
                var trie2LastLast = trie2.last!.last!
                
                var emptyTrie = Vector<ItemType>.Array2()
                emptyTrie.append(tail)
                trie2LastLast.append(emptyTrie)
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
            return self.trie[(i >> 25) & 0x01f][(i >> 20) & 0x01f][(i >> 15) & 0x01f][(i >> 10) & 0x01f][(i >> 5) & 0x01f]
        }
    }
    
    func update(i: Int, obj: ItemType) -> SelfType {
        var trie2a = trie
        var trie2b = trie2a[(i >> 25) & 0x01f]
        var trie2c = trie2b[(i >> 20) & 0x01f]
        var trie2d = trie2c[(i >> 15) & 0x01f]
        var trie2e = trie2d[(i >> 10) & 0x01f]
        var trie2f = trie2e[(i >> 5) & 0x01f]
        
        trie2f[i & 0x01f] = obj
        trie2e[(i >> 5) & 0x01f] = trie2f
        trie2d[(i >> 10) & 0x01f] = trie2e
        trie2c[(i >> 15) & 0x01f] = trie2d
        trie2b[(i >> 20) & 0x01f] = trie2c
        trie2a[(i >> 25) & 0x01f] = trie2b
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
                            var emptyTrie = Vector<ItemType>.Array5()
                            emptyTrie.append(Vector<ItemType>.Array4())
                            emptyTrie[0].append(Vector<ItemType>.Array3())
                            emptyTrie[0][0].append(Vector<ItemType>.Array2())
                            emptyTrie[0][0][0].append(tail)
                            
                            trie2.append(emptyTrie)
                            
                            return VectorSix<T>(trie2)
                        }
                    } else {
                        var trie2 = trie
                        var trie2Last = trie2.last!
                        
                        var emptyTrie = Vector<ItemType>.Array4()
                        emptyTrie.append(Vector<ItemType>.Array3())
                        emptyTrie[0].append(Vector<ItemType>.Array2())
                        emptyTrie[0][0].append(tail)
                        
                        trie2Last.append(emptyTrie)
                        trie2[trie2.count - 1] = trie2Last
                        
                        return VectorSix<T>(trie2)
                    }
                } else {
                    var trie2 = trie
                    var trie2Last = trie2.last!
                    var trie2LastLast = trie2Last.last!
                    
                    var emptyTrie = Vector<ItemType>.Array3()
                    emptyTrie.append(Vector<ItemType>.Array2())
                    emptyTrie[0].append(tail)
                    
                    trie2LastLast.append(emptyTrie)
                    trie2Last[trie2Last.count - 1] = trie2LastLast
                    trie2[trie2.count - 1] = trie2Last
                    
                    return VectorSix<T>(trie2)
                }
            } else {
                var trie2 = trie
                var trie2Last = trie2.last!
                var trie2LastLast = trie2.last!.last!
                var trie2LastLastLast = trie2.last!.last!.last!
                
                var emptyTrie = Vector<ItemType>.Array2()
                emptyTrie.append(tail)
                trie2LastLastLast.append(emptyTrie)
                
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
// A direct translation from Scala's version, just changed a little bit to allow creating a Vector from an existing Swift Array.

class VectorBuilder<T> {
    private var buffer : Array<T>
    
    let ZeroThresh = 0
    let OneThresh = 32
    let TwoThresh = 32 << 5
    let ThreeThresh = 32 << 10
    let FourThresh = 32 << 15
    let FiveThresh = 32 << 20
    let SixThresh = 32 << 25
    
    init(buffer: Array<T>) {
        self.buffer = buffer
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
        
        return Vector(length: buffer.count, trie: trie, tail: fillArray1(tailBuffer))
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

// MARK: - Traversable functions accesors
extension Vector {
    /**
    Returns an array containing the results of mapping the partial function `f` over a set of the elements of this Vector that match the condition defined in `f`'s `isDefinedAt`.
    */
    public func collect<U>(f: PartialFunction<T, U>) -> [U] {
        return collectT(self, f)
    }
    
    /**
    Returns the number of elements of this Vector satisfy the given predicate.
    */
    public func count(p: (T) -> Bool) -> Int {
        return countT(self, p)
    }
    
    /**
    Returns a new Stack containing all the elements from the current Vector except the first `n` ones.
    */
    public func drop(n: Int) -> Vector {
        return dropT(self, n)
    }
    
    /**
    Returns a new Vector containing all the elements from the current Vector except the last `n` ones.
    */
    public func dropRight(n: Int) -> Vector {
        return dropRightT(self, n)
    }
    
    /**
    Returns the longest prefix of this Vector whose first element does not satisfy the predicate p.
    */
    public func dropWhile(p: (T) -> Bool) -> Vector {
        return dropWhileT(self, p)
    }
    
    /**
    Returns true if at least one of its elements of this Vector satisfy the given predicate.
    */
    public func exists(p: (T) -> Bool) -> Bool {
        return existsT(self, p)
    }
    
    /**
    Returns a Vector containing all the values from the current one that satisfy the `includeElement` closure.
    */
    public func filter(includeElement: (T) -> Bool) -> Vector {
        return filterT(self, includeElement)
    }
    
    /**
    Returns a new Vector containing all the values from the current one except those that satisfy the `excludeElement` closure.
    */
    public func filterNot(excludeElement: (T) -> Bool) -> Vector {
        return filterNotT(self, excludeElement)
    }
    
    /**
    Returns the first element of this Vector that satisfy the given predicate `p`, if any.
    */
    public func find(p: (T) -> Bool) -> T? {
        return findT(self, p)
    }
    
    /**
    Returns the result of applying `transform` on each element of the Vector , and then flattening the results into an array.
    */
    public func flatMap<U>(transform: (T) -> [U]) -> [U] {
        return flatMapT(self, transform)
    }
    
    /**
    Returns the result of repeatedly calling combine with an accumulated value initialized to `initial` and each element of the current Vector from right to left. A reversal equivalent to `reduce`/`foldLeft`.
    */
    public func foldLeft<U>(initialValue: U, combine: (U, T) -> U) -> U {
        return foldLeftT(self, initialValue, combine)
    }
    
    /**
    Returns the result of repeatedly calling combine with an accumulated value initialized to `initial` and each element of the current Vector from left to right. Equivalent to `reduce`.
    */
    public func foldRight<U>(initialValue: U, combine: (U, T) -> U) -> U {
        return foldRightT(self, initialValue, combine)
    }
    
    /**
    Returns true if all the elements of this Vector satisfy the given predicate.
    */
    public func forAll(p: (T) -> Bool) -> Bool {
        return forAllT(self, p)
    }
    
    /**
    Partitions this Vector into a map of Vectors according to some discriminator function defined by the function `f`. `f` should return a HashableAny for groupBy to be able to build the map.
    
    It's possible to use complex computations made of partial functions (using |||> `orElse` and >>> `andThen` operators), and pattern matching with the use of `match` in the place of `f`. i.e., being `pfA`, `pfB`, `pfC` and `pfD` several partial functions that take a certain value and return a HashableAny, it's possible to group a Vector the following ways:
    
    * array.groupBy(pfa |||> pfb)
    
    * array.groupBy((pfa |||> pfb) >>> pfc)
    
    * array.groupBy(match(pfa, pfb, pfc, pfd))
    */
    public func groupBy(f: Function<T, HashableAny>) -> Map<Vector> {
        return groupByT(self, f)
    }
    
    /**
    :returns: The first element of the Vector , if any.
    */
    public func head() -> T? {
        return headT(self)
    }
    
    /**
    :returns: All the elements of this Vector except the last one.
    */
    public func initSegment() -> Vector {
        return initT(self)
    }
    
    /**
    Returns true if this Vector doesn't contain any elements.
    */
    public func isEmpty() -> Bool {
        return isEmptyT(self)
    }
    
    /**
    Returns an array containing the results of mapping `transform` over the elements of the current Vector.
    */
    public func map<U>(transform: (T) -> U) -> [U] {
        return mapT(self, transform)
    }
    
    /**
    Returns a new Vector containing the results of mapping `transform` over its elements. The resulting elements are guaranteed to be the same type as the items of the provided one.
    */
    public func mapConserve(transform: (T) -> T) -> Vector {
        return mapConserveT(self, transform)
    }
    
    /**
    Returns a string representation of all the elements within the Vector, without any separation between them.
    */
    public func mkString() -> String {
        return mkStringT(self)
    }
    
    /**
    Returns a string representation of all the elements within the Vector, separated by the provided separator.
    */
    public func mkString(separator: String) -> String {
        return mkStringT(self, separator)
    }
    
    /**
    Returns a string representation of all the elements within the Vector, separated by the provided separator and enclosed by the `start` and `end` strings.
    */
    public func mkString(start: String, separator: String, end: String) -> String {
        return mkStringT(self, start, separator, end)
    }
    
    /**
    Returns true if this Vector contains elements.
    */
    public func nonEmpty() -> Bool {
        return nonEmptyT(self)
    }
    
    /**
    :returns: Returns a tuple containing the results of splitting the Vector according to a predicate `p`. The first array in the tuple contains those elements which satisfy the predicate, while the second contains those which don't. Equivalent to (filter, filterNot).
    */
    public func partition(p: (T) -> Bool) -> (Vector, Vector) {
        return partitionT(self, p)
    }
    
    /**
    Returns the result of repeatedly calling combine with an accumulated value initialized to `initial` and each element of the current Vector.
    */
    public func reduce<U>(initialValue: U, combine: (U, T) -> U) -> U {
        return reduceT(self, initialValue, combine)
    }
    
    /**
    Returns a new Vector with elements in inverse order than the current one.
    */
    public func reverse() -> Vector {
        return reverseT(self)
    }
    
    /**
    Returns a new Vector made of the elements from the current one which satisfy the invariant:
    
    from <= indexOf(x) < until
    
    Note: If `endIndex` is out of range within the Vector, sliceT will throw an exception.
    */
    public func slice(from startIndex: Int, until endIndex: Int) -> Vector {
        return sliceT(self, from: startIndex, until: endIndex)
    }
    
    /**
    Returns a new Vector containing all the elements from the provided one, but sorted by a predicate `p`.
    
    :param: p Closure returning true if the first element should be ordered before the second.
    */
    public func sortWith(p: (T, T) -> Bool) -> Vector {
        return sortWithT(self, p)
    }
    
    /**
    :returns: Returns a tuple containing the results of splitting the Vector according to a predicate. The first traversable in the tuple contains the first elements that satisfy the predicate `p`, while the second contains all elements after those. Equivalent to (takeWhileT, dropWhileT).
    */
    public func span(p: (T) -> Bool) -> (Vector, Vector) {
        return spanT(self, p)
    }
    
    /**
    :returns: Returns a tuple containing the results of splitting the Vector at the given position (equivalent to: (take n, drop n)).
    */
    public func splitAt(n: Int) -> (Vector, Vector) {
        return splitAtT(self, n)
    }
    
    /**
    :returns: A new Vector containing the first `n` elements of the current one.
    */
    public func take(n: Int) -> Vector {
        return takeT(self, n)
    }
    
    /**
    :returns: A new Vector containing the last `n` elements of the current one.
    */
    public func takeRight(n: Int) -> Vector {
        return takeRightT(self, n)
    }
    
    /**
    Returns the longest prefix of elements that satisfy the predicate `p`.
    */
    public func takeWhile(p: (T) -> Bool) -> Vector {
        return takeWhileT(self, p)
    }
    
    /**
    Returns a list containing the elements of this Vector.
    */
    public func toList() -> ListT<T> {
        return toListT(self)
    }
    
    /**
    Returns a new Vector containing all the elements from the two provided Vector.
    */
    public func union(a: Vector, b: Vector) -> Vector {
        return unionT(a, b)
    }
}