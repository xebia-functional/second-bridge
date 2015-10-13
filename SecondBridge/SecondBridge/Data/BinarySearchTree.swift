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

internal enum PartsTree {
    case Left
    case Right
}

indirect enum BinarySearchTree<T:Comparable>: CustomStringConvertible {
    
    case Empty
    case Node(T, left: BinarySearchTree, right: BinarySearchTree)
    
    func getHead() -> T? {
        switch self{
        case .Empty:
            return .None
        case let .Node(T, left: _, right: _):
            return T
        }
    }
    
    
    func get(part: PartsTree) -> BinarySearchTree {
        
        switch self {
        case .Empty:
            return .Empty
        case let .Node(_, left: _, right: rigth) where part == .Right:
            return rigth
        case let .Node(_, left: left, right: _) where part == .Left:
            return left
        default:
            return self
        }
    }
    
    func add(element:T) -> BinarySearchTree {
        switch self {
        case .Empty:
            return BinarySearchTree.Node(element, left: BinarySearchTree.Empty, right: BinarySearchTree.Empty)
        case let .Node(value, left, right):
            if element > value {
                return BinarySearchTree.Node(value, left: left, right: right.add(element))
            } else {
                return BinarySearchTree.Node(value, left: left.add(element), right: right)
            }
        }
    }
    
    func search(element:T) -> Bool{
        
        switch self{
        case .Empty:
            return false
        case let .Node(value, _, _) where element == value:
            return true
        case let .Node(value, left, _) where value > element:
            return left.search(element)
        case let .Node(value, _, right) where value < element:
            return right.search(element)
        default:
            print("Error")
        }
        return false
    }
    
    
    func remove(element:T) -> BinarySearchTree? {
        
        switch self {
        case .Empty:
            return self
        case let .Node(value, left, right) where value > element:
            return BinarySearchTree.Node(value, left: left.remove(element)!, right: right)
        case let .Node(value, left, right) where value < element:
            return BinarySearchTree.Node(value, left:left, right: right.remove(element)!)
        case let .Node(value, .Empty, .Empty) where value == element:
            return BinarySearchTree.Empty
        case let .Node(value, left, .Empty) where value == element:
            return left
        case let .Node(value, .Empty, right) where value == element:
            return right
        case let .Node(value, left, right) where value == element:
            let a = findMin(right)
            switch a {
            case let .Node(value, _,_):
                return BinarySearchTree.Node(value, left: left, right: right.remove(value)!)
            default:
                return .Empty
            }
        default:
            print("Error")
            
        }
        return self
        
    }
    
    func findMin( root:BinarySearchTree) -> BinarySearchTree<T> {
        
        switch root{
        case .Node(_, .Empty, _):
            return root
        case let .Node(_, left,_):
            return findMin(left)
        default:
            return .Empty
        }
    }
    
    var description: String {
        switch self {
        case .Empty:
            return "."
        case let .Node(value, left, right):
            return "[\(left) \(value) \(right)]"
        }
    }
    
}

// Traversal

extension BinarySearchTree  {
    
    func inOrderTraversal() -> [T] {
        
        var result:[T] = []
        if (!self.get(.Left).isEmpty()){
           result += self.get(.Left).inOrderTraversal()
        }
        result.append(self.getHead()!)
        if (!self.get(.Right).isEmpty()){
            result += self.get(.Right).inOrderTraversal()
        }
        return result
    }
    
    
}


extension BinarySearchTree {
    
    func count() -> Int{
        if((self.getHead()) != nil){
            return 1 + self.get(.Left).count() + self.get(.Right).count()
        }else{
            return 0
        }
    }
    
    func isEmpty() -> Bool{
        switch self {
        case .Empty:
            return true
        default:
            return false
        }
    }
    
    
}

//// MARK: - Operators

func ==<T: Equatable>(lhs: BinarySearchTree<T>, rhs: BinarySearchTree<T>) -> Bool {
    if( lhs.isEmpty() && rhs.isEmpty()){
        return true
    }
    if( (lhs.isEmpty() && !rhs.isEmpty()) || ( !lhs.isEmpty() && rhs.isEmpty())){
        return false
    }
    
    if (lhs.getHead() == rhs.getHead() && (lhs.get(.Left) == rhs.get(.Left)) && (lhs.get(.Right) == rhs.get(.Right))){
        return true
    }else{
        return false
    }
}







