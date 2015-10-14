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

internal enum TreeBranch {
    case Left
    case Right
}

indirect enum BinarySearchTree<T:Comparable>: CustomStringConvertible {
    
    case Empty
    case Node(T, left: BinarySearchTree, right: BinarySearchTree)
    
    
    /*
    * Return the element the head the current BST
    */
    func head() -> T? {
        switch self{
        case .Empty:
            return .None
        case let .Node(T, left: _, right: _):
            return T
        }
    }
    
    /*
    * Return a new BST with the provided branch as specified in the provided enum (left or right)
    */
    func getBranch(branch: TreeBranch) -> BinarySearchTree {
        
        switch self {
        case let .Node(_, left: _, right: right) where branch == .Right:
            return right
        case let .Node(_, left: left, right: _) where branch == .Left:
            return left
        default:
            return .Empty
        }
    }
    
    /**
    * Returns a new BinarySearchTree with the provided item added to the current contents.
    */
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
    
    /**
    Checks if a certain element is included in the current BinarySearchTree .
    
    - parameter element: The element to be checked.
    
    - returns: True if the BinarySearchTree  contains this element.
    
    */
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
            break
        }
        return false
    }
    
    /**
    *  Removes the provided element from the current BinarySearchTree , and returns a new BinarySearchTree  without that element
    */
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
            break
            
        }
        return self
        
    }
    
    private func findMin( root:BinarySearchTree) -> BinarySearchTree<T> {
        
        switch root{
        case .Node(_, .Empty, _):
            return root
        case let .Node(_, left,_):
            return findMin(left)
        default:
            return .Empty
        }
    }
    
    // MARK: - Printable
    
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
    
    /*
    * Returns a sorted array of node items.
    */
    func inOrderTraversal() -> [T] {
        
        var result:[T] = []
        if (!self.getBranch(.Left).isEmpty()){
            result += self.getBranch(.Left).inOrderTraversal()
        }
        result.append(self.head()!)
        if (!self.getBranch(.Right).isEmpty()){
            result += self.getBranch(.Right).inOrderTraversal()
        }
        return result
    }
    
    
}


extension BinarySearchTree {
    
    /**
    * Returns the number of nodes contained in the provided BinarySearchTree.
    */
    func count() -> Int{
        if((self.head()) != nil){
            return 1 + self.getBranch(.Left).count() + self.getBranch(.Right).count()
        }else{
            return 0
        }
    }
    
    /**
    *Returns true if this BinarySearchTree doesn't contain any node.
    */
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

// MARK: - Equality

func ==<T: Equatable>(lhs: BinarySearchTree<T>, rhs: BinarySearchTree<T>) -> Bool {
    if( lhs.isEmpty() && rhs.isEmpty()){
        return true
    }
    if( (lhs.isEmpty() && !rhs.isEmpty()) || ( !lhs.isEmpty() && rhs.isEmpty())){
        return false
    }
    
    if (lhs.head() == rhs.head() && (lhs.getBranch(.Left) == rhs.getBranch(.Left)) && (lhs.getBranch(.Right) == rhs.getBranch(.Right))){
        return true
    }else{
        return false
    }
}








