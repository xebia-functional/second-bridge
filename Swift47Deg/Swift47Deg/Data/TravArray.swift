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

/// TravArray | An immutable and traversable Array containing elements of type T.
public struct TravArray<T> {
    private var internalArray : Array<T>
    
    public subscript(index: Int) -> T? {
        get {
            return (index < internalArray.count) ? internalArray[index] : nil
        }
    }
}

extension TravArray : ArrayLiteralConvertible {
    public init(arrayLiteral elements: T...) {
        internalArray = elements
    }
    
    public init(_ elements: Array<T>) {
        internalArray = elements
    }
}

extension TravArray : SequenceType {
    public typealias Generator = GeneratorOf<T>
    
    public func generate() -> Generator {
        var index : Int = 0
        
        return Generator {
            if index < self.internalArray.count {
                let result = self.internalArray[index]
                index++
                return result
            }
            return nil
        }
    }
}

extension TravArray {
    /**
    Returns a new TravArray with the current contents and the provided item on top.
    */
    public func append(item: T) -> TravArray<T> {
        var result = internalArray
        result.append(item)
        return TravArray<T>(result)
    }
    
    /**
    Returns the last item of the TravArray, if any.
    */
    public func last() -> T? {
        return internalArray.last
    }
    
    /**
    Returns the number of items contained in the TravArray.
    */
    public func size() -> Int {
        return internalArray.count
    }
}

extension TravArray : Traversable {
    typealias ItemType = T
    public func foreach(f: (T) -> ()) {
        for item in self.internalArray {
            f(item)
        }
    }
    
    /**
    Build a new TravArray instance with the elements contained in the `elements` array.
    */
    public static func build(elements: [ItemType]) -> TravArray<T> {
        return TravArray<T>(elements)
    }
    
    /**
    Build a new TravArray instance with the elements contained in the provided Traversable instance. The provided traversable is expected to contain
    items with the same type as the Stack struct. Items of different types will be discarded.
    */
    public static func buildFromTraversable<U where U : Traversable>(traversable: U) -> TravArray {
        return reduceT(traversable, TravArray()) { (result, item) -> TravArray in
            switch item {
            case let sameTypeItem as T: result.append(sameTypeItem)
            default: break
            }
            return result
        }
    }
}

extension TravArray : Iterable {
    
}

extension TravArray {
    func toArray() -> Array<T> {
        var internalArray = self.internalArray
        return internalArray
    }
}