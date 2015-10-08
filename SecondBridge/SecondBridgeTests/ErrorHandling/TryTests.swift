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

import XCTest

class TryTests: XCTestCase {

    // MARK: - Error types for our tests
    enum ParseError : ErrorType {
        case InvalidString
    }
    
    enum OperationError: ErrorType {
        case DivideByZero
    }
    
    // MARK: - Example simple functions for our tests
    func convertStringToInt(s: String) throws -> Int {
        if let parsedInt = Int(s) {
            return parsedInt
        } else {
            throw ParseError.InvalidString
        }
    }
    
    func halfOf(n: Int) -> Try<Int> {
        return Try<Int>((n / 2))
    }
    
    func divideInt(n: Int, by: Int) throws -> Int {
        switch by {
        case 0: throw OperationError.DivideByZero
        default: return n / by
        }
    }
    
    func tryDivideByZeroWhoops(n: Int) -> Try<Int> {
        return Try<Int>((try divideInt(n, by: 0)))
    }
    
    func tryHalf(n: Int) -> Try<Int> {
        return Try<Int>((try divideInt(n, by: 2)))
    }

    // MARK: - Try basic features tests
    func testTryBasicBehaviour() {
        let tryParseCorrectString = Try<Int>(try self.convertStringToInt("47"))
        XCTAssertTrue(tryParseCorrectString.isSuccess(), "Correct operation inside a Try should be a success")
        XCTAssertFalse(tryParseCorrectString.isFailure(), "Correct operation inside a Try shouldn't be a failure")
        let value = tryParseCorrectString.getOrElse(0)
        XCTAssertNotNil(value, "Correct operation inside a Try should yield a value")
        XCTAssertEqual(value, 47, "Correct operation inside a Try should yield the expected value")
        
        let tryParseIncorrectString = Try<Int>(try self.convertStringToInt("47 Degrees"))
        XCTAssertFalse(tryParseIncorrectString.isSuccess(), "Invalid operation inside a Try shouldn't be a success")
        XCTAssertTrue(tryParseIncorrectString.isFailure(), "Invalid operation inside a Try should be a failure")
        let invalidValue = tryParseIncorrectString.getOrElse(666)
        XCTAssertEqual(invalidValue, 666, "Invalid operation inside a Try shouldn't yield a value")
    }
    
    // MARK: - Try Higher-Order Functions tests
    func testTryHigherOrderFunctions() {
        let tryParseCorrectString = Try<Int>(try self.convertStringToInt("47"))
        let tryParseIncorrectString = Try<Int>(try self.convertStringToInt("47 Degrees"))
        
        // MARK: Map
        let f = { (n: Int) -> Int in n + 10 }
        let mapCorrectResult = tryParseCorrectString.map(f).getOrElse(666)
        print(mapCorrectResult)
        XCTAssertEqual(mapCorrectResult, 57, "Mapping over a successful Try should yield a correct value")

        let mapIncorrectResult = tryParseIncorrectString.map({ $0 + 10 }).getOrElse(666)
        XCTAssertEqual(mapIncorrectResult, 666, "Mapping over a failed Try shouldn't yield a correct value")
        
        // MARK: Filter
        let filterCorrectResult = tryParseCorrectString.filter({ $0 != 47 })
        XCTAssert(filterCorrectResult.isFailure(), "A Success filtered with an invalid predicate should be changed to a Failure")
        
        let filterIncorrectResult = tryParseIncorrectString.filter({ $0 != 47 })
        XCTAssert(filterIncorrectResult.isFailure(), "A Failure filtered with any predicate should be returned as such")
        
        // MARK: FlatMap
        let flatmapCorrectResultAgainstWrongFunction = tryParseCorrectString.flatMap(tryDivideByZeroWhoops)
        XCTAssertTrue(flatmapCorrectResultAgainstWrongFunction.isFailure(), "When flatmapping a Success against a Failure, we should get a Failure")
        
        let flatmapCorrectResultAgainstOKFunction = tryParseCorrectString.flatMap(tryHalf)
        XCTAssertTrue(flatmapCorrectResultAgainstOKFunction.isSuccess(), "When flatmapping a Success against a Success, we should get a Success")
        XCTAssertEqual(flatmapCorrectResultAgainstOKFunction.getOrElse(1), 23, "When flatmapping a Success against a Success, we should get a Success of a valid value")
        
        let flatmapIncorrectResultAgainstOKFunction = tryParseIncorrectString.flatMap(tryHalf)
        XCTAssertTrue(flatmapIncorrectResultAgainstOKFunction.isFailure(), "When flatmapping a Failure against a Success, we should get a Failure")
        
        let flatmapIncorrectResultAgainstIncorrectFunction = tryParseIncorrectString.flatMap(tryDivideByZeroWhoops)
        XCTAssertTrue(flatmapIncorrectResultAgainstIncorrectFunction.isFailure(), "When flatmapping a Failure against a Failure, we should get a Failure")
        
        // MARK: Recover / RecoverWith
        let recoverResult = tryParseIncorrectString.recover({
            (e: ErrorType) -> Bool in
                return true
            } |-> {(e: ErrorType) -> (Int) in return 0})
        let recoverResultGet = recoverResult.getOrElse(1)
        XCTAssertTrue(recoverResult.isSuccess(), "When recovering from a Failure with a valid value, we should get a Try that automatically succeeds")
        XCTAssertEqual(recoverResultGet, 0, "When recovering from a Failure with a valid value, we should get a Try that automatically succeeds")
        
        let recoverWithWrongResult = tryParseIncorrectString.recoverWith({
            (e: ErrorType) -> Bool in
            return true
            } |-> {(e: ErrorType) -> (Try<Int>) in
                return tryParseIncorrectString
            })
        let recoverWithWrongResultGet = recoverWithWrongResult.getOrElse(1)
        XCTAssertTrue(recoverWithWrongResult.isFailure(), "When recovering from a Failure with an invalid value, we should get a Failure")
        XCTAssertEqual(recoverWithWrongResultGet, 1, "When recovering from a Failure with an invalid value, we should get a Failure")
    
        let recoverFromSuccessResult = tryParseCorrectString.recover({
            (e: ErrorType) -> Bool in
            return true
            } |-> {(e: ErrorType) -> (Int) in return 0})
        let recoverFromSuccessResultGet = recoverFromSuccessResult.getOrElse(666)
        XCTAssertTrue(recoverFromSuccessResult.isSuccess(), "When recovering from a Success, we should get the original result")
        XCTAssertEqual(recoverFromSuccessResultGet, 47, "When recovering from a Success, we should get the original result")
    }

}
