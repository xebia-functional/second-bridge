import UIKit
import Swiftz
import Swift47Deg

// Double a number if it’s even
let doubleEvens = { $0 % 2 == 0 } |-> { $0 * 2 }

// Triple a number if it’s odd
let tripleOdds = { $0 % 2 != 0 } |-> { $0 * 3 }

// Just add five
let addFive = ∫(+5)

// Double a number if it’s even, or triple it if it’s odd
let opOrElseOp = doubleEvens |||> tripleOdds

// Double a number if it’s even, or triple it if it’s odd. Then, increment the result by 5.
let opOrElseAndThenOp = doubleEvens |||> tripleOdds >>> addFive

let resultEven = opOrElseOp.apply(3)
let resultOdd = opOrElseOp.apply(4)

let resultAndThenOdd = opOrElseAndThenOp.apply(3)
let resultAndThenEven = opOrElseAndThenOp.apply(4)


// We can also perform cool pattern matching, while getting a value as a result
let matchTest = match({(item: Int) -> Bool in item == 0 } |-> {(Int) -> String in return "Zero"},
    {(item: Int) -> Bool in item == 1 } |-> {(Int) -> String in return "One"},
    {(item: Int) -> Bool in item == 2 } |-> {(Int) -> String in return "Two"},
    {(item: Int) -> Bool in item > 2 } |-> {(Int) -> String in return "Moar!"})

matchTest.apply(0)
matchTest.apply(1)
matchTest.apply(2)
matchTest.apply(666)


// Also, we can apply a partial function to any Traversable collection, and receiving the result from all the values appliable:

let map : Map<Double> = ["a" : -1, "b" : 0, "c" : 1, "d" : 2, "e" : 3, "f" : 4]
let squareRoot = ∫({ $0.1 >= 0 }) |-> Function<(HashableAny, Double), (HashableAny, Double)>.arr({ ($0.0, sqrt(Double($0.1))) })
map.description
map.collect(squareRoot).description
