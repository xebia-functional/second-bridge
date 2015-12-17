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

private let FutureDefaultTimeout: NSTimeInterval = 60
private let FutureDefaultQueueRandomSuffixLength = 16

enum FutureError: ErrorType {
    case OperationNotYetCompleted
    case Timeout
}

//internal struct ExecutionContext<T> {
//    let queue: dispatch_queue_t
//    let op: () -> T
//    let resultDestination: TryMatcher<T>
//    
//    init(
//    
//    func run() {
//        
//    }
//}

/// Defines a computation to be executed concurrently, that will either result in an timeout, or return a successfully computed value.
/// Future cannot encapsulate throwable functions, as these are not supported by GCD functions yet.
public class Future<T>: AnyObject {
    private var result: TryMatcher<T> = TryMatcher.Failure(FutureError.OperationNotYetCompleted)
    public var value: Try<T>? {
        get {
            switch result {
            case .Failure(FutureError.OperationNotYetCompleted): return nil
            case .Failure(let ex): return Try<T>(.Failure(ex))
            case .Success(let value): return Try<T>(.Success(value))
            }
        }
    }
    internal let callbackSuccess: (T -> ())?
    internal let callbackFailure: (ErrorType -> ())?
    
    // The following properties are needed to create instances derived from the current one (i.e.: adding callbacks using onSuccess/onFailure methods)
    public let opTimeout: NSTimeInterval
    private let opLaunchTime: NSDate
    private var timer: NSTimer?
    private let operation: () -> T
    
    /**
    - parameter timeout: timeout in seconds. If the operation isn't completed in that time, the result will be `.Failure(FutureError.Timeout)`.
    - parameter onSuccess: an optional callback to be called as soon as the encapsulated operation is completed with success.
    - parameter onFailure: an optional callback to be called as soon as the encapsulated operation fails or times out.
    - parameter shouldStartOperation: `true` if the encapsulated operation should start inmediately. `false` if not. (default is `true`).
    - parameter op: A throwable computation to be executed and encapsulated
    */
    public init(_ op: () -> T, timeout: Double = FutureDefaultTimeout, onSuccess: (T -> ())? = nil, onFailure: (ErrorType -> ())? = nil, shouldStartOperation: Bool = true) {
        callbackSuccess = onSuccess
        callbackFailure = onFailure
        opTimeout = timeout
        opLaunchTime = NSDate()
        operation = op
        
        if shouldStartOperation {
            self.run()
        }
    }
    
    /**
    Runs the operation encapsulated within the Future, if it didn't start it automatically (i.e.: setting `shouldStartOperation` to `false`) while initializing)
    */
    public func run() {
        if isNotCompleted() {
            timer = NSTimer.scheduledTimerWithTimeInterval(opTimeout, target: self, selector: "handleOperationFailure", userInfo: nil, repeats: false)
            let queue = dispatch_queue_create(String.randomStringWithLength(FutureDefaultQueueRandomSuffixLength), DISPATCH_QUEUE_CONCURRENT)
            dispatch_async(queue) { () -> Void in
                let result = self.operation()
                self.result = TryMatcher.Success(result)
                self.callbackSuccess?(result)
            }
        }
    }
    
    // This method needs to be marked as `dynamic` so NSTimer's Objective-C API can access its signature:
    private dynamic func handleOperationFailure() {
        if isNotCompleted() {
            result = .Failure(FutureError.Timeout)
            callbackFailure?(FutureError.Timeout)
        }
    }
    
    /**
    - returns: `true` if the operation inside the Future is in progress and didn't time out. `false` if the Future finished,
    with a Success or Failure results.
    */
    public func isNotCompleted() -> Bool {
        switch result {
        case .Failure(let ex):
            switch ex {
            case FutureError.OperationNotYetCompleted:
                return true
            default: break
            }
        default: break
        }
        return false
    }
    
    private static func partialFunctionToSuccessCallback(pf: PartialFunction<T, Any>) -> (T -> ()) {
        return { (t: T) -> () in
            if pf.isDefinedAt.apply(t) {
                pf.apply(t)
            }
        }
    }
    
    private static func partialFunctionToFailureCallback(pf: PartialFunction<ErrorType, Any>) -> (ErrorType -> ()) {
        return { (ex: ErrorType) -> () in
            if pf.isDefinedAt.apply(ex) {
                pf.apply(ex)
            }
        }
    }
    
    private func recreateFutureWithTimeout(timeout: NSTimeInterval, callbackSuccess: ((T) -> ())?, callbackFailure: ((ErrorType) -> ())?) -> Future<T> {
        let newFuture = Future(self.operation, timeout: timeout, onSuccess: callbackSuccess ?? self.callbackSuccess, onFailure: callbackFailure ?? self.callbackFailure, shouldStartOperation: true)
        newFuture.result = self.result
        return newFuture
    }
    
    /**
    - parameter callback: function to call if the Future finish with a succesful result.
    - returns: a modified Future including the provided success callback.
    */
    public func onSuccess(callback: (T -> ())) -> Future<T> {
        // To be able to return a new instance of the future (including the new callback), we need to stop the current timer and modify
        // the timeout
        let spentTime = self.opLaunchTime.timeIntervalSinceNow
        
        if isNotCompleted() {
            self.timer?.invalidate()
            return recreateFutureWithTimeout(self.opTimeout - spentTime, callbackSuccess: callback, callbackFailure: nil)
        } else {
            switch result {
            case .Success(let value):
                // As we have already a success, and the operation finished successfully, we first call the provided callback and then return the modified instance:
                callback(value)
                return recreateFutureWithTimeout(self.opTimeout - spentTime, callbackSuccess: callback, callbackFailure: nil)
            default:
                return recreateFutureWithTimeout(self.opTimeout - spentTime, callbackSuccess: callback, callbackFailure: nil)
            }
        }
    }
    
    /**
    - parameter callback: function to call if the Future finish with a failed result.
    - returns: a modified Future including the provided failure callback.
    */
    public func onFailure(callback: (ErrorType -> ())) -> Future<T> {
        let spentTime = self.opLaunchTime.timeIntervalSinceNow
        
        if isNotCompleted() {
            self.timer?.invalidate()
            return recreateFutureWithTimeout(self.opTimeout - spentTime, callbackSuccess: nil, callbackFailure: callback)
        } else {
            switch result {
            case .Failure(let ex):
                // As we have already a failure, and the operation finished with a failure, we first call the provided callback and then return the modified instance:
                callback(ex)
                return recreateFutureWithTimeout(self.opTimeout - spentTime, callbackSuccess: nil, callbackFailure: callback)
            case .Success(_):
                return recreateFutureWithTimeout(self.opTimeout - spentTime, callbackSuccess: nil, callbackFailure: nil)
            }
        }
    }
    
    /**
    - parameter success: function to call if the Future finish with a succesful result.
    - parameter failure: function to call if the Future finish with a failed result.
    - returns: a modified Future including the provided callbacks.
    */
    public func onComplete(success: (T) -> (), failure: (ErrorType) -> ()) -> Future<T> {
        return self.onSuccess(success).onFailure(failure)
    }
}