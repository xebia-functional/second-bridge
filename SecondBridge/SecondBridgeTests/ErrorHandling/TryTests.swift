//
//  TryTests.swift
//  SecondBridge
//
//  Created by Javier de Silóniz Sandino on 7/10/15.
//  Copyright © 2015 47 Degrees. All rights reserved.
//

import XCTest

class TryTests: XCTestCase {

    enum ParseError : ErrorType {
        case InvalidString
    }
    
    enum OperationError: ErrorType {
        case DivideByZero
    }
    
    func convertStringToInt(s: String) throws -> Int {
        if let parsedInt = Int(s) {
            return parsedInt
        } else {
            throw ParseError.InvalidString
        }
    }
    
    func halfOf(n: Int) -> Try<Int> {
        return Try<Int>(op: (n / 2))
    }
    
    func divideInt(n: Int, by: Int) throws -> Int {
        switch by {
        case 0: throw OperationError.DivideByZero
        default: return n / by
        }
    }
    
    func tryDivideByZeroWhoops(n: Int) -> Try<Int> {
        return Try<Int>(op: (try divideInt(n, by: 0)))
    }
    
    func tryHalf(n: Int) -> Try<Int> {
        return Try<Int>(op: (try divideInt(n, by: 2)))
    }

    func testTryBasicBehaviour() {
        let tryParseCorrectString = Try<Int>(op: try self.convertStringToInt("47"))
        XCTAssertTrue(tryParseCorrectString.isSuccess(), "Correct operation inside a Try should be a success")
        XCTAssertFalse(tryParseCorrectString.isFailure(), "Correct operation inside a Try shouldn't be a failure")
        let value = tryParseCorrectString.get()
        XCTAssertNotNil(value, "Correct operation inside a Try should yield a value")
        XCTAssertEqual(value, 47, "Correct operation inside a Try should yield the expected value")
        
        let tryParseIncorrectString = Try<Int>(op: try self.convertStringToInt("47 Degrees"))
        XCTAssertFalse(tryParseIncorrectString.isSuccess(), "Invalid operation inside a Try shouldn't be a success")
        XCTAssertTrue(tryParseIncorrectString.isFailure(), "Invalid operation inside a Try should be a failure")
        let invalidValue = tryParseIncorrectString.getOrElse(666)
        XCTAssertEqual(invalidValue, 666, "Invalid operation inside a Try shouldn't yield a value")
    }
    
    func testTryHigherOrderFunctions() {
        let tryParseCorrectString = Try<Int>(op: try self.convertStringToInt("47"))
        let tryParseIncorrectString = Try<Int>(op: try self.convertStringToInt("47 Degrees"))
        
        let mapCorrectResult = tryParseCorrectString.map({ $0 + 10 }).getOrElse(666)
        XCTAssertEqual(mapCorrectResult, 57, "Mapping over a successful Try should yield a correct value")
        
        let mapIncorrectResult = tryParseIncorrectString.map({ $0 + 10 }).getOrElse(666)
        XCTAssertEqual(mapIncorrectResult, 666, "Mapping over a failed Try shouldn't yield a correct value")
        
        let filterCorrectResult = tryParseCorrectString.filter({ $0 != 47 })
        XCTAssert(filterCorrectResult.isFailure(), "A Success filtered with an invalid predicate should be changed to a Failure")
        
        let filterIncorrectResult = tryParseIncorrectString.filter({ $0 != 47 })
        XCTAssert(filterIncorrectResult.isFailure(), "A Failure filtered with any predicate should be returned as such")
        
        let flatmapCorrectResultAgainstWrongFunction = tryParseCorrectString.flatMap(tryDivideByZeroWhoops)
        XCTAssertTrue(flatmapCorrectResultAgainstWrongFunction.isFailure(), "When flatmapping a Success against a Failure, we should get a Failure")
        
        let flatmapCorrectResultAgainstOKFunction = tryParseCorrectString.flatMap(tryHalf)
        XCTAssertTrue(flatmapCorrectResultAgainstOKFunction.isSuccess(), "When flatmapping a Success against a Success, we should get a Success")
        XCTAssertEqual(flatmapCorrectResultAgainstOKFunction.getOrElse(1), 23, "When flatmapping a Success against a Success, we should get a Success of a valid value")
        
        let flatmapIncorrectResultAgainstOKFunction = tryParseIncorrectString.flatMap(tryHalf)
        XCTAssertTrue(flatmapIncorrectResultAgainstOKFunction.isFailure(), "When flatmapping a Failure against a Success, we should get a Failure")
        
        let flatmapIncorrectResultAgainstIncorrectFunction = tryParseIncorrectString.flatMap(tryDivideByZeroWhoops)
        XCTAssertTrue(flatmapIncorrectResultAgainstIncorrectFunction.isFailure(), "When flatmapping a Failure against a Failure, we should get a Failure")        
    }

}
