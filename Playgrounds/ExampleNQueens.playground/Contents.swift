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


/*:
# N-Queens Example

This Playground offers an example on how you can use functional programming to solve problems.
The N-Queens problem was first published in the 19th century by Max Bezzel and Franz Nauck. It’s
a classic example on the use of **backtracking algorithms**, and can be solved with pure functions
in a really short amount of code.

The problem we're solving with this algorithm is as follows: imagine we had a chess board of size NxN.
We need to place N queens in the board, without any of them killing any of the others. It's not as easy
a it seems: in a regular 8x8 board, there are only **92** solutions for **4,426,165,368** possible placements.

The algorithm itself is implemented in the following functions: **placeQueens**, **isAttacking**, **isSafe**.
*/

import UIKit
import SecondBridge
import XCPlayground

// MARK: N-Queens resolution algorithm

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
            let contains = filterT(rhs, { (item: Pos) -> Bool in
                item == lPos
            })
            result = contains.size() > 0
        }
        return ()
    })
    return result
}

/*:
This algorithm for the N-Queens problem resolution is based on **Martin Odersky**'s solution
("Programming in Scala", Chapter 23 - For Expressions Revisited). Its **for-comprehension**
has just been translated to a **flatmap/filter/map chain**.
Beware that Swift doesn't warrant recursion optimization, so its performance can be
problematic with high values of n (> 10).
*/

func isAttacking(posA: Pos, posB: Pos) -> Bool {
    return posA.x == posB.x || posA.y == posB.y || abs(posA.x - posB.x) == abs(posA.y - posB.y)
}

func isSafe(queen: Pos, queens: Stack<Pos>) -> Bool {
    return forAllT(queens, { (currentQueen) -> Bool in
        !isAttacking(queen, currentQueen)
    })
}

func placeQueens(k: Int, n: Int) -> Solutions {
    switch k {
    case 0: return Stack<Stack<Pos>>().push(Stack<Pos>())
    default:
        return Stack(flatMapT(placeQueens(k - 1, n), { (queens: Solution) -> [Solution] in
            return mapT(filterT(ArrayT([Int](1...n)), { (column: Int) -> Bool in
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

// MARK: - Chessboard view to show solutions

@objc class ChessBoardView : UIView {
    var size = CGFloat(0)
    var boardPieces = 0
    var queenLabels = Vector<UILabel>()
    
    let blackColor = UIColor.brownColor()
    let whiteColor = UIColor.yellowColor()
    
    init() {
        super.init(frame: CGRectZero)
    }
    
    convenience init(size: CGFloat, boardPieces: Int) {
        self.init()
        self.frame = CGRectMake(0, 0, size, size)
        self.size = size
        self.boardPieces = boardPieces
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var squareSize : CGFloat {
        get {
            return self.size / CGFloat(self.boardPieces)
        }
    }
    
    override func drawRect(rect: CGRect) {
        let cols = Vector<Int>([Int](0..<self.boardPieces))
        let rows = Vector<Int>([Int](0..<self.boardPieces))
        
        cols.foreach({ (currentRow: Int) -> () in
            rows.foreach({ (currentCol: Int) -> () in
                let square = UIBezierPath(rect: CGRectMake(CGFloat(currentCol) * self.squareSize, CGFloat(currentRow) * self.squareSize, self.squareSize, self.squareSize))
                
                var isBlackColor = currentCol % 2 != 0
                isBlackColor = (currentRow % 2 == 0) ? isBlackColor : !isBlackColor
                let fillColor = isBlackColor ? self.blackColor : self.whiteColor
                fillColor.setFill()
                
                square.fill()
            })
        })
    }
}

extension ChessBoardView {
    func showSolution(solution: Solution) {
        queenLabels.foreach({(label : UILabel) -> () in label.removeFromSuperview()})
        
        queenLabels = Vector<UILabel>()
        solution.foreach({ (pos: Pos) -> () in
            let label = UILabel(frame: CGRectMake(CGFloat(pos.x - 1) * self.squareSize, CGFloat(pos.y - 1) * self.squareSize, self.squareSize, self.squareSize))
            label.textColor = UIColor.blackColor()
            label.textAlignment = NSTextAlignment.Center
            label.font = UIFont.systemFontOfSize(35)
            label.text = "♛"
            
            self.addSubview(label)
            self.queenLabels = self.queenLabels.append(label)})
    }
}

// MARK: - Resolution view
/*:
N-Queens resolution is a really cool visual image of what you can achieve doing functional code with just a few lines of codes.
But its algorithm use intensive recursive calculation, and as such it won't work that well under a Playground if using values of `numberOfPieces` = 4 - 6.
Please keep that in mind while playing with it :).
*/

let numberOfPieces = 4
let solutions = nQueensSolutions(numberOfPieces).toArray()
let chessBoard = ChessBoardView(size: 300, boardPieces: numberOfPieces)

for solution in solutions {
    chessBoard.showSolution(solution)
}
