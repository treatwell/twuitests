//  Copyright 2019 Hotspring Ventures Ltd.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import XCTest
@testable import TWUITests

class TWUITestsTests: XCTestCase {

    private var modifier: RegexJSONModifier!
    private var jsonInput: Data!

    override func setUp() {
        super.setUp()
        modifier = RegexJSONModifier()
        jsonInput = """
        {
            "k1" : "v1",
            "k2" : "v4",
            "k4" : [{
                "k1" : "v4",
                "k4" : "v3",
                "k3" : "v1"
            }]
        }
        """.data(using: .utf8) ?? Data()
    }

    override func tearDown() {
        modifier = nil
        jsonInput = nil
        super.tearDown()
    }

    func testKeyValuesReplacement() {
        let result = modifier.apply(modification: .replaceKeyValues([
            "k1": "v9",
            "k9": "v99",
            "k3": "v13"
        ]), in: jsonInput)
        let resultStr = String(data: result ?? Data(), encoding: .utf8)
        let exp = """
        {
            "k1" : "v9",
            "k2" : "v4",
            "k4" : [{
                "k1" : "v9",
                "k4" : "v3",
                "k3" : "v13"
            }]
        }
        """
        XCTAssertEqual(resultStr, exp)
    }
}
