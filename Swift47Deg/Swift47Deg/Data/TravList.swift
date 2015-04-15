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
import Swiftz

/// TravList | An immutable and traversable List containing elements of type T.
public struct TravList<T> {
    
    private var internalList : List<T>
    
    public subscript(index: UInt) -> T? {
        return internalList[index]
    }
}

extension TravList : Equatable {}

public func ==<T>(lhs: TravList<T> , rhs: TravList<T> ) -> Bool {
    return true
}


extension TravList {
    
    public func tail() -> TravList {
       return travTail(self)
    }
        
    //Funcion reduce with only a parameter,  parameter initial is not necessary
    public func reduce<B>(f : (B, T) -> B) -> B? {
        
        if let head = internalList.head() as? B{
            if let tail = internalList.tail() as Swiftz.List<T>?{
                switch tail.match() {
                case .Nil:
                    return head
                case let .Cons(x, xs):
                    return xs.reduce(f, initial: f(head,x))
                }
            }
            return head
        }
        return nil
    }
    
    //Funcion reduce right with only a parameter,  parameter initial is not necessary
   public func reduceRight<B>(f : (B, T) -> B) -> B? {
        
        let a = internalList.reverse()
        if let head = a.head() as? B{
            if let tail = a.tail() as Swiftz.List<T>?{
                switch tail.match() {
                case .Nil:
                    return head
                case let .Cons(x, xs):
                    return xs.reduce(f, initial: f(head,x))
                }
            }
            return head
        }
        return nil
    }

    //Applies a binary operator to reduce the elements of the receiver to a single value.
    public func reduceRight<B>(f : (B, T) -> B, initial : B) -> B {
        let a = internalList.reverse()
        switch a.match() {
        case .Nil:
            return initial
        case let .Cons(x, xs):
            return xs.reduce(f, initial: f(initial,x))
        }
    }

    //Applies a binary operator to a start value and all elements of this sequence, going right to left
    public func fold<B>(f : (B, T) -> B, initial : B) -> B {
        switch internalList.match() {
        case .Nil:
            return initial
        case let .Cons(x, xs):
            return xs.reduce(f, initial: f(initial,x))
        }
    }
    
    //Applies a binary operator to a start value and all elements of this sequence, going left to right
    public func foldRight<B>(f : (B, T) -> B, initial : B) -> B {
        let a = internalList.reverse()
        switch a.match() {
        case .Nil:
            return initial
        case let .Cons(x, xs):
            return xs.reduce(f, initial: f(initial,x))
        }
    }
    
    /**
    Returns a new TravArray with the current contents and the provided item on top.
    */
    public func append(item: T) -> TravList<T> {
        var result = internalList
        result.append([item])
        return TravList<T>(result)
    }
    
    public func arrayToList( elements: Array<T>) -> TravList<T> {
        var result = internalList
        for element in elements {
            let l : List = [element]
            result = result + l
        }
        return TravList<T>(result)
    }
    
}




extension TravList : ArrayLiteralConvertible {
    
    public init(arrayLiteral elements: T...) {
        var listTemp = List<T>()
        for element in elements {
            let l : List = [element]
            listTemp = listTemp + l
        }
        internalList = listTemp
    }
    
    public init(_ elements: List<T>) {
        internalList = elements
    }
    
}


extension TravList : Traversable {
    
    typealias ItemType = T
    
    public func foreach(f: (T) -> ()) {
        for item in self.internalList {
            f(item)
        }
    }
    
    /**
    Build a new TravList instance with the elements contained in the `elements` array.
    */
    public static func build(elements: [ItemType]) -> TravList<T> {
        var result =  TravList()
        return result.arrayToList(elements)
    }
    
    /**
    Build a new TravList instance with the elements contained in the provided Traversable instance. The provided traversable is expected to contain
    items with the same type as the Stack struct. Items of different types will be discarded.
    */
    public static func buildFromTraversable<U where U : Traversable>(traversable: U) -> TravList {
        return travReduce(traversable, TravList()) { (result, item) -> TravList in
            switch item {
            case let sameTypeItem as T: result.append(sameTypeItem)
            default: break
            }
            return result
        }
        
    }
}


