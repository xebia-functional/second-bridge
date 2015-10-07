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
    
    func convertStringToInt(s: String) throws -> Int {
        if let parsedInt = Int(s) {
            return parsedInt
        } else {
            throw ParseError.InvalidString
        }
    }

    func testTryBasicBehaviour() {
        let tryParseCorrectString = Try<Int>(op: {() throws -> Int in try self.convertStringToInt("47")})
        XCTAssertTrue(tryParseCorrectString.isSuccess(), "Correct operation inside a Try should be a success")
        XCTAssertFalse(tryParseCorrectString.isFailure(), "Correct operation inside a Try shouldn't be a failure")
        let value = tryParseCorrectString.getOrElse()
        XCTAssertNotNil(value, "Correct operation inside a Try should yield a value")
        XCTAssertEqual(value, 47, "Correct operation inside a Try should yield the expected value")
        
        let tryParseIncorrectString = Try<Int>(op: {() throws -> Int in try self.convertStringToInt("47 Degrees")})
        XCTAssertFalse(tryParseIncorrectString.isSuccess(), "Invalid operation inside a Try shouldn't be a success")
        XCTAssertTrue(tryParseIncorrectString.isFailure(), "Invalid operation inside a Try should be a failure")
        let invalidValue = tryParseIncorrectString.getOrElse()
        XCTAssertNil(invalidValue, "Invalid operation inside a Try shouldn't yield a value")
    }

}
