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

import TWUITests

enum Stub {
    enum Authentication {
        static let success = APIStubInfo(statusCode: 200, url: "/v3/a34970a7-b5b4-4c7d-8b38-e74efb3ef895", jsonFilename: "stub.authentication", method: .GET)
        static let failure = APIStubInfo(statusCode: 500, url: "/v3/a34970a7-b5b4-4c7d-8b38-e74efb3ef895", jsonFilename: "stub.authentication", method: .GET)
    }
}
