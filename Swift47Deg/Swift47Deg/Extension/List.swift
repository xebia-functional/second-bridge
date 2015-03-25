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
import UIKit
import Swiftz


extension List {
    
     init(_ elements: A...)  {
        var listTemp = List()
        for element in elements {
            let l : List = [element]
            listTemp = listTemp + l
        }
       self = listTemp
    }
    
    //Funcion reduce with only a parameter,  parameter initial is not necessary
    func reduce<B>(f : (B, A) -> B) -> B? {
        
        if let head = self.head() as? B{
            if let tail = self.tail() as Swiftz.List<A>?{
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
    func reduceRight<B>(f : (B, A) -> B) -> B? {
        
        let a = self.reverse()
        if let head = a.head() as? B{
            if let tail = a.tail() as Swiftz.List<A>?{
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
    func reduceRight<B>(f : (B, A) -> B, initial : B) -> B {
        let a = self.reverse()
        switch a.match() {
        case .Nil:
            return initial
        case let .Cons(x, xs):
            return xs.reduce(f, initial: f(initial,x))
        }
    }

    //Applies a binary operator to a start value and all elements of this sequence, going right to left
    func fold<B>(f : (B, A) -> B, initial : B) -> B {
        switch self.match() {
        case .Nil:
            return initial
        case let .Cons(x, xs):
            return xs.reduce(f, initial: f(initial,x))
        }
    }
    
    //Applies a binary operator to a start value and all elements of this sequence, going left to right
    func foldRight<B>(f : (B, A) -> B, initial : B) -> B {
        let a = self.reverse()
        switch a.match() {
        case .Nil:
            return initial
        case let .Cons(x, xs):
            return xs.reduce(f, initial: f(initial,x))
        }
    }
    

}

