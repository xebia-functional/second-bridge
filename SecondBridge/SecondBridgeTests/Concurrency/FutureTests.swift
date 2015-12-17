//
//  FutureTests.swift
//  SecondBridge
//
//  Created by Javier de Silóniz Sandino on 13/10/15.
//  Copyright © 2015 47 Degrees. All rights reserved.
//

import XCTest

class FutureTests: XCTestCase {
    func delay(delay: Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func complexOpDoneInTime(time: Double) -> Int {
        var shouldReturn = false
        delay(time) { () -> () in shouldReturn = true}
        
        while !shouldReturn {
            
        }
        return 47
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCreateFutureWithSuccess() {
        let expectation = expectationWithDescription("A Future with an operation that doesn't time out will be executed correctly")
        let future = Future<Int>({() -> Int in return self.complexOpDoneInTime(5.0)}).onSuccess({ (n: Int) -> () in print("n = \(n)"); expectation.fulfill() }).onFailure({ (ErrorType) -> () in return ()})
        XCTAssertNil(future.value, "An unfinished Future should yield a nil value")
        
        waitForExpectationsWithTimeout(future.opTimeout) { (error) -> Void in
            XCTAssertNotNil(future.value, "A finished Future shouldn't yield a nil value")
            if let value = future.value {
                switch value.matchResult {
                case .Success(let value): XCTAssertEqual(value, 47, "A finished successful Future should yield the correct result")
                case .Failure(_): XCTFail("A finished successful Future shouldn't yield a Failure")
                }
            }
        }
    }
    
    func testCreateFutureWithFailure() {
        weak var expectation = expectationWithDescription("A Future with an operation that times out will fail")
        let future = Future<Int>({() -> Int in return self.complexOpDoneInTime(5.0)}, timeout: 2.0).onFailure({ (ErrorType) -> () in expectation?.fulfill() })
        XCTAssertNil(future.value, "An unfinished Future should yield a nil value")
        
        waitForExpectationsWithTimeout(future.opTimeout + 1) { (error) -> Void in
            XCTAssertNotNil(future.value, "A finished Future shouldn't yield a nil value")
            if let value = future.value {
                switch value.matchResult {
                case .Success(_): XCTFail("A failed Future shouldn't yield a Success")
                case .Failure(_): break;
                }
            }
        }
    }

}
