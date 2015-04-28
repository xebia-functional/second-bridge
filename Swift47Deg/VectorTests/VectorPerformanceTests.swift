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


import UIKit
import XCTest

class VectorPerformanceTests: XCTestCase {

    var vectorSmall = Vector<Int>()
    var vectorMedium = Vector<Int>()
    var vectorBig = Vector<Int>()
    
    var arraySmall = Array<Int>()
    var arrayMedium = Array<Int>()
    var arrayBig = Array<Int>()
    
    override func setUp() {
        super.setUp()
        
        for i in 0..<64 {
            vectorSmall = vectorSmall.append(i)
            arraySmall.append(i)
        }
        
        for i in 0..<1000 {
            vectorMedium = vectorMedium.append(i)
            arrayMedium.append(i)
        }
        
        for i in 0..<100000 {
            vectorBig = vectorBig.append(i)
            arrayBig.append(i)
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testPerformanceAppendSmall() {
        self.measureBlock() {
            self.vectorSmall = self.vectorSmall.append(666)
        }
    }    
    
    func testPerformanceAppendMedium() {
        self.measureBlock() {
            self.vectorMedium = self.vectorMedium.append(666)
        }
    }
    
    func testPerformanceAppendBig() {
        self.measureBlock() {
            self.vectorBig = self.vectorBig.append(666)
        }
    }
    
    func testPerformanceUpdateSmall() {
        self.measureBlock() {
            self.vectorSmall = self.vectorSmall.update(5, obj: 666)
        }
    }
    
    func testPerformanceUpdateMedium() {
        self.measureBlock() {
            self.vectorMedium = self.vectorMedium.update(500, obj: 666)
        }
    }
    
    func testPerformanceUpdateBig() {
        self.measureBlock() {
            self.vectorBig = self.vectorBig.update(30000, obj: 666)
        }
    }
    
    func testPerformanceAccessSmall() {
        self.measureBlock() {
            for i in 0..<10 {
                let index = Int(arc4random_uniform(UInt32(self.vectorSmall.count)))
                let value = self.vectorSmall[index]
            }
        }
    }
    
    func testPerformanceAccessMedium() {
        self.measureBlock() {
            for i in 0..<10 {
                let index = Int(arc4random_uniform(UInt32(self.vectorMedium.count)))
                let value = self.vectorBig[index]
            }
        }
    }
    
    func testPerformanceAccessBig() {
        self.measureBlock() {
            for i in 0..<10 {
                let index = Int(arc4random_uniform(UInt32(self.vectorMedium.count)))
                let value = self.vectorBig[index]
            }
        }
    }
    
    // MARK: - Array performance tests
    
    func testPerformanceAppendArraySmall() {
        self.measureBlock() {
            self.arraySmall.append(666)
        }
    }
    
    
    func testPerformanceAppendArrayMedium() {
        self.measureBlock() {
            self.arrayMedium.append(666)
        }
    }
    
    func testPerformanceAppendArrayBig() {
        self.measureBlock() {
            self.arrayBig.append(666)
        }
    }
    
    func testPerformanceUpdateArraySmall() {
        self.measureBlock() {
            self.arraySmall[5] = 666
        }
    }
    
    func testPerformanceUpdateArrayMedium() {
        self.measureBlock() {
            self.arrayMedium[500] = 666
        }
    }
    
    func testPerformanceUpdateArrayBig() {
        self.measureBlock() {
            self.arrayBig[30000] = 666
        }
    }
    
    func testPerformanceAccessArraySmall() {
        self.measureBlock() {
            for i in 0..<10 {
                let index = Int(arc4random_uniform(UInt32(self.vectorSmall.count)))
                let value = self.arraySmall[index]
            }
        }
    }
    
    func testPerformanceAccessArrayMedium() {
        self.measureBlock() {
            for i in 0..<10 {
                let index = Int(arc4random_uniform(UInt32(self.vectorMedium.count)))
                let value = self.arrayMedium[index]
            }
        }
    }
    
    func testPerformanceAccessArrayBig() {
        self.measureBlock() {
            for i in 0..<10 {
                let index = Int(arc4random_uniform(UInt32(self.vectorMedium.count)))
                let value = self.arrayBig[index]
            }
        }
    }
}
