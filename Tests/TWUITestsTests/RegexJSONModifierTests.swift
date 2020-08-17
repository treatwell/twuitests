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

final class RegexJSONModifierTests: XCTestCase {

    private var sut: RegexJSONModifier!
    private var jsonInput = """
        {
            "k1" : "v1",
            "k2" : "v4",
            "k4" : [{
                "k1" : "v4",
                "k4" : "v3",
                "k3" : "v1"
            }]
        }
        """.data(using: .utf8)!

    override func setUp() {
        super.setUp()
        sut = RegexJSONModifier()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testKeyValuesReplacement() throws {
        let result = try sut.apply(modification: .replaceKeyValues([
            "k1": "v9",
            "k9": "v99",
            "k3": "v13"
        ]), in: jsonInput)
        let resultStr = String(data: result, encoding: .utf8)
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

    func testValuesReplacement() throws {
        let result = try sut.apply(modification: .replaceValues([
            "v4": "v99",
            "k2": "v77",
            "v3": "v90"
        ]), in: jsonInput)
        let resultStr = String(data: result, encoding: .utf8)
        let exp = """
        {
            "k1" : "v1",
            "k2" : "v99",
            "k4" : [{
                "k1" : "v99",
                "k4" : "v90",
                "k3" : "v1"
            }]
        }
        """
        XCTAssertEqual(resultStr, exp)
    }
}
