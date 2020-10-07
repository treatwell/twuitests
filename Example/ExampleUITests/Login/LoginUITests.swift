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
import XCTest

final class LoginUITests: UITestCase {

    func testFirstTimeUserLoginScreenIsVisible() throws {
        try start(with: Configuration()
            .isFirstTimeUser()
        )
        .loginStep.loginScreenIsVisible()
    }

    func testEmptyUsernameOrPasswordShowsAlert() throws {
        try start(with: Configuration()
            .isFirstTimeUser()
        )
        .loginStep.providesEmptyCredentials()
        .loginStep.errorAlertIsVisible()
    }

    func testThatUserCanLogin() throws {
        try start(with: Configuration()
            .isFirstTimeUser()
        )
        .loginStep.providesUsername("hello@domain.com", password: "password")
        .homeStep.homeScreenIsVisible()
    }

    func testAPIResponse() throws {
        try start(with: Configuration()) { app in
            try app.replace(
                keysAndValues: [
                    "result": "NOT_AUTHENTICATED"
                ],
                in: Stub.Authentication.success
            )
        }
        .loginStep.authenticationStatusIsVisible()
        .loginStep.authenticationStatusIs(equal: "NOT_AUTHENTICATED")
    }
}
