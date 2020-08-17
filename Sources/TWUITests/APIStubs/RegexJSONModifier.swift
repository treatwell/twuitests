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

import Foundation

struct RegexJSONModifier {

    enum ReplacementError: Error {
        case couldNotMakeStringFromData
        case couldNotMakeDataFromString
    }

    enum Modification {
        case replaceKeyValues([String: String])
        case replaceValues([String: String])
    }

    func apply(modification: Modification, in input: Data) throws -> Data {
        guard var string = String(data: input, encoding: .utf8) else {
            throw ReplacementError.couldNotMakeStringFromData
        }

        switch modification {
        case let .replaceKeyValues(items):
            for (key, value) in items {
                string = string.replacingOccurrences(
                    of: "\"\(key)\"\\s?:\\s?\".*\"",
                    with: "\"\(key)\" : \"\(value)\"",
                    options: .regularExpression
                )
            }
        case let .replaceValues(items):
            for (oldVal, newVal) in items {
                string = string.replacingOccurrences(
                    of: ":\\s?\"\(oldVal)\"",
                    with: ": \"\(newVal)\"",
                    options: .regularExpression
                )
            }
        }
        guard let result = string.data(using: .utf8) else {
            throw ReplacementError.couldNotMakeDataFromString
        }
        return result
    }
}
