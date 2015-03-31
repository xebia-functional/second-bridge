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

import Foundation

// MARK: - Stack declaration and protocol implementations

/// Stack | An immutable iterable LIFO containing elements of type T.
public struct StackT<T> {
    private var internalArray : Array<T>
}

extension StackT : ArrayLiteralConvertible {
    public init(arrayLiteral elements: T...) {
        internalArray = elements
    }
    
    public init(_ elements: Array<T>) {
        internalArray = elements
    }
}

extension StackT : SequenceType {
    public typealias Generator = GeneratorOf<T>
    
    public func generate() -> Generator {
        var index : Int = 0
        
        return Generator {
            if index < self.internalArray.count {
                return self.internalArray[index]
            }
            return nil
        }
    }
}

// MARK: - Basic operations

extension StackT {
    /**
    Returns a new stack with the current contents and the provided item on top.
    */
    public func push(item: T) -> StackT<T> {
        var result = internalArray
        result.append(item)
        return StackT<T>(result)
    }
    
    /**
    Returns a tuple containing the top item in the current stack, and a new stack with that item popped out.
    */
    public func pop() -> (item: T?, stack: StackT<T>) {
        if internalArray.count > 0 {
            return (self.top()!, travTake(self, self.size() - 1))
        }
        return (nil, self)
    }
    
    /**
    Returns the item on top the stack without popping it out, or nil if the stack is empty.
    */
    public func top() -> T? {
        return internalArray.last
    }
    
    /**
    Returns the number of items contained in the stack.
    */
    public func size() -> Int {
        return internalArray.count
    }
}

extension StackT : Traversable {
    typealias ItemType = T
    public func foreach(f: (T) -> ()) {
        for item in self.internalArray {
            f(item)
        }
    }
    
    /**
    Build a new StackT instance with the elements contained in the `elements` array.
    */
    public static func build(elements: [ItemType]) -> StackT<T> {
        return StackT<T>(elements)
    }
    
    /**
    Build a new StackT instance with the elements contained in the provided Traversable instance. The provided traversable is expected to contain
    items with the same type as the StackT struct. Items of different types will be discarded.
    */
    public static func buildFromTraversable<U where U : Traversable>(traversable: U) -> StackT {
        return travReduce(traversable, StackT()) { (result, item) -> StackT in
            switch item {
            case let sameTypeItem as T: result.push(sameTypeItem)
            default: break
            }
            return result
        }
    }
}

extension StackT: Printable, DebugPrintable {
    public var description : String {
        get {
            if self.size() > 0 {
                return "bottom ->" + travReduce(self, "") { (text, item) -> String in
                    var nextText = text
                    nextText += "[\(item)]"
                    return nextText
                } + "<- top"
            }
            return "Empty stack"
        }
    }
    
    public var debugDescription : String {
        return self.description
    }
}