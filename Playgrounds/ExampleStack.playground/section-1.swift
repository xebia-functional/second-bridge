import UIKit
import Swift47Deg

var stack = Stack<Int>()
// You can use the push operation to add new elements to a stack. The one at the top is always the last to be added:
stack = stack.push(1)
stack.description
stack = stack.push(2)
stack.description
stack = stack.push(3)
stack.description

stack.top()

// Then you can use the pop operation to take new elements from the stack, also getting a new stack with that element removed.
stack = stack.pop().stack
stack.description

stack = stack.pop().stack
stack.description

stack = stack.pop().stack
stack.description


// Stacks are Traversable and Iterable, that means that you can create them easily using Swift arrays
stack = Stack<Int>([1, 2, 3, 4, 5])
stack.description

// And also you have access to the broad array of functions available:
let mappedStack = stack.mapConserve({$0 * 2})
mappedStack.description

let reduceStack = stack.reduce(0, combine: { $0 + $1 })
reduceStack
