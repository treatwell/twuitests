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

final class Configuration: TWUITests.Configuration {
    var apiConfiguration: APIConfiguration = APIConfiguration(
        port: 4567,
        apiStubs: []// Add defaults API stubs here)
    )

    var dictionary: [String: String] = [
        ConfigurationKeys.isUITest: String(Bool(true)),
        ConfigurationKeys.isFirstTimeUser: String(Bool(false)),
        ConfigurationKeys.isAnimationsEnabled: String(Bool(false)),
        ConfigurationKeys.isUser: String(Bool(false))
    ]
}

extension Configuration {
    func isFirstTimeUser() -> Self {
        dictionary[ConfigurationKeys.isFirstTimeUser] = String(Bool(true))
        return self
    }
    
    func isUser(_ userName: String, password: String) -> Self {
        dictionary[ConfigurationKeys.isUser] = userName + "::" + password
        apiConfiguration.apiStubs.append(Stub.Authentication.success)
        return self
    }
    
    func isLoggedInUser() -> Self {
        return isUser("username@domain.com", password: "password")
    }
}
