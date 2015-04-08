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
import XCTest

// MARK: N-Queens problem algorithm

typealias Pos = (x: Int, y: Int)
typealias Solution = Stack<Pos>
typealias Solutions = Stack<Solution>

func ==(lhs: Pos, rhs: Pos) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}
func !=(lhs: Pos, rhs: Pos) -> Bool {
    return !(lhs == rhs)
}

func ==(lhs: Solution, rhs: Solution) -> Bool {
    var result = true
    lhs.foreach({ (lPos : Pos) in
        if result {
            let contains = travFilter(rhs, { (item: Pos) -> Bool in
                item == lPos
            })
            result = contains.size() > 0
        }
        return ()
    })
    return result
}

func isAttacking(posA: Pos, posB: Pos) -> Bool {
    return posA.x == posB.x || posA.y == posB.y || abs(posA.x - posB.x) == abs(posA.y - posB.y)
}

func isSafe(queen: Pos, queens: Stack<Pos>) -> Bool {
    return travForAll(queens, { (currentQueen) -> Bool in
        !isAttacking(queen, currentQueen)
    })
}

func placeQueens(k: Int, n: Int) -> Solutions {
    // This algorithm for the N-Queens problem resolution is based on Martin Odersky's solution
    // ("Programming in Scala", Chapter 23 - For Expressions Revisited). Its for comprehension
    // is just translated to a flatmap/filter/map chain.
    // Beware that Swift doesn't warrant recursion optimization, so its performance can be
    // problematic with high values of n (> 10).
    
    switch k {
    case 0: return Stack<Stack<Pos>>().push(Stack<Pos>())
    default:
        return Stack(travFlatMap(placeQueens(k - 1, n), { (queens: Solution) -> [Solution] in
            return travMap(travFilter(TravArray([Int](1...n)), { (column: Int) -> Bool in
                isSafe((k, column), queens)
            }), { (column: Int) -> Solution in
                return queens.push((k, column))
            })
        }))
    }
}

func nQueensSolutions(n: Int) -> Stack<Stack<Pos>> {
    return placeQueens(n, n)
}

// MARK: - Tests

class NQueensExample: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testPerformance() {
        self.measureBlock() {
            let solution8 = nQueensSolutions(8)
            XCTAssertTrue(solution8.size() == 92, "Only valid solutions should be allowed")
        }
    }
    
    func testIsAttacking() {
        XCTAssertTrue(isAttacking((1, 1), (0, 0)), "This should be considered an attack")
        XCTAssertTrue(isAttacking((1, 1), (0, 2)), "This should be considered an attack")
        XCTAssertTrue(isAttacking((1, 1), (1, 0)), "This should be considered an attack")
        XCTAssertTrue(isAttacking((1, 1), (1, 2)), "This should be considered an attack")
        XCTAssertTrue(isAttacking((1, 1), (2, 0)), "This should be considered an attack")
        XCTAssertTrue(isAttacking((1, 1), (2, 1)), "This should be considered an attack")
        XCTAssertTrue(isAttacking((1, 1), (2, 2)), "This should be considered an attack")
        XCTAssertTrue(isAttacking((1, 1), (3, 3)), "This should be considered an attack")
        XCTAssertFalse(isAttacking((1, 1), (2, 3)), "This shouldn't be considered an attack")
    }
    
    func testSolution() {
        let solution4 = travToArray(nQueensSolutions(4))
        XCTAssertTrue(solution4.count == 2, "Only valid solutions should be allowed")
        
        let validSolution1 = Solution([(1, 2), (2, 4), (3, 1), (4, 3)])
        let validSolution2 = Solution([(1, 3), (2, 1), (3, 4), (4, 2)])
        let invalidSolution = Solution([(1, 1), (2, 1), (3, 1), (4, 1)])
        
        XCTAssertTrue(solution4[0] == validSolution1, "Only valid solutions should be allowed")
        XCTAssertTrue(solution4[1] == validSolution2, "Only valid solutions should be allowed")
        XCTAssertFalse(solution4[0] == invalidSolution, "Only valid solutions should be allowed")
        XCTAssertFalse(solution4[1] == invalidSolution, "Only valid solutions should be allowed")
    }
}
