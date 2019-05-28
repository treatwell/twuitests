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

public struct APIStubInfo {
    public enum HTTPMethod {
        case POST
        case GET
        case PUT
        case DELETE
    }

    let statusCode: Int
    let url: String
    let jsonFilename: String
    let method: HTTPMethod
    
    public init(
        statusCode: Int,
        url: String,
        jsonFilename: String,
        method: HTTPMethod = .GET
    ) {
        self.statusCode = statusCode
        self.url = url
        self.jsonFilename = jsonFilename
        self.method = method
    }
}
